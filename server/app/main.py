from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import AsyncSessionLocal, init_db
from app.core.redis_client import build_redis_cache
from app.core.security import verify_api_key
from app.routers import collect, news, papers, reports
from app.services.news_service import NewsService
from app.services.paper_service import PaperService


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    app.state.redis_cache = await build_redis_cache(settings.redis_url)
    app.state.paper_service = PaperService(session_factory=AsyncSessionLocal)
    app.state.news_service = NewsService(session_factory=AsyncSessionLocal)
    try:
        yield
    finally:
        await app.state.redis_cache.close()


app = FastAPI(
    title="ArXiv Research API",
    lifespan=lifespan,
    dependencies=[Depends(verify_api_key)],
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(collect.router)
app.include_router(papers.router)
app.include_router(news.router)
app.include_router(reports.router)


@app.get("/health")
async def health():
    return {"status": "ok"}
