from __future__ import annotations

import uuid
from datetime import date
from typing import Iterable

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.news_item import NewsItem


def _parse_date(raw: str) -> date:
    try:
        return date.fromisoformat(raw)
    except (ValueError, TypeError):
        return date.today()


class NewsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def list_all_sorted(self) -> list[NewsItem]:
        result = await self.db.execute(
            select(NewsItem).order_by(NewsItem.importance_score.desc())
        )
        return list(result.scalars().all())

    async def get_many_by_ids(self, ids: Iterable[str | uuid.UUID]) -> list[NewsItem]:
        uuids = [uuid.UUID(str(i)) if not isinstance(i, uuid.UUID) else i for i in ids]
        if not uuids:
            return []
        result = await self.db.execute(select(NewsItem).where(NewsItem.id.in_(uuids)))
        return list(result.scalars().all())

    async def upsert_by_url(self, item: dict) -> NewsItem | None:
        try:
            existing = await self.db.execute(select(NewsItem).where(NewsItem.url == item["url"]))
            news_item = existing.scalar_one_or_none()
            if news_item:
                news_item.title = item.get("title", "")
                news_item.summary = item.get("summary", "")
                news_item.why_it_matters = item.get("why_it_matters", "")
                news_item.source_name = item.get("source_name", "")
                news_item.published_date = _parse_date(item.get("published_date", ""))
                news_item.category = item.get("category", "other")[:100]
                news_item.importance_score = item.get("importance_score", 0)
            else:
                news_item = NewsItem(
                    title=item.get("title", ""),
                    summary=item.get("summary", ""),
                    why_it_matters=item.get("why_it_matters", ""),
                    source_name=item.get("source_name", ""),
                    url=item["url"],
                    published_date=_parse_date(item.get("published_date", "")),
                    category=item.get("category", "other")[:100],
                    importance_score=item.get("importance_score", 0),
                )
                self.db.add(news_item)
            await self.db.commit()
            await self.db.refresh(news_item)
            return news_item
        except Exception:
            await self.db.rollback()
            raise
