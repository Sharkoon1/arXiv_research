from __future__ import annotations

import asyncio
import logging
from collections.abc import Callable

from sqlalchemy.ext.asyncio import AsyncSession

from app.agents.news_agent import NewsAgent
from app.agents.news_ranking_agent import NewsRankingAgent
from app.models.news_item import NewsItem
from app.repositories.news_repository import NewsRepository

logger = logging.getLogger(__name__)


CATEGORY_PROMPTS: dict[str, str] = {
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

DEFAULT_CATEGORIES: list[str] = ["Model Release", "Product", "Industry", "Funding", "Partnership"]


class NewsService:
    def __init__(
        self,
        session_factory: Callable[[], AsyncSession],
        agent: NewsAgent | None = None,
        ranking_agent: NewsRankingAgent | None = None,
    ):
        self.session_factory = session_factory
        self.agent = agent or NewsAgent()
        self.ranking_agent = ranking_agent or NewsRankingAgent()

    async def list_all(self, db: AsyncSession) -> list[NewsItem]:
        return await NewsRepository(db).list_all_sorted()

    async def fetch_and_store(
        self,
        limit: int,
        categories: list[str] | None = None,
    ) -> list[NewsItem]:
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
            ranking_input += f"{label} news: {text} "

        ranking_raw = await self.ranking_agent.call_raw(ranking_input)
        if ranking_raw is None:
            return []
        items = self.ranking_agent._parse_json(ranking_raw)

        news: list[NewsItem] = []
        for item in items:
            try:
                async with self.session_factory() as db:
                    repo = NewsRepository(db)
                    news_item = await repo.upsert_by_url(item)
                    if news_item is not None:
                        news.append(news_item)
            except Exception as exc:
                logger.error("Failed to save news '%s': %s", item.get("title", "?"), exc)
        return news
