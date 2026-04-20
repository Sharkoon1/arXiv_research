import uuid
from datetime import datetime
from typing import Optional
from sqlalchemy import String, Text, DateTime, JSON, Uuid
from sqlalchemy.orm import Mapped, mapped_column
from app.core.database import Base


class Report(Base):
    __tablename__ = "reports"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(120))
    briefing: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    paper_ids: Mapped[list] = mapped_column(JSON, default=list)
    news_ids: Mapped[list] = mapped_column(JSON, default=list)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
