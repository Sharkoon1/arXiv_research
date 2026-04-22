"""Unit tests for CollectService orchestration.

All collaborators — paper/news services, summarize agent, and the DB layer
(via a patched ReportRepository) — are mocked. The service is exercised in
full isolation, with no SQLAlchemy engine or real session involved.
"""
from __future__ import annotations

from datetime import date, datetime
from types import SimpleNamespace
from unittest.mock import AsyncMock
from uuid import uuid4

from app.schemas.collect import CollectRequest
from app.services.collect_service import CollectService


def _fake_paper(id_=None, title="Paper"):
    return SimpleNamespace(
        id=id_ or uuid4(),
        title=title,
        summary="s",
        key_contribution="k",
        why_it_matters="w",
        authors=["A"],
        source="arXiv",
        url="https://a",
        published_date=date(2025, 1, 1),
        category="LLM",
        importance_score=80,
        created_at=datetime(2025, 1, 1, 0, 0, 0),
    )


def _fake_news(id_=None, title="News"):
    return SimpleNamespace(
        id=id_ or uuid4(),
        title=title,
        summary="s",
        why_it_matters="w",
        source_name="TC",
        url="https://b",
        published_date=date(2025, 1, 1),
        category="product",
        importance_score=70,
        created_at=datetime(2025, 1, 1, 0, 0, 0),
    )


async def test_run_happy_path_saves_report(mock_session_factory):
    paper_service = SimpleNamespace(fetch_and_store=AsyncMock(return_value=[_fake_paper()]))
    news_service = SimpleNamespace(fetch_and_store=AsyncMock(return_value=[_fake_news()]))
    summarize = SimpleNamespace(call_raw=AsyncMock(return_value="briefing text"))

    svc = CollectService(paper_service, news_service, mock_session_factory, summarize_agent=summarize)

    result = await svc.run(CollectRequest(papers_limit=5, news_limit=5))

    assert result.briefing == "briefing text"
    assert len(result.papers) == 1 and len(result.news) == 1
    assert result.errors == []
    paper_service.fetch_and_store.assert_awaited_once_with(5, None)
    news_service.fetch_and_store.assert_awaited_once_with(5, None)

    assert len(mock_session_factory.saved_reports) == 1
    saved = mock_session_factory.saved_reports[0]
    assert saved.briefing == "briefing text"
    assert len(saved.paper_ids) == 1 and len(saved.news_ids) == 1


async def test_run_papers_agent_failure_still_saves_news(mock_session_factory):
    paper_service = SimpleNamespace(
        fetch_and_store=AsyncMock(side_effect=RuntimeError("papers down"))
    )
    news_service = SimpleNamespace(fetch_and_store=AsyncMock(return_value=[_fake_news()]))
    summarize = SimpleNamespace(call_raw=AsyncMock(return_value="b"))

    svc = CollectService(paper_service, news_service, mock_session_factory, summarize_agent=summarize)

    result = await svc.run(CollectRequest(papers_limit=3, news_limit=3))

    assert result.papers == []
    assert len(result.news) == 1
    assert any("Papers agent failed" in e for e in result.errors)

    saved = mock_session_factory.saved_reports[0]
    assert saved.paper_ids == [] and len(saved.news_ids) == 1


async def test_run_skips_briefing_when_both_empty(mock_session_factory):
    paper_service = SimpleNamespace(fetch_and_store=AsyncMock(return_value=[]))
    news_service = SimpleNamespace(fetch_and_store=AsyncMock(return_value=[]))
    summarize = SimpleNamespace(call_raw=AsyncMock(return_value="should not be called"))

    svc = CollectService(paper_service, news_service, mock_session_factory, summarize_agent=summarize)

    result = await svc.run(CollectRequest(papers_limit=1, news_limit=1))

    assert result.briefing is None
    summarize.call_raw.assert_not_awaited()
    assert mock_session_factory.saved_reports[0].briefing is None


async def test_run_summarize_failure_appends_error(mock_session_factory):
    paper_service = SimpleNamespace(fetch_and_store=AsyncMock(return_value=[_fake_paper()]))
    news_service = SimpleNamespace(fetch_and_store=AsyncMock(return_value=[]))
    summarize = SimpleNamespace(call_raw=AsyncMock(side_effect=RuntimeError("agent down")))

    svc = CollectService(paper_service, news_service, mock_session_factory, summarize_agent=summarize)

    result = await svc.run(CollectRequest(papers_limit=1, news_limit=1))

    assert result.briefing is None
    assert any("Summarize agent failed" in e for e in result.errors)
