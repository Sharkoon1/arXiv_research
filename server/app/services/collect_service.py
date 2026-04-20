from __future__ import annotations

import asyncio
import json
import random
from typing import Callable, Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.agents.summarize_agent import SummarizeAgent
from app.repositories.report_repository import ReportRepository
from app.schemas.collect import CollectRequest, CollectResultResponse
from app.schemas.news import NewsItemOut
from app.schemas.paper import PaperOut
from app.services.news_service import NewsService
from app.services.paper_service import PaperService


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
    return f"{random.choice(_PREFIXES)} {random.choice(_NOUNS)} {random.choice(_SUFFIXES)}"


class CollectService:
    def __init__(
        self,
        paper_service: PaperService,
        news_service: NewsService,
        session_factory: Callable[[], AsyncSession],
        summarize_agent: Optional[SummarizeAgent] = None,
    ):
        self.paper_service = paper_service
        self.news_service = news_service
        self.session_factory = session_factory
        self.summarize_agent = summarize_agent or SummarizeAgent()

    async def run(self, body: CollectRequest) -> CollectResultResponse:
        papers_limit = min(max(1, body.papers_limit), 50)
        news_limit = min(max(1, body.news_limit), 50)

        papers_result, news_result = await asyncio.gather(
            self.paper_service.fetch_and_store(papers_limit, body.paper_categories or None),
            self.news_service.fetch_and_store(news_limit, body.news_categories or None),
            return_exceptions=True,
        )

        papers = [] if isinstance(papers_result, BaseException) else papers_result
        news = [] if isinstance(news_result, BaseException) else news_result

        errors: list[str] = []
        if isinstance(papers_result, BaseException):
            errors.append(f"Papers agent failed: {papers_result}")
        if isinstance(news_result, BaseException):
            errors.append(f"News agent failed: {news_result}")

        briefing = await self._build_briefing(papers, news, errors)

        async with self.session_factory() as db:
            report = await ReportRepository(db).create(
                name=_generate_report_name(),
                briefing=briefing,
                paper_ids=[str(p.id) for p in papers],
                news_ids=[str(n.id) for n in news],
            )

        return CollectResultResponse(
            report_id=report.id,
            report_name=report.name,
            papers=[PaperOut.model_validate(p) for p in papers],
            news=[NewsItemOut.model_validate(n) for n in news],
            briefing=briefing,
            errors=errors,
        )

    async def _build_briefing(self, papers, news, errors: list[str]) -> Optional[str]:
        if not (papers or news):
            return None
        try:
            items = []
            for p in papers:
                items.append({
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
                items.append({
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
            return await self.summarize_agent.call_raw(json.dumps(items))
        except Exception as exc:
            errors.append(f"Summarize agent failed: {exc}")
            return None
