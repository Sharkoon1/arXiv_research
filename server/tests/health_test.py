from httpx import AsyncClient


async def test_health_ok(client: AsyncClient):
    resp = await client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


async def test_missing_api_key_rejected(client: AsyncClient):
    resp = await client.get("/health", headers={"X-Api-Key": "wrong"})
    assert resp.status_code == 401
