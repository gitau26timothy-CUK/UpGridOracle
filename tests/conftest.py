import os
import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient


ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))


@pytest.fixture(scope="session")
def db_url(tmp_path_factory) -> str:
    db_path = tmp_path_factory.mktemp("db") / "test.db"
    return f"sqlite+aiosqlite:///{db_path}"


@pytest.fixture(scope="session")
def app(db_url):
    os.environ["DATABASE_URL"] = db_url
    from app.main import app as fastapi_app

    return fastapi_app


@pytest.fixture
def client(app):
    with TestClient(app) as test_client:
        yield test_client

