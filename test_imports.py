#!/usr/bin/env python3
"""Debug script to test imports"""
import sys
import os

print(f"Python: {sys.executable}")
print(f"CWD: {os.getcwd()}")
print(f".env exists: {os.path.exists('.env')}")
print()

# Test 1: import pydantic_settings
print("Test 1: Importing pydantic_settings...")
try:
    from pydantic_settings import BaseSettings, SettingsConfigDict
    print("✓ pydantic_settings imported")
except Exception as e:
    print(f"✗ {type(e).__name__}: {e}")
    sys.exit(1)

print()

# Test 2: Import app.config  
print("Test 2: Importing app.config...")
try:
    import app.config
    print(f"✓ app.config module imported")
    print(f"  - Settings class: {hasattr(app.config, 'Settings')}")
    print(f"  - settings instance: {hasattr(app.config, 'settings')}")
    if hasattr(app.config, 'settings'):
        settings = app.config.settings
        print(f"  - DATABASE_URL: {settings.database_url}")
except Exception as e:
    print(f"✗ {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print()

# Test 3: Import get_db
print("Test 3: Importing app.database.get_db...")
try:
    from app.database import get_db, Base, engine
    print("✓ app.database items imported")
except Exception as e:
    print(f"✗ {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print()
print("All tests passed! ✓")
