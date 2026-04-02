"""Simple RQ worker launcher for UpGridOracle.

Run this in the project root to start a worker listening on the `default`
queue. Requires a running Redis instance (default: redis://localhost:6379/0).

Example:
    .venv\Scripts\python.exe worker.py
"""
import os
from redis import Redis
from rq import Worker, Queue, Connection


def main():
    redis_url = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    conn = Redis.from_url(redis_url)
    with Connection(conn):
        qs = [Queue("default")]
        worker = Worker(qs)
        print(f"Starting RQ worker listening on {redis_url} (queues: default)")
        worker.work()


if __name__ == "__main__":
    main()
