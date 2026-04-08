def test_price_signal(client):
    resp = client.get(
        "/api/federation/market/price-signal",
        params={"settlement_interval": "2026-04-06T00:00:00Z", "billing_period": "2026-04"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert "price_kes" in data


def test_submit_bid(client, monkeypatch):
    async def _stub_send_bid(payload):
        return {"status": "ok", "payload": payload}

    monkeypatch.setenv("KPLC_API_URL", "http://example.test/bids")
    monkeypatch.setattr("app.routers.federation.send_bid", _stub_send_bid)

    payload = {
        "customer_id": "cust-1",
        "settlement_interval": "2026-04-06T00:00:00Z",
        "bid_price_kes": 12.5,
    }
    resp = client.post("/api/federation/market/submit-bid", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    assert data.get("customer_id") == "cust-1"
    assert "id" in data


def test_submit_gradient_and_aggregate(client, monkeypatch):
    monkeypatch.setenv("FED_AGG_DELAY", "0")
    grad = {
        "client_id": "c1",
        "model_version": "v1",
        "update_payload": "opaque",
        "timestamp": "2026-04-06T00:00:00Z",
    }
    r = client.post("/api/federation/submit-update", json=grad)
    assert r.status_code == 200

    r2 = client.post("/api/federation/aggregate", params={"epsilon": 1.0})
    assert r2.status_code == 200
    j = r2.json()
    assert float(j.get("epsilon", 0)) == 1.0


def test_submit_gradient_validation(client):
    payload = {
        "client_id": "c2",
        "model_version": "v1",
        "update_payload": "",
        "timestamp": "2026-04-06T00:00:00Z",
    }
    resp = client.post("/api/federation/submit-update", json=payload)
    assert resp.status_code == 400


def test_aggregate_rejects_large_epsilon(client):
    resp = client.post("/api/federation/aggregate", params={"epsilon": 1.5})
    assert resp.status_code == 400
