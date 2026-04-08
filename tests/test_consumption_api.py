import uuid


def test_consumption_history_and_get(client):
    customer_id = f"cust_{uuid.uuid4().hex[:6]}"
    category = f"cat_{uuid.uuid4().hex[:6]}"
    payload = {
        "customer_id": customer_id,
        "category": category,
        "consumption_kwh": 42.5,
        "billing_period": "2026-03",
    }

    resp = client.post("/api/consumption/record", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    consumption_id = data["id"]

    resp = client.get(f"/api/consumption/consumption/{consumption_id}")
    assert resp.status_code == 200
    assert resp.json()["customer_id"] == customer_id

    resp = client.get(f"/api/consumption/history/{customer_id}")
    assert resp.status_code == 200
    history = resp.json()
    assert any(item["id"] == consumption_id for item in history)


def test_consumption_history_missing_customer_returns_404(client):
    resp = client.get("/api/consumption/history/missing-customer")
    assert resp.status_code == 404


def test_calculate_price_without_tiers_returns_404(client):
    payload = {
        "customer_id": "cust-missing",
        "category": f"missing_{uuid.uuid4().hex[:6]}",
        "consumption_kwh": 100.0,
        "billing_period": "2026-03",
    }

    resp = client.post("/api/consumption/calculate-price", json=payload)
    assert resp.status_code == 404
