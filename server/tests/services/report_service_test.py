"""Unit tests for ReportService caching behavior.

These test the service layer in isolation: repos use the real SQLite session
fixture from conftest, while the cache is either a FakeRedisCache (hits/misses)
or a RedisCache whose client raises on every call (fallback to DB).
"""
from __future__ import annotations

import pytest
from redis.exceptions import RedisError

from app.core.exceptions import ReportNotFound
from app.core.redis_client import RedisCache
from app.repositories.news_repository import NewsRepository
from app.repositories.paper_repository import PaperRepository
from app.repositories.report_repository import ReportRepository
from app.services.report_service import ReportService
from tests.repositories.news_repository_test import NEWS_ITEM
from tests.repositories.paper_repository_test import PAPER_ITEM


def make_service(db_session, cache) -> ReportService:
    return ReportService(
        reports=ReportRepository(db_session),
        papers=PaperRepository(db_session),
        news=NewsRepository(db_session),
        cache=cache,
        ttl=60,
    )


async def _seed_report(db_session):
    paper = await PaperRepository(db_session).upsert_by_url(PAPER_ITEM)
    news = await NewsRepository(db_session).upsert_by_url(NEWS_ITEM)
    report = await ReportRepository(db_session).create(
        name="Test report",
        briefing="Brief.",
        paper_ids=[str(paper.id)],
        news_ids=[str(news.id)],
    )
    return report, paper, news


async def test_get_by_id_cache_miss_populates_cache(db_session, fake_cache):
    report, paper, _ = await _seed_report(db_session)
    service = make_service(db_session, fake_cache)

    detail = await service.get_by_id(report.id)

    assert detail.id == report.id
    assert [p.id for p in detail.papers] == [paper.id]
    cache_key = f"report:{report.id}"
    assert cache_key in fake_cache.store  # miss populated the cache


async def test_get_by_id_cache_hit_skips_db(db_session, fake_cache):
    report, _, _ = await _seed_report(db_session)
    service = make_service(db_session, fake_cache)

    # First call populates cache.
    await service.get_by_id(report.id)

    # Now detach the repo — a hit must not hit the DB.
    class ExplodingRepo:
        async def get_by_id(self, *_args, **_kwargs):
            raise AssertionError("Cache hit should not touch the report repo")

    service.reports = ExplodingRepo()  # type: ignore[assignment]
    detail = await service.get_by_id(report.id)
    assert detail.id == report.id


async def test_get_by_id_missing_raises_report_not_found(db_session, fake_cache):
    import uuid
    service = make_service(db_session, fake_cache)
    with pytest.raises(ReportNotFound):
        await service.get_by_id(uuid.uuid4())


async def test_redis_error_falls_back_to_db(db_session):
    report, _, _ = await _seed_report(db_session)

    class FlakyClient:
        async def get(self, *_args, **_kwargs):
            raise RedisError("boom")

        async def set(self, *_args, **_kwargs):
            raise RedisError("boom")

    cache = RedisCache(client=FlakyClient())  # type: ignore[arg-type]
    service = make_service(db_session, cache)

    # Should not raise — RedisCache swallows RedisError in both get and set.
    detail = await service.get_by_id(report.id)
    assert detail.id == report.id


async def test_list_all_returns_summaries(db_session, fake_cache):
    await _seed_report(db_session)
    service = make_service(db_session, fake_cache)

    summaries = await service.list_all()

    assert len(summaries) == 1
    assert summaries[0].paper_count == 1
    assert summaries[0].news_count == 1
