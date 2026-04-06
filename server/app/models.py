import uuid
from datetime import datetime, date
from typing import Optional
from sqlalchemy import String, Text, Integer, DateTime, Date, JSON
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base


class Paper(Base):
    __tablename__ = "papers"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title: Mapped[str] = mapped_column(Text)
    summary: Mapped[str] = mapped_column(Text)
    key_contribution: Mapped[str] = mapped_column(Text)
    why_it_matters: Mapped[str] = mapped_column(Text)
    authors: Mapped[list] = mapped_column(JSON)
    source: Mapped[str] = mapped_column(String(50))
    url: Mapped[str] = mapped_column(Text, unique=True)
    published_date: Mapped[date] = mapped_column(Date)
    category: Mapped[str] = mapped_column(String(30))
    importance_score: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class NewsItem(Base):
    __tablename__ = "news_items"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title: Mapped[str] = mapped_column(Text)
    summary: Mapped[str] = mapped_column(Text)
    why_it_matters: Mapped[str] = mapped_column(Text)
    source_name: Mapped[str] = mapped_column(String(100))
    url: Mapped[str] = mapped_column(Text, unique=True)
    published_date: Mapped[date] = mapped_column(Date)
    category: Mapped[str] = mapped_column(String(30))
    importance_score: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class Report(Base):
    __tablename__ = "reports"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(120))
    briefing: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    paper_ids: Mapped[list] = mapped_column(JSON, default=list)
    news_ids: Mapped[list] = mapped_column(JSON, default=list)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
