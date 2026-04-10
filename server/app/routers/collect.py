import asyncio
import json
import random
from datetime import date
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db, AsyncSessionLocal
from app.models import Paper, NewsItem, Report
from app.schemas import (
    CollectRequest,
    CollectResultResponse,
    PaperOut,
    NewsItemOut,
)
from app.agents.papers_agent import PapersAgent
from app.agents.news_agent import NewsAgent
from app.agents.summarize_agent import SummarizeAgent

router = APIRouter()

# Random scientific-sounding report names
_PREFIXES = [
    "Quantum", "Neural", "Spectral", "Orbital", "Lattice", "Bayesian",
    "Stochastic", "Entropic", "Photonic", "Resonant", "Gradient", "Tensor",
    "Manifold", "Isotopic", "Kinetic", "Harmonic", "Geodesic", "Fractal",
    "Thermal", "Chromatic", "Ergodic", "Topological", "Holographic", "Axiomatic",
]
_NOUNS = [
    "Synthesis", "Dispatch", "Spectrum", "Convergence", "Cascade", "Lattice",
    "Protocol", "Survey", "Digest", "Analysis", "Signal", "Probe",
    "Vector", "Epoch", "Pulse", "Lens", "Index", "Atlas",
    "Codex", "Nexus", "Prism", "Field", "Matrix", "Kernel",
]
_SUFFIXES = [
    "Alpha", "Beta", "Gamma", "Delta", "Sigma", "Omega",
    "Prime", "Nova", "Echo", "Arc", "Tau", "Zeta",
]


def _generate_report_name() -> str:
    prefix = random.choice(_PREFIXES)
    noun = random.choice(_NOUNS)
    suffix = random.choice(_SUFFIXES)
    return f"{prefix} {noun} {suffix}"


async def _fetch_papers(limit: int) -> list[Paper]:
    agent = PapersAgent()
    items = await agent.call(limit)
    papers = []

    async with AsyncSessionLocal() as db:
        for item in items:
            try:
                existing = await db.execute(select(Paper).where(Paper.url == item["url"]))
                paper = existing.scalar_one_or_none()
                if paper:
                    paper.title = item.get("title", "")
                    paper.summary = item.get("summary", "")
                    paper.key_contribution = item.get("key_contribution", "")
                    paper.why_it_matters = item.get("why_it_matters", "")
                    paper.authors = item.get("authors", [])
                    paper.source = item.get("source", "")
                    paper.published_date = date.fromisoformat(item["published_date"])
                    paper.category = item.get("category", "other")
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
                        published_date=date.fromisoformat(item["published_date"]),
                        category=item.get("category", "other"),
                        importance_score=item.get("importance_score", 0),
                    )
                    db.add(paper)
                await db.commit()
                await db.refresh(paper)
                papers.append(paper)
            except Exception:
                await db.rollback()

    return papers


async def _fetch_news(limit: int) -> list[NewsItem]:
    agent = NewsAgent()
    items = await agent.call(limit)
    news = []

    async with AsyncSessionLocal() as db:
        for item in items:
            try:
                existing = await db.execute(select(NewsItem).where(NewsItem.url == item["url"]))
                news_item = existing.scalar_one_or_none()
                if news_item:
                    news_item.title = item.get("title", "")
                    news_item.summary = item.get("summary", "")
                    news_item.why_it_matters = item.get("why_it_matters", "")
                    news_item.source_name = item.get("source_name", "")
                    news_item.published_date = date.fromisoformat(item["published_date"])
                    news_item.category = item.get("category", "other")
                    news_item.importance_score = item.get("importance_score", 0)
                else:
                    news_item = NewsItem(
                        title=item.get("title", ""),
                        summary=item.get("summary", ""),
                        why_it_matters=item.get("why_it_matters", ""),
                        source_name=item.get("source_name", ""),
                        url=item["url"],
                        published_date=date.fromisoformat(item["published_date"]),
                        category=item.get("category", "other"),
                        importance_score=item.get("importance_score", 0),
                    )
                    db.add(news_item)
                await db.commit()
                await db.refresh(news_item)
                news.append(news_item)
            except Exception:
                await db.rollback()

    return news


@router.post("/collect", response_model=CollectResultResponse)
async def collect(body: CollectRequest):
    papers_limit = min(max(1, body.papers_limit), 50)
    news_limit = min(max(1, body.news_limit), 50)

    papers_result, news_result = await asyncio.gather(
        _fetch_papers(papers_limit),
        _fetch_news(news_limit),
        return_exceptions=True,
    )

    papers = [] if isinstance(papers_result, BaseException) else papers_result
    news = [] if isinstance(news_result, BaseException) else news_result
    paper_ids = [str(p.id) for p in papers]
    news_ids = [str(n.id) for n in news]

    errors = []
    if isinstance(papers_result, BaseException):
        errors.append(f"Papers agent failed: {papers_result}")
    if isinstance(news_result, BaseException):
        errors.append(f"News agent failed: {news_result}")

    # Build briefing from collected data
    briefing = None
    if papers or news:
        try:
            items_for_briefing = []
            for p in papers:
                items_for_briefing.append({
                    "type": "paper",
                    "title": p.title,
                    "summary": p.summary,
                    "key_contribution": p.key_contribution,
                    "why_it_matters": p.why_it_matters,
                    "authors": p.authors,
                    "source": p.source,
                    "url": p.url,
                    "published_date": p.published_date.isoformat(),
                    "category": p.category,
                    "importance_score": p.importance_score,
                })
            for n in news:
                items_for_briefing.append({
                    "type": "news",
                    "title": n.title,
                    "summary": n.summary,
                    "why_it_matters": n.why_it_matters,
                    "source": n.source_name,
                    "url": n.url,
                    "published_date": n.published_date.isoformat(),
                    "category": n.category,
                    "importance_score": n.importance_score,
                })
            agent = SummarizeAgent()
            briefing = await agent.call_raw(json.dumps(items_for_briefing))
        except Exception as e:
            errors.append(f"Summarize agent failed: {e}")

    # Save report
    report_name = _generate_report_name()
    async with AsyncSessionLocal() as db:
        report = Report(
            name=report_name,
            briefing=briefing,
            paper_ids=paper_ids,
            news_ids=news_ids,
        )
        db.add(report)
        await db.commit()
        await db.refresh(report)

    return CollectResultResponse(
        report_id=report.id,
        report_name=report.name,
        papers=[PaperOut.model_validate(p) for p in papers],
        news=[NewsItemOut.model_validate(n) for n in news],
        briefing=briefing,
        errors=errors,
    )
