from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func
from app.database import Base


class Consumption(Base):
    """Track customer electricity consumption"""
    __tablename__ = "consumptions"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(String(100), nullable=False, index=True)  # e.g., meter number
    category = Column(String(50), nullable=False, index=True)  # residential, commercial, etc.
    consumption_kwh = Column(Float, nullable=False)  # Total kWh consumed
    billing_period = Column(String(20), nullable=False)  # e.g., "2026-03"
    created_at = Column(DateTime, server_default=func.now())

    def __repr__(self):
        return f"<Consumption customer={self.customer_id} kWh={self.consumption_kwh}>"
