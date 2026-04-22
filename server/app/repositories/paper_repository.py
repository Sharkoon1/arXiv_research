from __future__ import annotations

import uuid
from collections.abc import Iterable
from datetime import date

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.paper import Paper


def _parse_date(raw: str) -> date:
    try:
        return date.fromisoformat(raw)
    except (ValueError, TypeError):
        return date.today()


class PaperRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def list_all_sorted(self) -> list[Paper]:
        result = await self.db.execute(
            select(Paper).order_by(Paper.importance_score.desc())
        )
        return list(result.scalars().all())

    async def get_many_by_ids(self, ids: Iterable[str | uuid.UUID]) -> list[Paper]:
        uuids = [uuid.UUID(str(i)) if not isinstance(i, uuid.UUID) else i for i in ids]
        if not uuids:
            return []
        result = await self.db.execute(select(Paper).where(Paper.id.in_(uuids)))
        return list(result.scalars().all())

    async def upsert_by_url(self, item: dict) -> Paper | None:
        """Insert or update a paper by unique URL. Returns the persisted row, or None on error."""
        try:
            existing = await self.db.execute(select(Paper).where(Paper.url == item["url"]))
            paper = existing.scalar_one_or_none()
            if paper:
                paper.title = item.get("title", "")
                paper.summary = item.get("summary", "")
                paper.key_contribution = item.get("key_contribution", "")
                paper.why_it_matters = item.get("why_it_matters", "")
                paper.authors = item.get("authors", [])
                paper.source = item.get("source", "")
                paper.published_date = _parse_date(item.get("published_date", ""))
                paper.category = item.get("category", "other")[:100]
                paper.importance_score = item.get("importance_score", 0)
            else:
                paper = Paper(
                    title=item.get("title", ""),
                    summary=item.get("summary", ""),
                    key_contribution=item.get("key_contribution", ""),
                    why_it_matters=item.get("why_it_matters", ""),
                    authors=item.get("authors", []),
                    source=item.get("source", ""),
                    url=item["url"],
                    published_date=_parse_date(item.get("published_date", "")),
                    category=item.get("category", "other")[:100],
                    importance_score=item.get("importance_score", 0),
                )
                self.db.add(paper)
            await self.db.commit()
            await self.db.refresh(paper)
            return paper
        except Exception:
            await self.db.rollback()
            raise
