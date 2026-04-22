import uuid

from fastapi import APIRouter, Depends, HTTPException

from app.core.exceptions import ReportNotFound
from app.dependencies import get_report_service
from app.schemas.report import ReportDetail, ReportSummary
from app.services.report_service import ReportService

router = APIRouter()


@router.get("/reports", response_model=list[ReportSummary])
async def list_reports(service: ReportService = Depends(get_report_service)):
    return await service.list_all()


@router.get("/reports/{report_id}", response_model=ReportDetail)
async def get_report(
    report_id: uuid.UUID,
    service: ReportService = Depends(get_report_service),
):
    try:
        return await service.get_by_id(report_id)
    except ReportNotFound as err:
        raise HTTPException(status_code=404, detail="Report not found") from err
