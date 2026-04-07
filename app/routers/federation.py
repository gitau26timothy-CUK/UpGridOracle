from fastapi import APIRouter, HTTPException
from typing import List
from app.schemas.pricing import (
    GradientUpdate,
    AggregationResult,
    BidCreate,
    BidResponse,
    PriceSignal,
)
import asyncio
import uuid
import os

from app.integration.kplc import send_bid

router = APIRouter(prefix="/api/federation", tags=["Federation & Market"])

# In-memory stores used as lightweight stubs for proof-of-concept / frontend
# The production system would use persistent queues and secure aggregation.
_GRADIENT_BUFFER: List[GradientUpdate] = []
_BID_STORE: List[dict] = []


@router.post("/submit-update")
async def submit_gradient_update(update: GradientUpdate):
    """Accept a (opaque/encrypted) client gradient update.

    Frontend will send only encoded payloads; the server persists for later
    DP aggregation. This is a stub that accepts and acknowledges updates.
    """
    # Basic validation
    if not update.update_payload:
        raise HTTPException(status_code=400, detail="Empty update payload")

    _GRADIENT_BUFFER.append(update)
    return {"status": "received", "client_id": update.client_id}


@router.post("/aggregate", response_model=AggregationResult)
async def run_aggregation(epsilon: float = 1.0):
    """Run a simulated DP-SGD aggregation over buffered updates.

    This is a placeholder: it consumes the in-memory buffer and returns
    a mock aggregation result. In production, this would perform secure
    aggregation and apply DP mechanisms (ε ≤ 1.0 recommended).
    """
    if epsilon > 1.0:
        raise HTTPException(status_code=400, detail="Epsilon must be <= 1.0")

    clients = len(_GRADIENT_BUFFER)
    # Simulate some processing delay
    await asyncio.sleep(float(os.getenv("FED_AGG_DELAY", "0.1")))

    # Clear buffer after aggregation (stub behaviour)
    _GRADIENT_BUFFER.clear()

    return AggregationResult(
        aggregated_model_version=str(uuid.uuid4()),
        clients_aggregated=clients,
        epsilon=epsilon,
    )


@router.post("/market/submit-bid", response_model=BidResponse)
async def submit_bid(bid: BidCreate):
    """Accept a per-household bid and forward to KPLC asynchronously.

    Returns an acknowledgement to the caller while forwarding to KPLC.
    """
    bid_id = str(uuid.uuid4())
    record = {"id": bid_id, **bid.model_dump(), "status": "accepted"}
    _BID_STORE.append(record)

    # Fire-and-forget forwarding to KPLC; do not block the caller
    async def _forward(b):
        try:
            await send_bid(b)
        except Exception:
            # In production, record errors and retry
            pass

    asyncio.create_task(_forward(record))

    return BidResponse(id=bid_id, **bid.model_dump())


@router.get("/market/price-signal", response_model=PriceSignal)
async def get_price_signal(settlement_interval: str, billing_period: str):
    """Return the current price signal for a settlement interval (stub)."""
    # In production this would query the latest computed price for the interval
    return PriceSignal(
        billing_period=billing_period,
        settlement_interval=settlement_interval,
        price_kes=float(os.getenv("DEFAULT_PRICE_KES", "15.0")),
        metadata={"note": "stub price signal"},
    )
