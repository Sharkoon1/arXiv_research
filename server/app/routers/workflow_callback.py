import logging
from fastapi import APIRouter, Request
from app import workflow_callback

logger = logging.getLogger(__name__)

router = APIRouter(tags=["workflow-callback"])


@router.post("/workflow/callback")
async def handle_callback(request: Request):
    """Receives activity responses from Azure workflow callbacks."""
    body = await request.json()
    logger.info("Workflow callback received: type=%s", body.get("type"))

    conversation_id = None
    conversation = body.get("conversation")
    if isinstance(conversation, dict):
        conversation_id = conversation.get("id")

    text = body.get("text")

    if conversation_id:
        workflow_callback.resolve(conversation_id, text)
    else:
        logger.warning("Callback missing conversation.id: %s", body)

    return {"status": "ok"}
