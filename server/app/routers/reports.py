from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import Report, Paper, NewsItem
from app.schemas import ReportSummary, ReportDetail, PaperOut, NewsItemOut
import uuid

router = APIRouter()


@router.get("/reports", response_model=list[ReportSummary])
async def list_reports(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Report).order_by(Report.created_at.desc()))
    reports = result.scalars().all()
    return [
        ReportSummary(
            id=r.id,
            name=r.name,
            created_at=r.created_at,
            paper_count=len(r.paper_ids),
            news_count=len(r.news_ids),
        )
        for r in reports
    ]


@router.get("/reports/{report_id}", response_model=ReportDetail)
async def get_report(report_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Report).where(Report.id == report_id))
    report = result.scalar_one_or_none()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")

    papers = []
    if report.paper_ids:
        uuids = [uuid.UUID(pid) for pid in report.paper_ids]
        result = await db.execute(select(Paper).where(Paper.id.in_(uuids)))
        papers = result.scalars().all()

    news = []
    if report.news_ids:
        uuids = [uuid.UUID(nid) for nid in report.news_ids]
        result = await db.execute(select(NewsItem).where(NewsItem.id.in_(uuids)))
        news = result.scalars().all()

    return ReportDetail(
        id=report.id,
        name=report.name,
        briefing=report.briefing,
        papers=[PaperOut.model_validate(p) for p in papers],
        news=[NewsItemOut.model_validate(n) for n in news],
        created_at=report.created_at,
    )
