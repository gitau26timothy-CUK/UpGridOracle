import sys
from typing import Optional

# Import SQLAlchemy components; fail gracefully but always declare `Base`
try:
    from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
    from sqlalchemy.orm import DeclarativeBase
    from app.config import settings
    DeclarativeBaseAvailable = True
except Exception as e:
    # If SQLAlchemy or app.config is unavailable at import-time, log and
    # fall back to minimal definitions so module import doesn't leave
    # models with an undefined `Base` class (which breaks ORM mapping).
    print(f"WARNING in app.database imports: {type(e).__name__}: {e}", file=sys.stderr)
    DeclarativeBaseAvailable = False


# Base class that all SQLAlchemy models will inherit from. If DeclarativeBase
# is available, use it so models are properly mapped even if engine creation
# later fails; otherwise provide a minimal placeholder.
if DeclarativeBaseAvailable:
    class Base(DeclarativeBase):
        pass
else:
    class Base:
        pass

# Try to create the async engine and sessionmaker; if this fails, continue
# with `engine = None` but keep `Base` defined so model classes are mapped.
try:
    engine_kwargs = {
        "echo": False,  # set True to log every SQL query (useful for debugging)
    }
    if settings.database_url.startswith("sqlite"):
        engine_kwargs["connect_args"] = {"check_same_thread": False}
    else:
        engine_kwargs["pool_size"] = 10
        engine_kwargs["max_overflow"] = 20

    engine = create_async_engine(settings.database_url, **engine_kwargs)

    # Session factory — creates individual DB sessions per request
    AsyncSessionLocal = async_sessionmaker(
        bind=engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )

    async def get_db() -> AsyncSession:
        async with AsyncSessionLocal() as session:
            try:
                yield session
                await session.commit()
            except Exception:
                await session.rollback()
                raise
            finally:
                await session.close()

except Exception as e:
    print(f"ERROR in app.database engine/session creation: {type(e).__name__}: {e}", file=sys.stderr)
    import traceback
    traceback.print_exc(file=sys.stderr)
    engine = None
    AsyncSessionLocal = None

    async def get_db():
        # Fallback dependency for environments without a DB during import-time
        yield None
