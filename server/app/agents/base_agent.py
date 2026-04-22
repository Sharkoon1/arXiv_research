import json
import logging
import re

import httpx

from app.core.config import settings

logger = logging.getLogger(__name__)


class BaseAgent:
    agent_name: str  # set by subclass

    def __init__(self):
        self._base = settings.azure_project_endpoint
        self._headers = {
            "api-key": settings.azure_api_key,
            "Content-Type": "application/json",
        }
        self._params = {"api-version": settings.azure_api_version}

    async def _post(self, input_data: str) -> str | None:
        """Post to the agent and return the raw assistant text."""
        url = f"{self._base}/applications/{self.agent_name}/protocols/openai/responses"

        async with httpx.AsyncClient(timeout=120.0) as client:
            resp = await client.post(
                url,
                headers=self._headers,
                params=self._params,
                json={
                    "input": [
                        {
                            "role": "user",
                            "content": input_data,
                        }
                    ],
                },
            )
            if resp.status_code != 200:
                logger.error("Agent %s returned %s: %s", self.agent_name, resp.status_code, resp.text)
            resp.raise_for_status()
            data = resp.json()

            # Extract text output from the response
            output = data.get("output", [])
            for item in output:
                if item.get("type") == "message" and item.get("role") == "assistant":
                    content = item.get("content", [])
                    for block in content:
                        if block.get("type") == "output_text":
                            return block["text"]
                        if block.get("type") == "text":
                            return block["text"]

            # Fallback: try top-level output_text
            if isinstance(data.get("output_text"), str):
                return data["output_text"]

            return None

    async def call(self, limit: int) -> list[dict]:
        raw = await self._post(json.dumps({"limit": limit}))
        if raw is None:
            return []
        return self._parse_json(raw)

    async def call_with_retry(self, limit: int, max_attempts: int = 3) -> list[dict]:
        """Call the agent with retries until we have enough items or exhaust attempts."""
        all_items: list[dict] = []
        seen_urls: set[str] = set()

        for attempt in range(max_attempts):
            remaining = limit - len(all_items)
            if remaining <= 0:
                break

            if attempt == 0:
                payload = {"limit": limit}
            else:
                payload = {"limit": remaining, "exclude_urls": list(seen_urls)}

            raw = await self._post(json.dumps(payload))
            if raw is None:
                break

            try:
                items = self._parse_json(raw)
            except (json.JSONDecodeError, ValueError):
                logger.warning("Agent %s returned invalid JSON on attempt %d", self.agent_name, attempt + 1)
                break

            new_count = 0
            for item in items:
                url = item.get("url", "")
                if url and url not in seen_urls:
                    seen_urls.add(url)
                    all_items.append(item)
                    new_count += 1

            logger.info("Agent %s attempt %d: got %d new items (%d total, need %d)",
                        self.agent_name, attempt + 1, new_count, len(all_items), limit)

            if new_count == 0:
                break

        return all_items

    async def call_raw(self, input_data: str) -> str | None:
        """Call the agent and return the raw text response (no JSON parsing)."""
        return await self._post(input_data)

    @staticmethod
    def _parse_json(raw: str) -> list[dict]:
        raw = raw.strip()
        raw = re.sub(r"^```(?:json)?\s*", "", raw)
        raw = re.sub(r"\s*```$", "", raw)
        return json.loads(raw.strip())
