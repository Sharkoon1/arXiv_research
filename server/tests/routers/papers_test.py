from app.repositories.paper_repository import PaperRepository
from tests.repositories.paper_repository_test import PAPER_ITEM


async def test_list_papers_empty(client):
    resp = await client.get("/papers")
    assert resp.status_code == 200
    assert resp.json() == []


async def test_list_papers_returns_seeded_rows_sorted(client, db_session):
    repo = PaperRepository(db_session)
    await repo.upsert_by_url({**PAPER_ITEM, "url": "https://a", "importance_score": 10})
    await repo.upsert_by_url({**PAPER_ITEM, "url": "https://b", "importance_score": 90})

    resp = await client.get("/papers")

    assert resp.status_code == 200
    body = resp.json()
    assert [p["url"] for p in body] == ["https://b", "https://a"]


async def test_list_papers_requires_api_key(client):
    resp = await client.get("/papers", headers={"X-Api-Key": "wrong"})
    assert resp.status_code == 401
