from app.repositories.news_repository import NewsRepository

NEWS_ITEM = {
    "title": "OpenAI releases GPT-X",
    "summary": "A new frontier model.",
    "why_it_matters": "Better reasoning.",
    "source_name": "TechCrunch",
    "url": "https://techcrunch.com/gpt-x",
    "published_date": "2025-01-15",
    "category": "product",
    "importance_score": 85,
}


async def test_upsert_inserts_new_row(db_session):
    repo = NewsRepository(db_session)

    news = await repo.upsert_by_url(NEWS_ITEM)

    assert news.id is not None
    assert news.source_name == "TechCrunch"


async def test_upsert_updates_existing_row_by_url(db_session):
    repo = NewsRepository(db_session)
    first = await repo.upsert_by_url(NEWS_ITEM)
    updated = {**NEWS_ITEM, "title": "GPT-X v2", "importance_score": 95}
    second = await repo.upsert_by_url(updated)

    assert first.id == second.id
    assert second.title == "GPT-X v2"


async def test_list_all_sorted_by_importance_desc(db_session):
    repo = NewsRepository(db_session)
    await repo.upsert_by_url({**NEWS_ITEM, "url": "https://a", "importance_score": 10})
    await repo.upsert_by_url({**NEWS_ITEM, "url": "https://b", "importance_score": 90})

    news = await repo.list_all_sorted()

    assert [n.url for n in news] == ["https://b", "https://a"]


async def test_get_many_by_ids(db_session):
    repo = NewsRepository(db_session)
    a = await repo.upsert_by_url({**NEWS_ITEM, "url": "https://a"})
    b = await repo.upsert_by_url({**NEWS_ITEM, "url": "https://b"})

    result = await repo.get_many_by_ids([str(a.id), str(b.id)])

    assert {n.id for n in result} == {a.id, b.id}
