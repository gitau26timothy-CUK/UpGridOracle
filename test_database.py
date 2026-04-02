#!/usr/bin/env python3
"""Debug database module"""
print("Importing app.database module...")
try:
    import app.database
    print("✓ Module imported")
    print(f"Module contents: {dir(app.database)}")
    print(f"\nHas 'Base': {hasattr(app.database, 'Base')}")
    print(f"Has 'engine': {hasattr(app.database, 'engine')}")
    print(f"Has 'get_db': {hasattr(app.database, 'get_db')}")
    print(f"Has 'AsyncSessionLocal': {hasattr(app.database, 'AsyncSessionLocal')}")
except Exception as e:
    print(f"✗ Error importing: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()

print("\n\nTrying to execute database.py code directly...")
try:
    exec(open('app/database.py').read())
    print("✓ File executed")
except Exception as e:
    print(f"✗ Error: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()
