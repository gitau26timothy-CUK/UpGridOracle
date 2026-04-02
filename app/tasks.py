"""Background tasks for UpGridOracle (RQ-ready).

These functions are intentionally synchronous so they can be executed by a
separate RQ worker process. They use a synchronous SQLAlchemy engine derived
from the project's `settings.database_url`.
"""
from app.config import settings
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models import Consumption, Invoice


def _get_sync_db_url() -> str:
    url = settings.database_url
    # Convert async sqlite URL (sqlite+aiosqlite://) to sync (sqlite://)
    if "+aiosqlite" in url:
        return url.replace("+aiosqlite", "")
    return url


def generate_billing_summary(customer_id: str, billing_period: str) -> dict:
    """Generate a simple billing summary for a customer and period.

    This runs synchronously so RQ can execute it. It returns a small dict and
    prints the result for worker logs.
    """
    sync_url = _get_sync_db_url()
    connect_args = {}
    if sync_url.startswith("sqlite"):
        # SQLite needs this when used across threads/processes
        connect_args = {"check_same_thread": False}

    engine = create_engine(sync_url, connect_args=connect_args)
    SessionLocal = sessionmaker(bind=engine)

    with SessionLocal() as session:
        consumptions = (
            session.query(Consumption)
            .filter(Consumption.customer_id == customer_id, Consumption.billing_period == billing_period)
            .all()
        )

        total_consumption = sum(c.consumption_kwh for c in consumptions) if consumptions else 0.0

        invoices = (
            session.query(Invoice)
            .filter(Invoice.customer_id == customer_id, Invoice.billing_period == billing_period)
            .all()
        )
        total_billed = sum(inv.total_amount_kes for inv in invoices) if invoices else 0.0

    result = {
        "customer_id": customer_id,
        "billing_period": billing_period,
        "total_consumption_kwh": total_consumption,
        "total_billed_kes": total_billed,
        "status": "done",
    }

    print("[tasks.generate_billing_summary]", result)
    return result
