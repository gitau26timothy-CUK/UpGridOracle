import traceback
print("Attempting to load config...")
try:
    exec(open('app/config.py').read())
    print("File executed successfully")
except ValidationError as e:
    print(f"ValidationError: {e}")
    traceback.print_exc()
except Exception as e:
    print(f"Exception: {type(e).__name__}: {e}")
    traceback.print_exc()
