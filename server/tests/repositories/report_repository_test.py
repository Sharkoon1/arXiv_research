from app.repositories.report_repository import ReportRepository


async def test_create_and_get_by_id(db_session):
    repo = ReportRepository(db_session)

    created = await repo.create(
        name="Test Digest",
        briefing="One thing happened today.",
        paper_ids=["11111111-1111-1111-1111-111111111111"],
        news_ids=[],
    )

    assert created.id is not None
    fetched = await repo.get_by_id(created.id)
    assert fetched is not None
    assert fetched.name == "Test Digest"
    assert fetched.paper_ids == ["11111111-1111-1111-1111-111111111111"]


async def test_get_by_id_missing_returns_none(db_session):
    import uuid
    repo = ReportRepository(db_session)
    assert await repo.get_by_id(uuid.uuid4()) is None


async def test_list_all_newest_first(db_session):
    import asyncio
    repo = ReportRepository(db_session)

    first = await repo.create(name="A", briefing=None, paper_ids=[], news_ids=[])
    await asyncio.sleep(0.01)
    second = await repo.create(name="B", briefing=None, paper_ids=[], news_ids=[])

    rows = await repo.list_all()
    assert [r.id for r in rows] == [second.id, first.id]
