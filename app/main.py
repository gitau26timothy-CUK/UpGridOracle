"""
UpGridOracle Energy Pricing API
Multi-tiered pricing with EPRA regulatory adjustments
"""
from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from app.routers import rates_router, pricing_router, federation_router
from app.database import engine, Base

# Create FastAPI app
@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    try:
        yield
    finally:
        await engine.dispose()


app = FastAPI(
    title="UpGridOracle API",
    description="Energy consumption pricing with multi-tier support and EPRA adjustments",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS middleware (allow frontend calls)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to specific domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Health check
@app.get("/health", tags=["Health"])
async def health_check():
    return {"status": "healthy", "service": "UpGridOracle API"}


# Include routers
app.include_router(rates_router)
app.include_router(pricing_router)
app.include_router(federation_router)


# Lifespan handler manages startup (create tables) and shutdown (dispose engine)


# Root endpoint
@app.get("/", tags=["Root"])
async def root():
    return {
        "message": "Welcome to UpGridOracle Energy Pricing API",
        "docs": "/docs",
        "endpoints": {
            "rates": "/api/rates",
            "pricing": "/api/consumption",
            "federation": "/api/federation",
        },
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
