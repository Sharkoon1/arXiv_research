import uuid
from datetime import datetime, date
from sqlalchemy import String, Text, Integer, DateTime, Date, JSON, Uuid
from sqlalchemy.orm import Mapped, mapped_column
from app.core.database import Base


class Paper(Base):
    __tablename__ = "papers"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    title: Mapped[str] = mapped_column(Text)
    summary: Mapped[str] = mapped_column(Text)
    key_contribution: Mapped[str] = mapped_column(Text)
    why_it_matters: Mapped[str] = mapped_column(Text)
    authors: Mapped[list] = mapped_column(JSON)
    source: Mapped[str] = mapped_column(Text)
    url: Mapped[str] = mapped_column(Text, unique=True)
    published_date: Mapped[date] = mapped_column(Date)
    category: Mapped[str] = mapped_column(String(100))
    importance_score: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
