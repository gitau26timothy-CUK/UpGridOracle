from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func
from app.database import Base


class RateTier(Base):
    """Electricity rate tiers with tier-based pricing"""
    __tablename__ = "rate_tiers"

    id = Column(Integer, primary_key=True, index=True)
    category = Column(String(50), nullable=False, unique=True)  # e.g., "residential", "commercial"
    tier_name = Column(String(100), nullable=False)  # e.g., "Tier1: 0-50kWh", "Tier2: 51-100kWh"
    min_consumption = Column(Float, nullable=False)  # kWh minimum
    max_consumption = Column(Float, nullable=False)  # kWh maximum
    base_rate_kes = Column(Float, nullable=False)  # KES per kWh
    epra_alpha = Column(Float, default=0.4)  # EPRA adjustment factor 1
    epra_beta = Column(Float, default=0.35)   # EPRA adjustment factor 2
    epra_gamma = Column(Float, default=0.25)  # EPRA adjustment factor 3
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    def __repr__(self):
        return f"<RateTier {self.category}: {self.tier_name}>"
