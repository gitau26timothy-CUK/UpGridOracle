#!/usr/bin/env python3
"""Verify workspace stacks: python, venv, imports, and DB connectivity."""
import sys
import os
import asyncio


def ok(msg: str):
    print("✓", msg)


def err(msg: str):
    print("✗", msg)


async def test_db():
    try:
        # Import engine from app.database and run a lightweight test query
        from app.database import engine
        if engine is None:
            err("No database engine configured (engine is None)")
            return False

        from sqlalchemy import text

        async with engine.begin() as conn:
            await conn.execute(text("SELECT 1"))
        ok("Database connection test passed")
        return True
    except Exception as e:
        err(f"Database connection test failed: {type(e).__name__}: {e}")
        return False


def main():
    print(f"Python executable: {sys.executable}")
    print(f"Python version: {sys.version.splitlines()[0]}")

    if os.path.exists('.venv'):
        ok(".venv directory present")
    else:
        err(".venv directory not found")

    overall_ok = True

    # Basic imports
    try:
        import app.config  # noqa: F401
        ok("Imported app.config")
    except Exception as e:
        err(f"Import app.config failed: {type(e).__name__}: {e}")
        overall_ok = False

    try:
        import app.main  # noqa: F401
        ok("Imported app.main")
    except Exception as e:
        err(f"Import app.main failed: {type(e).__name__}: {e}")
        overall_ok = False

    # Async DB test
    try:
        db_ok = asyncio.run(test_db())
    except Exception as e:
        err(f"Running DB test failed: {type(e).__name__}: {e}")
        db_ok = False

    if not (overall_ok and db_ok):
        err("Workspace verification FAILED")
        sys.exit(2)

    ok("All checks passed")
    sys.exit(0)


if __name__ == "__main__":
    main()
