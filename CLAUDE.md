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
- **Local storage**: `hive_ce_flutter` (stores papers as JSON maps in a Box) + `shared_preferences` (read IDs, last fetch time)
- **Networking**: `http` package
- **Models**: `freezed` + `json_serializable` (generates `.freezed.dart` and `.g.dart`)
- **Animations**: `flutter_animate`
- **Fonts**: `google_fonts`

### Project structure
```
client/
  lib/
    main.dart                        # Entry point — inits Hive, StorageService, ProviderScope
    core/
      constants/
        app_colors.dart
        app_constants.dart           # URLs, query, fetch count limits, Hive box name
      theme/
        app_theme.dart
    models/
      paper.dart                     # @freezed Paper model (no @HiveType — stored as JSON)
      paper.freezed.dart             # generated
      paper.g.dart                   # generated
    providers/
      providers.dart                 # All Riverpod providers: papers, readStatus, theme, fetchCount
    services/
      storage_service.dart           # Hive box (papers as JSON) + SharedPreferences
      backend_service.dart           # HTTP client for server API
    ui/
      screens/
        home_screen.dart
      widgets/
        category_chip.dart
        empty_state.dart
        fetch_controls.dart
        paper_card.dart
        paper_detail_sheet.dart
        papers_list.dart
        status_badge.dart
  test/
    models/
      paper_test.dart
    services/
      xml_parser_test.dart
      arxiv_service_test.dart
    providers/
      papers_notifier_test.dart
```

### Key decisions / gotchas

#### hive_ce instead of hive
`hive` / `hive_generator` don't support `analyzer >=7.0.0` which `freezed ^2.5.x` and `riverpod_generator` require. Replaced with `hive_ce_flutter` + `hive_ce_generator` (community fork). Correct import:
```dart
import 'package:hive_ce_flutter/hive_flutter.dart'; // NOT hive_ce_flutter.dart
```

#### No @HiveType on Paper
Mixing `@freezed` and `@HiveType` on the same class causes build_runner errors. `Paper` is stored as a JSON map (`paper.toJson()`) in the Hive box and deserialized with `Paper.fromJson()`. No adapter registration needed in `main.dart`.

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
Uses `mocktail` for mocks. Mock `ArxivService` and `StorageService`, then inject via `ProviderContainer` overrides:
```dart
final container = ProviderContainer(overrides: [
  arxivServiceProvider.overrideWithValue(mockArxiv),
  storageServiceProvider.overrideWithValue(mockStorage),
]);
```

---

## Server (FastAPI)

### Tech stack
- **Python** + **FastAPI**
- Deployed via **Docker** on **Render**

### Project structure
```
server/
  app/
    routers/       # API route handlers
    agents/        # AI agent logic
  Dockerfile
  render.yaml
  requirements.txt
```

### Running the server
```bash
cd server
pip install -r requirements.txt
uvicorn app.main:app --reload
```
