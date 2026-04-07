from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import Consumption, RateTier, Invoice
from app.schemas import (
    ConsumptionCreate,
    ConsumptionResponse,
    PricingRequest,
    PricingResponse,
    InvoiceCreate,
    InvoiceResponse,
    BillingSummaryResponse,
)
from app.core.pricing import calculate_complete_pricing
import os
import app.tasks as tasks

# Optional Redis/RQ integration — fall back when packages are not installed
try:
    from redis import Redis
    from rq import Queue
    _RQ_AVAILABLE = True
except Exception:  # pragma: no cover - fallback for test environments
    Redis = None
    Queue = None
    _RQ_AVAILABLE = False

router = APIRouter(prefix="/api/consumption", tags=["Consumption & Pricing"])


@router.post("/record", response_model=ConsumptionResponse)
async def record_consumption(consumption: ConsumptionCreate, db: AsyncSession = Depends(get_db)):
    """Record customer consumption"""
    db_consumption = Consumption(**consumption.model_dump())
    db.add(db_consumption)
    await db.commit()
    await db.refresh(db_consumption)
    return db_consumption


@router.get("/history/{customer_id}", response_model=list[ConsumptionResponse])
async def get_customer_history(customer_id: str, db: AsyncSession = Depends(get_db)):
    """Get consumption history for a customer"""
    stmt = select(Consumption).where(Consumption.customer_id == customer_id).order_by(Consumption.created_at.desc())
    result = await db.execute(stmt)
    history = result.scalars().all()
    if not history:
        raise HTTPException(status_code=404, detail=f"No consumption records found for customer: {customer_id}")
    return history


@router.post("/calculate-price", response_model=PricingResponse)
async def calculate_price(request: PricingRequest, db: AsyncSession = Depends(get_db)):
    """
    Calculate pricing based on consumption and rate tiers.
    Returns breakdown with EPRA adjustments.
    """
    # Fetch applicable rate tiers for the category
    stmt = select(RateTier).where(RateTier.category == request.category).order_by(RateTier.min_consumption)
    result = await db.execute(stmt)
    tiers = result.scalars().all()

    if not tiers:
        raise HTTPException(
            status_code=404,
            detail=f"No rate tiers configured for category: {request.category}",
        )

    # Calculate pricing
    pricing = calculate_complete_pricing(
        customer_id=request.customer_id,
        consumption_kwh=request.consumption_kwh,
        category=request.category,
        billing_period=request.billing_period,
        rate_tiers=tiers,
    )

    return pricing


@router.get("/consumption/{consumption_id}", response_model=ConsumptionResponse)
async def get_consumption(consumption_id: int, db: AsyncSession = Depends(get_db)):
    """Get specific consumption record"""
    stmt = select(Consumption).where(Consumption.id == consumption_id)
    result = await db.execute(stmt)
    consumption = result.scalars().first()
    if not consumption:
        raise HTTPException(status_code=404, detail="Consumption record not found")
    return consumption


@router.post("/invoice", response_model=InvoiceResponse)
async def create_invoice(invoice: InvoiceCreate, db: AsyncSession = Depends(get_db)):
    """Create an invoice record from a pricing result"""
    db_invoice = Invoice(**invoice.model_dump())
    db.add(db_invoice)
    await db.commit()
    await db.refresh(db_invoice)
    return db_invoice


@router.get("/billing/summary/{customer_id}/{billing_period}", response_model=BillingSummaryResponse)
async def billing_summary(customer_id: str, billing_period: str, db: AsyncSession = Depends(get_db)):
    """Return billing summary: total consumption and invoices for a customer and period"""
    # total consumption
    stmt = select(Consumption).where(
        (Consumption.customer_id == customer_id) & (Consumption.billing_period == billing_period)
    )
    result = await db.execute(stmt)
    consumptions = result.scalars().all()

    total_consumption = sum(c.consumption_kwh for c in consumptions) if consumptions else 0.0

    # invoices
    stmt2 = select(Invoice).where(
        (Invoice.customer_id == customer_id) & (Invoice.billing_period == billing_period)
    )
    result2 = await db.execute(stmt2)
    invoices = result2.scalars().all()

    total_billed = sum(inv.total_amount_kes for inv in invoices) if invoices else 0.0

    return BillingSummaryResponse(
        customer_id=customer_id,
        billing_period=billing_period,
        total_consumption_kwh=total_consumption,
        invoices=invoices,
        total_billed_kes=total_billed,
    )


@router.post("/billing/summary-async")
async def billing_summary_async(customer_id: str, billing_period: str):
    """Enqueue a background job to generate a billing summary using RQ.

    Requires a running Redis instance reachable via `REDIS_URL` env var or
    default `redis://localhost:6379/0`.
    """
    if not _RQ_AVAILABLE:
        # RQ/Redis not available in this environment — run synchronously as a fallback
        result = tasks.generate_billing_summary(customer_id, billing_period)
        return {"job_id": None, "status": "completed_sync", "result": result}

    redis_url = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    conn = Redis.from_url(redis_url)
    q = Queue(connection=conn)
    # enqueue the callable; RQ will serialize by import path
    job = q.enqueue(tasks.generate_billing_summary, customer_id, billing_period)
    return {"job_id": job.id, "status": "queued"}
