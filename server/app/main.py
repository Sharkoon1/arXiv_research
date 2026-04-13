from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from app.database import init_db
from app.auth import verify_api_key
from app.routers import collect, papers, news, reports, workflow_callback


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield


app = FastAPI(title="ArXiv Research API", lifespan=lifespan, dependencies=[Depends(verify_api_key)])

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(collect.router)
app.include_router(papers.router)
app.include_router(news.router)
app.include_router(reports.router)

# Callback router has no auth — Azure posts to it directly
callback_app = FastAPI()
callback_app.include_router(workflow_callback.router)
app.mount("/internal", callback_app)


@app.get("/health")
async def health():
    return {"status": "ok"}
