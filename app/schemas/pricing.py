from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional


# ===== Rate Tier Schemas =====
class RateTierCreate(BaseModel):
    """Create a new rate tier"""
    category: str = Field(..., description="e.g., residential, commercial")
    tier_name: str = Field(..., description="e.g., Tier1: 0-50kWh")
    min_consumption: float = Field(..., ge=0, description="Min kWh")
    max_consumption: float = Field(..., ge=0, description="Max kWh")
    base_rate_kes: float = Field(..., gt=0, description="KES per kWh")
    epra_alpha: float = Field(0.4)
    epra_beta: float = Field(0.35)
    epra_gamma: float = Field(0.25)


class RateTierResponse(RateTierCreate):
    """Rate tier response"""
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# ===== Consumption Schemas =====
class ConsumptionCreate(BaseModel):
    """Record consumption"""
    customer_id: str = Field(..., description="Meter number or customer ID")
    category: str = Field(..., description="residential, commercial, etc.")
    consumption_kwh: float = Field(..., gt=0, description="kWh consumed")
    billing_period: str = Field(..., description="e.g., 2026-03")


class ConsumptionResponse(ConsumptionCreate):
    """Consumption response"""
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


# ===== Pricing Calculation Schemas =====
class PricingRequest(BaseModel):
    """Calculate price for consumption"""
    customer_id: str
    category: str
    consumption_kwh: float = Field(..., gt=0)
    billing_period: str


class PricingBreakdown(BaseModel):
    """Breakdown of pricing calculation"""
    consumption_kwh: float
    tier_name: str
    base_rate_kes: float
    tier_consumption: float
    tier_cost: float
    epra_adjustment: float


class PricingResponse(BaseModel):
    """Complete pricing response"""
    customer_id: str
    consumption_kwh: float
    category: str
    billing_period: str
    base_amount_kes: float
    epra_adjustments: dict = Field(description="alpha, beta, gamma adjustments")
    total_amount_kes: float
    tiers_used: list[PricingBreakdown]


# ===== Invoice Schemas =====
class InvoiceCreate(BaseModel):
    """Create invoice from pricing"""
    customer_id: str
    consumption_id: int
    consumption_kwh: float
    category: str
    base_amount_kes: float
    total_amount_kes: float
    billing_period: str


class InvoiceResponse(InvoiceCreate):
    """Invoice response"""
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


# ===== Billing Summary Schema =====
class BillingSummaryResponse(BaseModel):
    """Billing summary for a customer and billing period"""
    customer_id: str
    billing_period: str
    total_consumption_kwh: float
    invoices: list[InvoiceResponse]
    total_billed_kes: float


# ===== Federation / Market Schemas =====
class BidCreate(BaseModel):
    """Per-household price bid for a settlement interval"""
    customer_id: str
    settlement_interval: str = Field(..., description="ISO timestamp or interval id")
    bid_price_kes: float = Field(..., gt=0, description="Price offered per kWh in KES")


class BidResponse(BidCreate):
    id: str
    status: str = Field("accepted")


class GradientUpdate(BaseModel):
    """A client's (encrypted/encoded) gradient update placeholder"""
    client_id: str
    model_version: str
    update_payload: str  # opaque, frontend will send an encrypted/encoded blob
    timestamp: datetime


class AggregationResult(BaseModel):
    """Result of a federated aggregation run"""
    aggregated_model_version: str
    clients_aggregated: int
    epsilon: float = Field(..., description="DP epsilon used; should be <=1.0 for production")


class PriceSignal(BaseModel):
    """Price signal emitted by the cloud to consumers"""
    billing_period: str
    settlement_interval: str
    price_kes: float
    metadata: dict = Field(default_factory=dict)
