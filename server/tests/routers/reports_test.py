import uuid

from app.repositories.news_repository import NewsRepository
from app.repositories.paper_repository import PaperRepository
from app.repositories.report_repository import ReportRepository

from tests.repositories.paper_repository_test import PAPER_ITEM
from tests.repositories.news_repository_test import NEWS_ITEM


async def test_list_reports_empty(client):
    resp = await client.get("/reports")
    assert resp.status_code == 200
    assert resp.json() == []


async def test_list_reports_returns_summary(client, db_session):
    paper = await PaperRepository(db_session).upsert_by_url(PAPER_ITEM)
    news = await NewsRepository(db_session).upsert_by_url(NEWS_ITEM)
    await ReportRepository(db_session).create(
        name="Digest",
        briefing="brief",
        paper_ids=[str(paper.id)],
        news_ids=[str(news.id)],
    )

    resp = await client.get("/reports")

    assert resp.status_code == 200
    body = resp.json()
    assert len(body) == 1
    assert body[0]["paper_count"] == 1
    assert body[0]["news_count"] == 1


async def test_get_report_detail(client, db_session, fake_cache):
    paper = await PaperRepository(db_session).upsert_by_url(PAPER_ITEM)
    report = await ReportRepository(db_session).create(
        name="Digest",
        briefing="brief",
        paper_ids=[str(paper.id)],
        news_ids=[],
    )

    resp = await client.get(f"/reports/{report.id}")

    assert resp.status_code == 200
    body = resp.json()
    assert body["name"] == "Digest"
    assert len(body["papers"]) == 1
    assert f"report:{report.id}" in fake_cache.store  # cache populated on miss


async def test_get_report_detail_cache_hit(client, db_session, fake_cache):
    paper = await PaperRepository(db_session).upsert_by_url(PAPER_ITEM)
    report = await ReportRepository(db_session).create(
        name="Digest",
        briefing="brief",
        paper_ids=[str(paper.id)],
        news_ids=[],
    )

    # First request populates the cache.
    first = await client.get(f"/reports/{report.id}")
    assert first.status_code == 200

    # Mutate the cached payload to prove the second read came from Redis.
    key = f"report:{report.id}"
    fake_cache.store[key] = fake_cache.store[key].replace('"Digest"', '"From cache"')

    second = await client.get(f"/reports/{report.id}")
    assert second.status_code == 200
    assert second.json()["name"] == "From cache"


async def test_get_report_detail_404(client):
    resp = await client.get(f"/reports/{uuid.uuid4()}")
    assert resp.status_code == 404
    assert resp.json()["detail"] == "Report not found"
