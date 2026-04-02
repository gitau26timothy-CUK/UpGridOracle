#!/usr/bin/env python3
"""Execute database.py and capture any errors"""
import sys
import io

# Redirect stderr to capture any errors
old_stderr = sys.stderr
sys.stderr = io.StringIO()

print("Attempting to import app.database...")
try:
    import app.database as db
except Exception as e:
    print(f"Error during import: {e}")
    import traceback
    traceback.print_exc()
finally:
    # Restore stderr and get any captured errors
    error_output = sys.stderr.getvalue()
    sys.stderr = old_stderr
    if error_output:
        print(f"\nCaptured stderr:\n{error_output}")

# Now check what's in the module
print(f"\nModule attributes: {[x for x in dir(db) if not x.startswith('_')]}")

# Try to explicitly check for the specific items
print("\nChecking for 'engine'...")
try:
    from app.database import engine
    print(f"✓ Got engine: {type(engine)}")
except ImportError as e:
    print(f"✗ Cannot import: {e}")

print("\nChecking for 'Base'...")
try:
    from app.database import Base
    print(f"✓ Got Base: {Base}")
except ImportError as e:
    print(f"✗ Cannot import: {e}")

print("\nChecking for 'get_db'...")
try:
    from app.database import get_db
    print(f"✓ Got get_db: {get_db}")
except ImportError as e:
    print(f"✗ Cannot import: {e}")

# Check if there are any exceptions silently happening
print("\nAttempting to reload the module...")
import importlib
try:
    importlib.reload(app.database)
    print("✓ Reloaded")
    print(f"After reload: {[x for x in dir(app.database) if not x.startswith('_')]}")
except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()
