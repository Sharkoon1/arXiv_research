import uuid

from pydantic import BaseModel

from app.schemas.news import NewsItemOut
from app.schemas.paper import PaperOut


class CollectRequest(BaseModel):
    papers_limit: int = 25
    news_limit: int = 25
    paper_categories: list[str] = []
    news_categories: list[str] = []


class CollectResultResponse(BaseModel):
    report_id: uuid.UUID
    report_name: str
    papers: list[PaperOut] = []
    news: list[NewsItemOut] = []
    briefing: str | None = None
    errors: list[str] = []
