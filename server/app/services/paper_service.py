from __future__ import annotations

import asyncio
import logging
from collections.abc import Callable

from sqlalchemy.ext.asyncio import AsyncSession

from app.agents.papers_agent import PapersAgent
from app.agents.papers_ranking_agent import PapersRankingAgent
from app.models.paper import Paper
from app.repositories.paper_repository import PaperRepository

logger = logging.getLogger(__name__)


CATEGORY_PROMPTS: dict[str, str] = {
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

DEFAULT_CATEGORIES: list[str] = ["LLM", "Machine Learning", "Reasoning", "Agents", "Optimization"]


class PaperService:
    """Encapsulates paper retrieval via agents and persistence via the repository.

    Each upsert uses its own session so a single failure doesn't roll back the batch.
    """

    def __init__(
        self,
        session_factory: Callable[[], AsyncSession],
        agent: PapersAgent | None = None,
        ranking_agent: PapersRankingAgent | None = None,
    ):
        self.session_factory = session_factory
        self.agent = agent or PapersAgent()
        self.ranking_agent = ranking_agent or PapersRankingAgent()

    async def list_all(self, db: AsyncSession) -> list[Paper]:
        return await PaperRepository(db).list_all_sorted()

    async def fetch_and_store(
        self,
        limit: int,
        categories: list[str] | None = None,
    ) -> list[Paper]:
        selected = [c for c in (categories or DEFAULT_CATEGORIES) if c in CATEGORY_PROMPTS]
        if not selected:
            selected = DEFAULT_CATEGORIES
        per_category = max(2, -(-limit // len(selected)))

        prompts = [(c, CATEGORY_PROMPTS[c].format(n=per_category)) for c in selected]
        raw_results = await asyncio.gather(
            *[self.agent.call_raw(p) for _, p in prompts],
            return_exceptions=True,
        )

        ranking_input = f"Limit: {limit}. "
        for (label, _), result in zip(prompts, raw_results, strict=False):
            text = result if isinstance(result, str) else "[]"
            ranking_input += f"{label} papers: {text} "

        ranking_raw = await self.ranking_agent.call_raw(ranking_input)
        if ranking_raw is None:
            return []
        items = self.ranking_agent._parse_json(ranking_raw)

        papers: list[Paper] = []
        for item in items:
            try:
                async with self.session_factory() as db:
                    repo = PaperRepository(db)
                    paper = await repo.upsert_by_url(item)
                    if paper is not None:
                        papers.append(paper)
            except Exception as exc:
                logger.error("Failed to save paper '%s': %s", item.get("title", "?"), exc)
        return papers
