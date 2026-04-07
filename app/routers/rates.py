from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import RateTier, Consumption, Invoice
from app.schemas import (
    RateTierCreate,
    RateTierResponse,
    ConsumptionCreate,
    ConsumptionResponse,
)

router = APIRouter(prefix="/api/rates", tags=["Rate Tiers"])


@router.post("/tiers", response_model=RateTierResponse)
async def create_rate_tier(tier: RateTierCreate, db: AsyncSession = Depends(get_db)):
    """Create a new rate tier"""
    # Check if tier already exists
    stmt = select(RateTier).where(
        (RateTier.category == tier.category) & (RateTier.tier_name == tier.tier_name)
    )
    existing = await db.execute(stmt)
    if existing.scalars().first():
        raise HTTPException(status_code=400, detail="Rate tier already exists")

    db_tier = RateTier(**tier.model_dump())
    db.add(db_tier)
    await db.commit()
    await db.refresh(db_tier)
    return db_tier


@router.get("/tiers/{category}", response_model=list[RateTierResponse])
async def get_category_tiers(category: str, db: AsyncSession = Depends(get_db)):
    """Get all tiers for a category"""
    stmt = select(RateTier).where(RateTier.category == category).order_by(RateTier.min_consumption)
    result = await db.execute(stmt)
    tiers = result.scalars().all()
    if not tiers:
        raise HTTPException(status_code=404, detail=f"No tiers found for category: {category}")
    return tiers


@router.get("/tiers", response_model=list[RateTierResponse])
async def list_all_tiers(db: AsyncSession = Depends(get_db)):
    """Get all rate tiers"""
    stmt = select(RateTier).order_by(RateTier.category, RateTier.min_consumption)
    result = await db.execute(stmt)
    return result.scalars().all()


@router.put("/tiers/{tier_id}", response_model=RateTierResponse)
async def update_rate_tier(tier_id: int, tier_update: RateTierCreate, db: AsyncSession = Depends(get_db)):
    """Update a rate tier"""
    stmt = select(RateTier).where(RateTier.id == tier_id)
    result = await db.execute(stmt)
    db_tier = result.scalars().first()
    if not db_tier:
        raise HTTPException(status_code=404, detail="Rate tier not found")

    for key, value in tier_update.model_dump().items():
        setattr(db_tier, key, value)
    
    await db.commit()
    await db.refresh(db_tier)
    return db_tier


@router.delete("/tiers/{tier_id}")
async def delete_rate_tier(tier_id: int, db: AsyncSession = Depends(get_db)):
    """Delete a rate tier"""
    stmt = select(RateTier).where(RateTier.id == tier_id)
    result = await db.execute(stmt)
    db_tier = result.scalars().first()
    if not db_tier:
        raise HTTPException(status_code=404, detail="Rate tier not found")

    await db.delete(db_tier)
    await db.commit()
    return {"message": "Rate tier deleted"}
