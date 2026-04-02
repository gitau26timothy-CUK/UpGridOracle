import sys
try:
    from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
    from sqlalchemy.orm import DeclarativeBase
    from app.config import settings

    # The engine is the connection pool — one per application lifetime
    engine = create_async_engine(
        settings.database_url,
        echo=False,       # set True to log every SQL query (useful for debugging)
        pool_size=10,
        max_overflow=20,
    )

    # Session factory — creates individual DB sessions per request
    AsyncSessionLocal = async_sessionmaker(
        bind=engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )

    # Base class that all SQLAlchemy models will inherit from
    class Base(DeclarativeBase):
        pass

    # Dependency — FastAPI injects this into route handlers
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
    print(f"ERROR in app.database: {type(e).__name__}: {e}", file=sys.stderr)
    import traceback
    traceback.print_exc(file=sys.stderr)
    # Define dummy classes so imports don't fail completely
    class Base:
        pass
    async def get_db():
        yield None
    engine = None
    AsyncSessionLocal = None
