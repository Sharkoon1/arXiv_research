from app.repositories.news_repository import NewsRepository
from tests.repositories.news_repository_test import NEWS_ITEM


async def test_list_news_empty(client):
    resp = await client.get("/news")
    assert resp.status_code == 200
    assert resp.json() == []


async def test_list_news_returns_seeded_rows_sorted(client, db_session):
    repo = NewsRepository(db_session)
    await repo.upsert_by_url({**NEWS_ITEM, "url": "https://a", "importance_score": 10})
    await repo.upsert_by_url({**NEWS_ITEM, "url": "https://b", "importance_score": 90})

    resp = await client.get("/news")

    assert resp.status_code == 200
    body = resp.json()
    assert [n["url"] for n in body] == ["https://b", "https://a"]
