from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database import Base


class Invoice(Base):
    """Generated invoices with calculated pricing"""
    __tablename__ = "invoices"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(String(100), nullable=False, index=True)
    consumption_id = Column(Integer, ForeignKey("consumptions.id"), nullable=False)
    consumption_kwh = Column(Float, nullable=False)
    category = Column(String(50), nullable=False)
    base_amount_kes = Column(Float, nullable=False)  # Base cost before EPRA
    total_amount_kes = Column(Float, nullable=False)  # Final cost with EPRA adjustments
    billing_period = Column(String(20), nullable=False)
    created_at = Column(DateTime, server_default=func.now())

    def __repr__(self):
        return f"<Invoice customer={self.customer_id} amount={self.total_amount_kes} KES>"
