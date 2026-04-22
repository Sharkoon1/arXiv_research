# ArXiv Research — Claude Context

## What this app does
Personal ML/AI research paper reader. Monorepo with a Flutter mobile client and a FastAPI backend server.

## Repository structure
```
client/    # Flutter mobile app
server/    # Python FastAPI backend
```

## Expectations
- Always write unit tests for new functionality
- Update existing tests when modifying behavior
- Run the full test suite before finishing
- Ensure no lint or type errors remain

## Code Style
- Prefer simple, readable clean solutions over clever ones
- Follow existing patterns in the codebase

---

## Client (Flutter)

### Tech stack
- **Flutter** + **Dart** (>=3.3.0)
- **State management**: `flutter_riverpod` (StateNotifier pattern, no code-gen providers)
- **Local storage**: `shared_preferences` (read IDs). Papers themselves are fetched fresh from the backend and held in-memory via Riverpod.
- **Networking**: `http` package
- **Models**: `freezed` + `json_serializable` (generates `.freezed.dart` and `.g.dart`)
- **Animations**: `flutter_animate`
- **Fonts**: `google_fonts`

### Project structure
```
client/
  lib/
    main.dart                        # Entry point — ProviderScope + MaterialApp
    core/
      constants/
        app_colors.dart
        app_constants.dart           # Backend URL, fetch count limits, categories
      theme/
        app_theme.dart
      utils/
        api_exception.dart           # Typed exceptions for backend errors
    models/
      paper.dart                     # @freezed Paper model (JSON-serializable)
      news_item.dart                 # @freezed NewsItem model
      report.dart                    # @freezed Report model
      *.freezed.dart, *.g.dart       # generated
    providers/
      providers.dart                 # All Riverpod providers: papers, readStatus, theme, fetchCount
    services/
      storage_service.dart           # SharedPreferences wrapper (read IDs)
      papers_service.dart            # HTTP client for papers endpoints
      news_service.dart              # HTTP client for news endpoints
      reports_service.dart           # HTTP client for report endpoints
    ui/
      screens/
        home_screen.dart
      widgets/
        category_chip.dart
        empty_state.dart
        fetch_controls.dart
        news_card.dart
        paper_card.dart
        paper_detail_sheet.dart
        papers_list.dart
        status_badge.dart
  test/
    models/
      paper_test.dart
    services/
      xml_parser_test.dart
      papers_service_test.dart
      news_service_test.dart
      reports_service_test.dart
      storage_service_test.dart
    providers/
      papers_notifier_test.dart
```

### Key decisions / gotchas

#### Code generation
After any model/provider changes run:
```bash
cd client && dart run build_runner build --delete-conflicting-outputs
```

### Running the client
```bash
cd client
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Testing the client
```bash
cd client && flutter test
cd client && flutter test --reporter expanded
```

### Mocking
Uses `mocktail` for mocks. Mock the HTTP services (`PapersService`, `NewsService`, `ReportsService`) and `StorageService`, then inject via `ProviderContainer` overrides:
```dart
final container = ProviderContainer(overrides: [
  papersServiceProvider.overrideWithValue(mockPapers),
  storageServiceProvider.overrideWithValue(mockStorage),
]);
```

---

## Server (FastAPI)

### Tech stack
- **Python 3.12** + **FastAPI**
- **Database**: SQLAlchemy (async) + Alembic migrations. SQLite for local/tests, Postgres in prod.
- **Cache**: Redis (optional — falls back to DB if unavailable)
- **Validation**: Pydantic v2 (`pydantic-settings` for config)
- **HTTP**: `httpx` (async)
- **Testing**: `pytest` + `pytest-asyncio`
- **Linting**: `ruff`
- Deployed via **Docker** on **Render**

### Project structure
```
server/
  app/
    main.py                          # FastAPI app factory, router wiring
    dependencies.py                  # FastAPI Depends() factories
    core/
      config.py                      # Settings (pydantic-settings)
      database.py                    # SQLAlchemy engine / session factory
      redis_client.py                # RedisCache with DB fallback
      security.py                    # API key verification
      exceptions.py                  # Domain exceptions (e.g. ReportNotFound)
    models/                          # SQLAlchemy ORM models (Paper, NewsItem, Report)
    schemas/                         # Pydantic request/response schemas
    repositories/                    # DB access layer (one per model)
    services/                        # Business logic (collect, paper, news, report)
    routers/                         # API route handlers (collect, papers, news, reports)
    agents/                          # AI agent wrappers (papers, news, ranking, summarize)
  tests/
    conftest.py                      # Async DB fixtures, FakeRedisCache, auth client
    health_test.py
    repositories/                    # Repository unit tests
    routers/                         # Router integration tests
    services/                        # Service unit tests
  Dockerfile                         # Python 3.12-slim base
  docker-compose.yml
  render.yaml
  pyproject.toml                     # pytest + ruff config
  requirements.txt
```

### Running the server
```bash
cd server
python3.12 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/uvicorn app.main:app --reload
```

### Testing the server
```bash
make server-test
make server-lint      # ruff
```

### Key decisions / gotchas
- **Dev/prod parity**: the venv must use Python 3.12 (matches the Dockerfile). `X | None` type hints require 3.10+ at runtime.
- **Redis is optional**: `RedisCache` transparently falls back to the DB when the client raises. Tests use `FakeRedisCache` from [tests/conftest.py](server/tests/conftest.py).
- **Layered architecture**: routers → services → repositories → models. Keep business logic out of routers.
