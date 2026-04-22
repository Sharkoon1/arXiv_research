import secrets

from fastapi import Header, HTTPException

from app.core.config import settings


async def verify_api_key(x_api_key: str = Header(...)) -> None:
    if not secrets.compare_digest(x_api_key, settings.app_api_key):
        raise HTTPException(status_code=401, detail="Invalid API key")
