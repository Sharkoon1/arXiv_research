import asyncio
import json
import logging
import re
import uuid
from typing import Optional
import httpx
from app.config import settings
from app import workflow_callback

logger = logging.getLogger(__name__)

CALLBACK_TIMEOUT = 120.0  # seconds to wait for workflow response


class WorkflowAgent:
    agent_name: str  # set by subclass

    def __init__(self):
        self._base = settings.azure_project_endpoint
        self._headers = {
            "api-key": settings.azure_api_key,
            "Content-Type": "application/json",
        }
        self._params = {"api-version": settings.azure_api_version}
        self._callback_url = f"{settings.server_base_url}/internal/workflow/callback"

    async def _post(self, input_data: str) -> Optional[str]:
        """Post to the workflow via activityprotocol and wait for callback response."""
        url = f"{self._base}/applications/{self.agent_name}/protocols/activityprotocol"
        conversation_id = str(uuid.uuid4())

        # Register callback before sending request
        event = workflow_callback.register(conversation_id)

        async with httpx.AsyncClient(timeout=120.0) as client:
            resp = await client.post(
                url,
                headers=self._headers,
                params=self._params,
                json={
                    "type": "message",
                    "text": input_data,
                    "channelId": "directline",
                    "from": {"id": "user"},
                    "conversation": {"id": conversation_id},
                    "serviceUrl": self._callback_url,
                },
            )
            if resp.status_code not in (200, 202):
                logger.error("Workflow %s returned %s: %s", self.agent_name, resp.status_code, resp.text)
                workflow_callback.cleanup(conversation_id)
                resp.raise_for_status()

        # Wait for the callback
        try:
            await asyncio.wait_for(event.wait(), timeout=CALLBACK_TIMEOUT)
        except asyncio.TimeoutError:
            logger.error("Workflow %s timed out waiting for callback (conversation=%s)", self.agent_name, conversation_id)
            workflow_callback.cleanup(conversation_id)
            return None

        return workflow_callback.get_result(conversation_id)

    async def call(self, limit: int) -> list[dict]:
        raw = await self._post(json.dumps({"limit": limit}))
        if raw is None:
            return []
        return self._parse_json(raw)

    async def call_with_retry(self, limit: int, max_attempts: int = 3) -> list[dict]:
        """Call the workflow with retries until we have enough items or exhaust attempts."""
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
                logger.warning("Workflow %s returned invalid JSON on attempt %d", self.agent_name, attempt + 1)
                break

            new_count = 0
            for item in items:
                url = item.get("url", "")
                if url and url not in seen_urls:
                    seen_urls.add(url)
                    all_items.append(item)
                    new_count += 1

            logger.info("Workflow %s attempt %d: got %d new items (%d total, need %d)",
                        self.agent_name, attempt + 1, new_count, len(all_items), limit)

            if new_count == 0:
                break

        return all_items

    async def call_raw(self, input_data: str) -> Optional[str]:
        """Call the workflow and return the raw text response (no JSON parsing)."""
        return await self._post(input_data)

    @staticmethod
    def _parse_json(raw: str) -> list[dict]:
        raw = raw.strip()
        raw = re.sub(r"^```(?:json)?\s*", "", raw)
        raw = re.sub(r"\s*```$", "", raw)
        return json.loads(raw.strip())
