"""KPLC billing integration client (stub).

This module provides a minimal async client to forward per-household bids
or price results to KPLC's billing/AMI REST endpoint. In production this
would include authentication, retries, robust error handling and schema
validation. For frontend alignment we expose a single `send_bid` helper.
"""
import os
import httpx


async def send_bid(bid_payload: dict) -> dict:
    """Send a bid payload to KPLC's REST API. Returns response JSON or raises."""
    kplc_url = os.getenv("KPLC_API_URL", "https://kplc.example/api/bids")
    timeout = float(os.getenv("KPLC_TIMEOUT", "5"))

    async with httpx.AsyncClient(timeout=timeout) as client:
        resp = await client.post(kplc_url, json=bid_payload)
        resp.raise_for_status()
        return resp.json()
