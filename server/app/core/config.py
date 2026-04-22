
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str
    azure_project_endpoint: str
    azure_api_key: str
    azure_api_version: str = "2025-11-15-preview"
    app_api_key: str
    redis_url: str | None = None
    cache_ttl_seconds: int = 86400


settings = Settings()
