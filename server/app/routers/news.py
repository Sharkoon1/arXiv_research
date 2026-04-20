from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies import get_news_service
from app.schemas.news import NewsItemOut
from app.services.news_service import NewsService

router = APIRouter()


@router.get("/news", response_model=list[NewsItemOut])
async def list_news(
    db: AsyncSession = Depends(get_db),
    service: NewsService = Depends(get_news_service),
):
    return await service.list_all(db)
