"""Shared pytest fixtures.

Env vars are set before any `app.*` import so `pydantic-settings` reads them
on first `Settings()` instantiation. The DB URL is SQLite in-memory with
``StaticPool`` so every session shares the same in-memory database.
"""
from __future__ import annotations

import os

os.environ.setdefault("DATABASE_URL", "sqlite+aiosqlite:///:memory:")
os.environ.setdefault("AZURE_PROJECT_ENDPOINT", "http://fake-azure.test")
os.environ.setdefault("AZURE_API_KEY", "fake-azure-key")
os.environ.setdefault("APP_API_KEY", "test-api-key")
os.environ.setdefault("REDIS_URL", "")

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.pool import StaticPool

from app import models  # noqa: F401 — ensure model classes register with Base.metadata
from app.core.database import Base, get_db
from app.core.redis_client import RedisCache
from app.dependencies import get_redis_cache
from app.main import app
from app.services.news_service import NewsService
from app.services.paper_service import PaperService

TEST_API_KEY = "test-api-key"


class FakeRedisCache(RedisCache):
    """In-memory dict cache with the same surface as RedisCache."""

    def __init__(self) -> None:
        super().__init__(client=None)
        self.store: dict[str, str] = {}

    async def get(self, key: str) -> str | None:
        return self.store.get(key)

    async def set(self, key: str, value: str, ttl: int) -> None:
        self.store[key] = value

    async def close(self) -> None:  # pragma: no cover
        pass


@pytest_asyncio.fixture
async def engine():
    eng = create_async_engine(
        "sqlite+aiosqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    async with eng.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    try:
        yield eng
    finally:
        await eng.dispose()


@pytest_asyncio.fixture
async def session_factory(engine):
    return async_sessionmaker(engine, expire_on_commit=False)


@pytest_asyncio.fixture
async def db_session(session_factory) -> AsyncSession:
    async with session_factory() as session:
        yield session


@pytest.fixture
def fake_cache() -> FakeRedisCache:
    return FakeRedisCache()


@pytest_asyncio.fixture
async def client(session_factory, fake_cache):
    """An AsyncClient bound to the FastAPI app with test overrides.

    ASGITransport does not fire the app's lifespan, so we wire the bits of
    app.state the routers need (paper_service, news_service) here.
    """
    async def override_get_db():
        async with session_factory() as session:
            yield session

    def override_get_cache() -> RedisCache:
        return fake_cache

    app.state.paper_service = PaperService(session_factory=session_factory)
    app.state.news_service = NewsService(session_factory=session_factory)
    app.state.redis_cache = fake_cache

    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[get_redis_cache] = override_get_cache

    transport = ASGITransport(app=app)
    async with AsyncClient(
        transport=transport,
        base_url="http://test",
        headers={"X-Api-Key": TEST_API_KEY},
    ) as ac:
        yield ac

    app.dependency_overrides.clear()
