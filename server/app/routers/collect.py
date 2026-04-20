from fastapi import APIRouter, Depends

from app.dependencies import get_collect_service
from app.schemas.collect import CollectRequest, CollectResultResponse
from app.services.collect_service import CollectService

router = APIRouter()


@router.post("/collect", response_model=CollectResultResponse)
async def collect(
    body: CollectRequest,
    service: CollectService = Depends(get_collect_service),
):
    return await service.run(body)
