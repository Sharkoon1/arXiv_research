# AI Research

A personal AI research briefing app. Collects the latest AI/ML papers and news via Azure AI Foundry agents, generates a summarized briefing, and presents everything in a clean mobile interface.

## Architecture

```
client/          Flutter mobile app (iOS)
server/          FastAPI backend (Python)
```

### Backend

- **FastAPI** with async PostgreSQL (SQLAlchemy)
- **Azure AI Foundry** agents for paper retrieval, news collection, and briefing summarization
- API key authentication via `X-Api-Key` header
- Deployed on **Render**

### Client

- **Flutter** with Riverpod state management
- Tabs for Papers and News with collapsible controls
- Markdown-rendered AI briefing with expand/collapse
- Report history with random scientific names
- Dark/light theme

## Setup

### Backend

```bash
cd server
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

Create `server/.env`:

```
DATABASE_URL=postgresql+asyncpg://...
AZURE_PROJECT_ENDPOINT=https://...
AZURE_API_KEY=...
AZURE_API_VERSION=2025-11-15-preview
APP_API_KEY=...
```

### Client

```bash
cd client
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Running

```bash
# Both backend + frontend
make start

# Or separately
make server-run
make client-run
```

### Release build (iOS device)

```bash
cd client
flutter run --release --dart-define=API_KEY=your-api-key
```

## Agents

| Agent | Purpose |
|-------|---------|
| `research-agent-papers` | Searches for recent AI/ML research papers |
| `research-agent-news` | Collects latest AI industry news |
| `research-agent-summarize` | Generates a markdown briefing from collected items |

Agents are managed in [Azure AI Foundry](https://ai.azure.com) and called via the OpenAI Responses protocol.
