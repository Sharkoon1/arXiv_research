import uuid
from datetime import datetime, date
from pydantic import BaseModel, ConfigDict


class PaperOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

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
