import uuid
from typing import Optional
from pydantic import BaseModel

from app.schemas.paper import PaperOut
from app.schemas.news import NewsItemOut


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
    briefing: Optional[str] = None
    errors: list[str] = []
