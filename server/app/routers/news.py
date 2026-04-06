from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import NewsItem
from app.schemas import NewsItemOut

router = APIRouter()


@router.get("/news", response_model=list[NewsItemOut])
async def list_news(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(NewsItem).order_by(NewsItem.importance_score.desc()))
    return result.scalars().all()
