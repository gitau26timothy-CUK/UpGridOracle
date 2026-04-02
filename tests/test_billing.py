import uuid
from fastapi.testclient import TestClient

from app.main import app


def test_billing_summary_flow():
    client = TestClient(app)

    # unique category to avoid conflicts
    category = f"test_cat_{uuid.uuid4().hex[:6]}"

    # create a rate tier so calculate-price can find tiers
    tier_payload = {
        "category": category,
        "tier_name": "T1",
        "min_consumption": 0,
        "max_consumption": 1000,
        "base_rate_kes": 10.0,
    }
    r = client.post("/api/rates/tiers", json=tier_payload)
    assert r.status_code == 200

    # record consumption
    consumption_payload = {
        "customer_id": "CUST123",
        "category": category,
        "consumption_kwh": 150.0,
        "billing_period": "2026-03",
    }
    r = client.post("/api/consumption/record", json=consumption_payload)
    assert r.status_code == 200
    consumption = r.json()
    consumption_id = consumption["id"]

    # calculate price
    price_payload = {
        "customer_id": "CUST123",
        "category": category,
        "consumption_kwh": 150.0,
        "billing_period": "2026-03",
    }
    r = client.post("/api/consumption/calculate-price", json=price_payload)
    assert r.status_code == 200
    pricing = r.json()

    # create invoice from pricing
    invoice_payload = {
        "customer_id": pricing["customer_id"],
        "consumption_id": consumption_id,
        "consumption_kwh": pricing["consumption_kwh"],
        "category": pricing["category"],
        "base_amount_kes": pricing["base_amount_kes"],
        "total_amount_kes": pricing["total_amount_kes"],
        "billing_period": pricing["billing_period"],
    }
    r = client.post("/api/consumption/invoice", json=invoice_payload)
    assert r.status_code == 200
    invoice = r.json()

    # fetch billing summary
    r = client.get(f"/api/consumption/billing/summary/{pricing['customer_id']}/{pricing['billing_period']}")
    assert r.status_code == 200
    summary = r.json()

    assert summary["customer_id"] == pricing["customer_id"]
    assert summary["billing_period"] == pricing["billing_period"]
    assert summary["total_consumption_kwh"] >= 150.0
    assert summary["total_billed_kes"] >= pricing["total_amount_kes"]
