#!/usr/bin/env python3
"""Debug circular imports"""
try:
    print("Attempting to import app.routers.rates...")
    from app.routers import rates_router
    print("✓ SUCCESS: rates_router imported")
except Exception as e:
    print(f"✗ FAILED: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()
