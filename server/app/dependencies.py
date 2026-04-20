from __future__ import annotations

from fastapi import Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import AsyncSessionLocal, get_db
from app.core.redis_client import RedisCache
from app.repositories.news_repository import NewsRepository
from app.repositories.paper_repository import PaperRepository
from app.repositories.report_repository import ReportRepository
from app.services.collect_service import CollectService
from app.services.news_service import NewsService
from app.services.paper_service import PaperService
from app.services.report_service import ReportService


def get_redis_cache(request: Request) -> RedisCache:
    return request.app.state.redis_cache


def get_paper_service(request: Request) -> PaperService:
    return request.app.state.paper_service


def get_news_service(request: Request) -> NewsService:
    return request.app.state.news_service


def get_report_service(
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_redis_cache),
) -> ReportService:
    return ReportService(
        reports=ReportRepository(db),
        papers=PaperRepository(db),
        news=NewsRepository(db),
        cache=cache,
        ttl=settings.cache_ttl_seconds,
    )


def get_collect_service(request: Request) -> CollectService:
    return CollectService(
        paper_service=request.app.state.paper_service,
        news_service=request.app.state.news_service,
        session_factory=AsyncSessionLocal,
    )
