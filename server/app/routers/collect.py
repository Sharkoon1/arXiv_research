import asyncio
import json
import logging
import random
from datetime import date
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException

logger = logging.getLogger(__name__)
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
from app.agents.papers_ranking_agent import PapersRankingAgent
from app.agents.news_agent import NewsAgent
from app.agents.news_ranking_agent import NewsRankingAgent
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


def _parse_date(raw: str) -> date:
    try:
        return date.fromisoformat(raw)
    except (ValueError, TypeError):
        return date.today()


PAPER_CATEGORY_PROMPTS = {
    "LLM": "Find up to {n} recent AI research papers published in the last 14 days about large language models, LLM training, LLM inference, and LLM fine-tuning. Search arxiv for recent LLM papers. Return ONLY a JSON array.",
    "Machine Learning": "Find up to {n} recent AI research papers published in the last 14 days about machine learning, deep learning, supervised and unsupervised learning, and neural network training. Search arxiv for recent machine learning papers. Return ONLY a JSON array.",
    "Reasoning": "Find up to {n} recent AI research papers published in the last 14 days about AI reasoning, chain-of-thought, logical reasoning, mathematical reasoning, and commonsense reasoning. Search arxiv for recent AI reasoning papers. Return ONLY a JSON array.",
    "Agents": "Find up to {n} recent AI research papers published in the last 14 days about AI agents, tool use, agentic systems, autonomous agents, and multi-agent systems. Search arxiv for recent AI agents papers. Return ONLY a JSON array.",
    "Optimization": "Find up to {n} recent AI research papers published in the last 14 days about optimization, model compression, quantization, pruning, distillation, and efficient training. Search arxiv for recent AI optimization papers. Return ONLY a JSON array.",
    "Architecture": "Find up to {n} recent AI research papers published in the last 14 days about novel neural network architectures, transformers, mixture of experts, state space models, and model design. Search arxiv for recent AI architecture papers. Return ONLY a JSON array.",
    "Robotics": "Find up to {n} recent AI research papers published in the last 14 days about robotics, embodied AI, robot learning, manipulation, and autonomous systems. Search arxiv for recent robotics papers. Return ONLY a JSON array.",
    "Computer Vision": "Find up to {n} recent AI research papers published in the last 14 days about computer vision, object detection, image segmentation, 3D vision, and visual representation learning. Search arxiv for recent computer vision papers. Return ONLY a JSON array.",
    "Safety": "Find up to {n} recent AI research papers published in the last 14 days about AI safety, alignment, RLHF, red-teaming, jailbreaks, and responsible AI. Search arxiv for recent AI safety papers. Return ONLY a JSON array.",
    "Benchmark": "Find up to {n} recent AI research papers published in the last 14 days about AI benchmarks, evaluation, leaderboards, and model comparison. Search arxiv for recent AI benchmark papers. Return ONLY a JSON array.",
}

DEFAULT_PAPER_CATEGORIES = ["LLM", "Machine Learning", "Reasoning", "Agents", "Optimization"]

NEWS_CATEGORY_PROMPTS = {
    "Model Release": "Find up to {n} recent AI news from the last 14 days about new model launches, major AI model releases, and open-weights releases. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
    "Product": "Find up to {n} recent AI news from the last 14 days about AI product launches, new AI features, and AI tool announcements. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
    "Industry": "Find up to {n} recent AI news from the last 14 days about AI industry trends, company announcements, market developments, and corporate AI strategy. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
    "Funding": "Find up to {n} recent AI news from the last 14 days about AI funding rounds, acquisitions, startup investments, and AI market valuations. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
    "Partnership": "Find up to {n} recent AI news from the last 14 days about AI partnerships, collaborations, joint ventures, and strategic alliances between AI companies. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
    "Hardware": "Find up to {n} recent AI news from the last 14 days about AI chips, GPUs, AI hardware, and AI infrastructure developments. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
    "Policy": "Find up to {n} recent AI news from the last 14 days about AI regulation, AI policy, AI governance, and government AI initiatives. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
    "Research": "Find up to {n} recent AI news from the last 14 days about major AI research breakthroughs, record-setting benchmarks, and paradigm-shifting results. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
    "Safety": "Find up to {n} recent AI news from the last 14 days about AI safety developments, alignment research, AI ethics, and responsible AI initiatives. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
    "Job Market": "Find up to {n} recent AI news from the last 14 days about AI job market trends, AI hiring, AI workforce impact, layoffs, and AI skills demand. Categorize each item using one of: research, industry, policy, product, hardware, funding, safety, partnership, other. Return ONLY a JSON array.",
}

