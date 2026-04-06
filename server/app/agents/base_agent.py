import json
import logging
import re
from typing import Optional
import httpx
from app.config import settings

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

    async def _post(self, input_data: str) -> Optional[str]:
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

    async def call_raw(self, input_data: str) -> Optional[str]:
        """Call the agent and return the raw text response (no JSON parsing)."""
        return await self._post(input_data)

    @staticmethod
    def _parse_json(raw: str) -> list[dict]:
        raw = raw.strip()
        raw = re.sub(r"^```(?:json)?\s*", "", raw)
        raw = re.sub(r"\s*```$", "", raw)
        return json.loads(raw.strip())
