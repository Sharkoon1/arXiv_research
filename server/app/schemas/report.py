import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

from app.schemas.paper import PaperOut
from app.schemas.news import NewsItemOut


class ReportSummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    created_at: datetime
    paper_count: int
    news_count: int


class ReportDetail(BaseModel):
    id: uuid.UUID
    name: str
    briefing: Optional[str] = None
    papers: list[PaperOut] = []
    news: list[NewsItemOut] = []
    created_at: datetime
