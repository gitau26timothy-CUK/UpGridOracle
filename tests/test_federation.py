import pytest
from httpx import AsyncClient
from httpx._transports.asgi import ASGITransport
from app.main import app


@pytest.mark.asyncio
async def test_price_signal():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        resp = await ac.get(
            "/api/federation/market/price-signal",
            params={"settlement_interval": "2026-04-06T00:00:00Z", "billing_period": "2026-04"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "price_kes" in data


@pytest.mark.asyncio
async def test_submit_bid():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        payload = {
            "customer_id": "cust-1",
            "settlement_interval": "2026-04-06T00:00:00Z",
            "bid_price_kes": 12.5,
        }
        resp = await ac.post("/api/federation/market/submit-bid", json=payload)
        assert resp.status_code == 200
        data = resp.json()
        assert data.get("customer_id") == "cust-1"
        assert "id" in data


@pytest.mark.asyncio
async def test_submit_gradient_and_aggregate():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        grad = {
            "client_id": "c1",
            "model_version": "v1",
            "update_payload": "opaque",
            "timestamp": "2026-04-06T00:00:00Z",
        }
        r = await ac.post("/api/federation/submit-update", json=grad)
        assert r.status_code == 200

        r2 = await ac.post("/api/federation/aggregate", params={"epsilon": 1.0})
        assert r2.status_code == 200
        j = r2.json()
        assert float(j.get("epsilon", 0)) == 1.0