DEFAULT_NEWS_CATEGORIES = ["Model Release", "Product", "Industry", "Funding", "Partnership"]


async def _fetch_papers(limit: int, categories: Optional[list[str]] = None) -> list[Paper]:
    agent = PapersAgent()
    selected = categories if categories else DEFAULT_PAPER_CATEGORIES
    selected = [c for c in selected if c in PAPER_CATEGORY_PROMPTS]
    if not selected:
        selected = DEFAULT_PAPER_CATEGORIES
    per_category = max(2, -(-limit // len(selected)))

    # Parallel category searches
    prompts = [(c, PAPER_CATEGORY_PROMPTS[c].format(n=per_category)) for c in selected]
    raw_results = await asyncio.gather(
        *[agent.call_raw(p) for _, p in prompts],
        return_exceptions=True,
    )

    # Build ranking input
    ranking_input = f"Limit: {limit}. "
    for (label, _), result in zip(prompts, raw_results):
        text = result if isinstance(result, str) else "[]"
        ranking_input += f"{label} papers: {text} "

    # Rank and deduplicate
    ranking_agent = PapersRankingAgent()
    ranking_raw = await ranking_agent.call_raw(ranking_input)
    if ranking_raw is None:
        return []
    items = ranking_agent._parse_json(ranking_raw)

    # Save to DB
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
                    paper.published_date = _parse_date(item.get("published_date", ""))
                    paper.category = item.get("category", "other")[:100]
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
                        published_date=_parse_date(item.get("published_date", "")),
                        category=item.get("category", "other")[:100],
                        importance_score=item.get("importance_score", 0),
                    )
                    db.add(paper)
                await db.commit()
                await db.refresh(paper)
                papers.append(paper)
            except Exception as e:
                logger.error("Failed to save paper '%s': %s", item.get("title", "?"), e)
                await db.rollback()

    return papers


async def _fetch_news(limit: int, categories: Optional[list[str]] = None) -> list[NewsItem]:
    agent = NewsAgent()
    selected = categories if categories else DEFAULT_NEWS_CATEGORIES
    selected = [c for c in selected if c in NEWS_CATEGORY_PROMPTS]
    if not selected:
        selected = DEFAULT_NEWS_CATEGORIES
    per_category = max(2, -(-limit // len(selected)))

    # Parallel category searches
    prompts = [(c, NEWS_CATEGORY_PROMPTS[c].format(n=per_category)) for c in selected]
    raw_results = await asyncio.gather(
        *[agent.call_raw(p) for _, p in prompts],
        return_exceptions=True,
    )

    # Build ranking input
    ranking_input = f"Limit: {limit}. "
    for (label, _), result in zip(prompts, raw_results):
        text = result if isinstance(result, str) else "[]"
        ranking_input += f"{label} news: {text} "

    # Rank and deduplicate
    ranking_agent = NewsRankingAgent()
    ranking_raw = await ranking_agent.call_raw(ranking_input)
    if ranking_raw is None:
        return []
    items = ranking_agent._parse_json(ranking_raw)

    # Save to DB
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
                    news_item.published_date = _parse_date(item.get("published_date", ""))
                    news_item.category = item.get("category", "other")[:100]
                    news_item.importance_score = item.get("importance_score", 0)
                else:
                    news_item = NewsItem(
                        title=item.get("title", ""),
                        summary=item.get("summary", ""),
                        why_it_matters=item.get("why_it_matters", ""),
                        source_name=item.get("source_name", ""),
                        url=item["url"],
                        published_date=_parse_date(item.get("published_date", "")),
                        category=item.get("category", "other")[:100],
                        importance_score=item.get("importance_score", 0),
                    )
                    db.add(news_item)
                await db.commit()
                await db.refresh(news_item)
                news.append(news_item)
            except Exception as e:
                logger.error("Failed to save news '%s': %s", item.get("title", "?"), e)
                await db.rollback()

    return news


@router.post("/collect", response_model=CollectResultResponse)
async def collect(body: CollectRequest):
    papers_limit = min(max(1, body.papers_limit), 50)
    news_limit = min(max(1, body.news_limit), 50)

    papers_result, news_result = await asyncio.gather(
        _fetch_papers(papers_limit, body.paper_categories or None),
        _fetch_news(news_limit, body.news_categories or None),
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
