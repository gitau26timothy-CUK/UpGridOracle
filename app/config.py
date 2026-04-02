from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    database_url: str = "sqlite+aiosqlite:///./upgridoracle.db"  # Default to SQLite
    epra_alpha: float = 0.4
    epra_beta: float = 0.35
    epra_gamma: float = 0.25
    settlement_interval_minutes: int = 15
    base_rate_kes: float = 22.0

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False)

try:
    settings = Settings()
except Exception as e:
    print(f"Warning: Error loading settings: {e}")
    print("Using default settings")
    settings = Settings()