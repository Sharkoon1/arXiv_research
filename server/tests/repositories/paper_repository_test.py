from app.repositories.paper_repository import PaperRepository


PAPER_ITEM = {
    "title": "Attention Is All You Need",
    "summary": "Transformer architecture.",
    "key_contribution": "Self-attention.",
    "why_it_matters": "Foundation of modern LLMs.",
    "authors": ["Vaswani et al."],
    "source": "arXiv",
    "url": "https://arxiv.org/abs/1706.03762",
    "published_date": "2017-06-12",
    "category": "Architecture",
    "importance_score": 99,
}


async def test_upsert_inserts_new_row(db_session):
    repo = PaperRepository(db_session)

    paper = await repo.upsert_by_url(PAPER_ITEM)

    assert paper.id is not None
    assert paper.title == "Attention Is All You Need"
    assert paper.importance_score == 99


async def test_upsert_updates_existing_row_by_url(db_session):
    repo = PaperRepository(db_session)
    first = await repo.upsert_by_url(PAPER_ITEM)

    updated = {**PAPER_ITEM, "title": "Attention v2", "importance_score": 100}
    second = await repo.upsert_by_url(updated)

    assert first.id == second.id  # same row, not a duplicate
    assert second.title == "Attention v2"
    assert second.importance_score == 100


async def test_list_all_sorted_by_importance_desc(db_session):
    repo = PaperRepository(db_session)
    await repo.upsert_by_url({**PAPER_ITEM, "url": "https://a", "importance_score": 10})
    await repo.upsert_by_url({**PAPER_ITEM, "url": "https://b", "importance_score": 90})
    await repo.upsert_by_url({**PAPER_ITEM, "url": "https://c", "importance_score": 50})

    papers = await repo.list_all_sorted()

    assert [p.url for p in papers] == ["https://b", "https://c", "https://a"]


async def test_get_many_by_ids(db_session):
    repo = PaperRepository(db_session)
    a = await repo.upsert_by_url({**PAPER_ITEM, "url": "https://a"})
    b = await repo.upsert_by_url({**PAPER_ITEM, "url": "https://b"})
    await repo.upsert_by_url({**PAPER_ITEM, "url": "https://c"})

    result = await repo.get_many_by_ids([str(a.id), str(b.id)])

    assert {p.id for p in result} == {a.id, b.id}


async def test_get_many_by_ids_empty(db_session):
    repo = PaperRepository(db_session)
    assert await repo.get_many_by_ids([]) == []
