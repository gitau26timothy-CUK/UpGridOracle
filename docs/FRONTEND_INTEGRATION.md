# Frontend Integration — UpGridOracle (Phase 1)

This document lists backend endpoints and example payloads that the Flutter frontend expects for Phase 1 pilot.

Base path: `/api/federation`

Endpoints

- `GET /market/price-signal` — query params: `settlement_interval`, `billing_period`
  - Response (JSON): `{ "billing_period": "2026-04", "settlement_interval": "2026-04-06T00:00:00Z", "price_kes": 15.0, "metadata": {...} }`

- `POST /market/submit-bid` — body: `{ "customer_id": str, "settlement_interval": str, "bid_price_kes": float }`
  - Response: acknowledgement with `id` and original fields.

- `POST /submit-update` — body (opaque gradient):
  ```json
  {
    "client_id": "device-123",
    "model_version": "v1",
    "update_payload": "<base64-or-encrypted-payload>",
    "timestamp": "2026-04-06T00:00:00Z"
  }
  ```

- `POST /aggregate` — query param `epsilon` (float, recommended ≤ 1.0)
  - Response: `{ "aggregated_model_version": "uuid", "clients_aggregated": 12, "epsilon": 1.0 }`

Notes for frontend engineers

- The `update_payload` is intentionally opaque — Phase 1 uses a stub that accepts any string. In Phase 2, the payload should be encrypted and encoded per the secure aggregation scheme.
- The `/market/submit-bid` endpoint forwards bids to KPLC asynchronously; the response is a local acknowledgement. For demo, the KPLC endpoint is a stub configured by `KPLC_API_URL` env var.
- The price-signal endpoint returns a single price for the requested settlement interval. The Flutter `OracleService` can poll this endpoint every 15 minutes or subscribe to a push mechanism later.

Example frontend flow

1. App starts, calls `GET /market/price-signal` to show initial rate.
2. OracleService runs timer → polls `/market/price-signal` every 15 minutes.
3. Device computes local PPFL gradient and `POST /submit-update` with opaque payload.
4. Device optionally `POST /market/submit-bid` to place a household bid for the interval.
