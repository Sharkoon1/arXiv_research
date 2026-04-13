import asyncio
import logging
from typing import Optional

logger = logging.getLogger(__name__)

# Maps conversation_id -> (Event, result_text)
_pending: dict[str, tuple[asyncio.Event, list[Optional[str]]]] = {}


def register(conversation_id: str) -> asyncio.Event:
    """Register a pending callback and return an Event to await."""
    event = asyncio.Event()
    _pending[conversation_id] = (event, [None])
    return event


def resolve(conversation_id: str, text: Optional[str]) -> bool:
    """Resolve a pending callback with the result text. Returns True if found."""
    entry = _pending.pop(conversation_id, None)
    if entry is None:
        logger.warning("No pending callback for conversation %s", conversation_id)
        return False
    event, holder = entry
    holder[0] = text
    event.set()
    return True


def get_result(conversation_id: str) -> Optional[str]:
    """Get the result after the event fires. Call only after awaiting the event."""
    entry = _pending.pop(conversation_id, None)
    if entry is None:
        return None
    _, holder = entry
    return holder[0]


def cleanup(conversation_id: str):
    """Remove a pending callback (e.g. on timeout)."""
    _pending.pop(conversation_id, None)
