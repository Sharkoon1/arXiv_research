from __future__ import annotations

import uuid

from app.core.exceptions import ReportNotFound
from app.core.redis_client import RedisCache
from app.repositories.news_repository import NewsRepository
from app.repositories.paper_repository import PaperRepository
from app.repositories.report_repository import ReportRepository
from app.schemas.news import NewsItemOut
from app.schemas.paper import PaperOut
from app.schemas.report import ReportDetail, ReportSummary


class ReportService:
    """Reads reports, with Redis caching on the expensive GET /reports/{id} path.

    Reports are immutable after creation, so a long TTL is sufficient and no
    invalidation hook is needed when new reports are created.
    """

    CACHE_PREFIX = "report:"

    def __init__(
        self,
        reports: ReportRepository,
        papers: PaperRepository,
        news: NewsRepository,
        cache: RedisCache,
        ttl: int,
    ):
        self.reports = reports
        self.papers = papers
        self.news = news
        self.cache = cache
        self.ttl = ttl

    def _cache_key(self, report_id: uuid.UUID) -> str:
        return f"{self.CACHE_PREFIX}{report_id}"

    async def list_all(self) -> list[ReportSummary]:
        rows = await self.reports.list_all()
        return [
            ReportSummary(
                id=r.id,
                name=r.name,
                created_at=r.created_at,
                paper_count=len(r.paper_ids or []),
                news_count=len(r.news_ids or []),
            )
            for r in rows
        ]

    async def get_by_id(self, report_id: uuid.UUID) -> ReportDetail:
        cached = await self.cache.get(self._cache_key(report_id))
        if cached is not None:
            return ReportDetail.model_validate_json(cached)

        report = await self.reports.get_by_id(report_id)
        if report is None:
            raise ReportNotFound(str(report_id))

        papers = await self.papers.get_many_by_ids(report.paper_ids or [])
        news = await self.news.get_many_by_ids(report.news_ids or [])

        detail = ReportDetail(
            id=report.id,
            name=report.name,
            briefing=report.briefing,
            papers=[PaperOut.model_validate(p) for p in papers],
            news=[NewsItemOut.model_validate(n) for n in news],
            created_at=report.created_at,
        )

        await self.cache.set(
            self._cache_key(report_id),
            detail.model_dump_json(),
            ttl=self.ttl,
        )
        return detail
