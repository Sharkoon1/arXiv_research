# Start both backend and frontend
start:
	cd server && .venv/bin/uvicorn app.main:app --reload & cd client && flutter run --dart-define=API_KEY=$(API_KEY)

# Start backend + iOS Simulator + frontend on the simulator in one go
# API_KEY is read from server/.env automatically; override with `make start-sim API_KEY=...`
API_KEY ?= $(shell grep -E '^APP_API_KEY=' server/.env | cut -d= -f2-)

start-sim: client-build
	@open -a Simulator
	@sleep 2
	@lsof -ti:8000 | xargs kill 2>/dev/null || true
	@bash -c 'trap "lsof -ti:8000 | xargs kill 2>/dev/null" EXIT INT TERM; (cd server && .venv/bin/uvicorn app.main:app --reload) & cd client && flutter run -d "iPhone 17" --dart-define=API_KEY=$(API_KEY)'

# Client (Flutter)
client-run:
	cd client && flutter run --dart-define=API_KEY=$(API_KEY)

client-test:
	cd client && flutter test

client-build:
	cd client && dart run build_runner build --delete-conflicting-outputs

client-get:
	cd client && flutter pub get

client-clean:
	cd client && flutter clean && flutter pub get

# Server (FastAPI)
server-run:
	cd server && .venv/bin/uvicorn app.main:app --reload

server-test:
	cd server && .venv/bin/pytest

server-install:
	cd server && python3 -m venv .venv && .venv/bin/pip install -r requirements.txt

server-docker-build:
	cd server && docker build -t arxiv-research-api .

server-docker-run:
	cd server && docker run -p 8000:8000 --env-file .env arxiv-research-api
