from __future__ import annotations

import logging

import redis.asyncio as aioredis
from redis.exceptions import RedisError

logger = logging.getLogger(__name__)


class RedisCache:
    """Thin Redis wrapper with graceful fallback when Redis is unavailable.

    Why: we want the app to keep serving via DB when the cache is down,
    rather than failing the request.
    """

    def __init__(self, client: aioredis.Redis | None):
        self.client = client

    async def get(self, key: str) -> str | None:
        if self.client is None:
            return None
        try:
            value = await self.client.get(key)
            if value is None:
                return None
            return value.decode() if isinstance(value, bytes) else value
        except RedisError as exc:
            logger.warning("Redis GET %s failed: %s", key, exc)
            return None

    async def set(self, key: str, value: str, ttl: int) -> None:
        if self.client is None:
            return
        try:
            await self.client.set(key, value, ex=ttl)
        except RedisError as exc:
            logger.warning("Redis SET %s failed: %s", key, exc)

    async def close(self) -> None:
        if self.client is not None:
            try:
                await self.client.aclose()
            except RedisError:
                pass


async def build_redis_cache(url: str | None) -> RedisCache:
    if not url:
        return RedisCache(None)
    try:
        client = aioredis.from_url(url)
        await client.ping()
        return RedisCache(client)
    except RedisError as exc:
        logger.warning("Redis unreachable at %s (%s); continuing without cache", url, exc)
        return RedisCache(None)
