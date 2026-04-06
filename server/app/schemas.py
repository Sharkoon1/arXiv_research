from __future__ import annotations
import uuid
from datetime import datetime, date
from typing import Optional
from pydantic import BaseModel


class CollectRequest(BaseModel):
    papers_limit: int = 25
    news_limit: int = 25


class CollectResultResponse(BaseModel):
    report_id: uuid.UUID
    report_name: str
    papers: list[PaperOut]
    news: list[NewsItemOut]
    briefing: Optional[str] = None
    errors: list[str] = []


class PaperOut(BaseModel):
    id: uuid.UUID
    title: str
    summary: str
    key_contribution: str
    why_it_matters: str
    authors: list[str]
    source: str
    url: str
    published_date: date
    category: str
    importance_score: int
    created_at: datetime

    class Config:
        from_attributes = True


class NewsItemOut(BaseModel):
    id: uuid.UUID
    title: str
    summary: str
    why_it_matters: str
    source_name: str
    url: str
    published_date: date
    category: str
    importance_score: int
    created_at: datetime

    class Config:
        from_attributes = True


class ReportSummary(BaseModel):
    id: uuid.UUID
    name: str
    created_at: datetime
    paper_count: int
    news_count: int

    class Config:
        from_attributes = True


class ReportDetail(BaseModel):
    id: uuid.UUID
    name: str
    briefing: Optional[str]
    papers: list[PaperOut]
    news: list[NewsItemOut]
    created_at: datetime
