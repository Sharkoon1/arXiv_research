from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import Paper
from app.schemas import PaperOut

router = APIRouter()


@router.get("/papers", response_model=list[PaperOut])
async def list_papers(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Paper).order_by(Paper.importance_score.desc()))
    return result.scalars().all()
