from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies import get_paper_service
from app.schemas.paper import PaperOut
from app.services.paper_service import PaperService

router = APIRouter()


@router.get("/papers", response_model=list[PaperOut])
async def list_papers(
    db: AsyncSession = Depends(get_db),
    service: PaperService = Depends(get_paper_service),
):
    return await service.list_all(db)
