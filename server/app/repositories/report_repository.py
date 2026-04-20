from __future__ import annotations

import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.report import Report


class ReportRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def list_all(self) -> list[Report]:
        result = await self.db.execute(
            select(Report).order_by(Report.created_at.desc())
        )
        return list(result.scalars().all())

    async def get_by_id(self, report_id: uuid.UUID) -> Optional[Report]:
        result = await self.db.execute(select(Report).where(Report.id == report_id))
        return result.scalar_one_or_none()

    async def create(
        self,
        name: str,
        briefing: Optional[str],
        paper_ids: list[str],
        news_ids: list[str],
    ) -> Report:
        report = Report(
            name=name,
            briefing=briefing,
            paper_ids=paper_ids,
            news_ids=news_ids,
        )
        self.db.add(report)
        await self.db.commit()
        await self.db.refresh(report)
        return report
