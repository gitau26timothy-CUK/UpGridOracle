import uuid


def test_rate_tier_crud_flow(client):
    category = f"rate_cat_{uuid.uuid4().hex[:6]}"
    payload = {
        "category": category,
        "tier_name": "T1",
        "min_consumption": 0,
        "max_consumption": 100,
        "base_rate_kes": 12.0,
        "epra_alpha": 0.4,
        "epra_beta": 0.35,
        "epra_gamma": 0.25,
    }

    resp = client.post("/api/rates/tiers", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    tier_id = data["id"]

    resp = client.get(f"/api/rates/tiers/{category}")
    assert resp.status_code == 200
    tiers = resp.json()
    assert len(tiers) == 1
    assert tiers[0]["category"] == category

    resp = client.get("/api/rates/tiers")
    assert resp.status_code == 200
    assert any(tier["id"] == tier_id for tier in resp.json())

    update_payload = {**payload, "base_rate_kes": 15.0}
    resp = client.put(f"/api/rates/tiers/{tier_id}", json=update_payload)
    assert resp.status_code == 200
    assert resp.json()["base_rate_kes"] == 15.0

    resp = client.delete(f"/api/rates/tiers/{tier_id}")
    assert resp.status_code == 200

    resp = client.get(f"/api/rates/tiers/{category}")
    assert resp.status_code == 404
