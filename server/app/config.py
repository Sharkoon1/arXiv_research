from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str
    azure_project_endpoint: str
    azure_api_key: str
    azure_api_version: str = "2025-11-15-preview"

    class Config:
        env_file = ".env"


settings = Settings()
