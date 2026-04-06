# Start both backend and frontend
start:
	cd server && .venv/bin/uvicorn app.main:app --reload & cd client && flutter run

# Client (Flutter)
client-run:
	cd client && flutter run

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

server-install:
	cd server && python3 -m venv .venv && .venv/bin/pip install -r requirements.txt

server-docker-build:
	cd server && docker build -t arxiv-research-api .

server-docker-run:
	cd server && docker run -p 8000:8000 --env-file .env arxiv-research-api
