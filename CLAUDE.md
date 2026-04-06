# ArXiv Research — Claude Context

## What this app does
Personal ML/AI research paper reader. Fetches papers from the ArXiv API (cs.AI, cs.LG, cs.CV, cs.CL), caches them locally, and lets the user mark papers as read.

## Expectations
- Always write unit tests for new functionality
- Update existing tests when modifying behavior
- Run the full test suite before finishing
- Ensure no lint or type errors remain


## Code Style
- Prefer simple, readable clean solutions over clever ones
- Follow existing patterns in the codebase

## Tech stack
- **Flutter** + **Dart** (>=3.3.0)
- **State management**: `flutter_riverpod` (StateNotifier pattern, no code-gen providers)
- **Local storage**: `hive_ce_flutter` (stores papers as JSON maps in a Box) + `shared_preferences` (read IDs, last fetch time)
- **Networking**: `http` package hitting `https://export.arxiv.org/api/query`
- **Models**: `freezed` + `json_serializable` (generates `.freezed.dart` and `.g.dart`)
- **Animations**: `flutter_animate`
- **Fonts**: `google_fonts`

## Project structure
```
lib/
  main.dart                        # Entry point — inits Hive, StorageService, ProviderScope
  core/
    constants/
      app_colors.dart
      app_constants.dart           # URLs, query, fetch count limits, Hive box name
    theme/
      app_theme.dart
    utils/
      xml_parser.dart              # Parses ArXiv Atom/XML responses into Paper objects
  models/
    paper.dart                     # @freezed Paper model (no @HiveType — stored as JSON)
    paper.freezed.dart             # generated
    paper.g.dart                   # generated
  providers/
    providers.dart                 # All Riverpod providers: papers, readStatus, theme, fetchCount
  services/
    arxiv_service.dart             # HTTP fetch + ArxivException
    storage_service.dart           # Hive box (papers as JSON) + SharedPreferences
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
```

## Key decisions / gotchas

### hive_ce instead of hive
`hive` / `hive_generator` don't support `analyzer >=7.0.0` which `freezed ^2.5.x` and `riverpod_generator` require. Replaced with `hive_ce_flutter` + `hive_ce_generator` (community fork). Correct import:
```dart
import 'package:hive_ce_flutter/hive_flutter.dart'; // NOT hive_ce_flutter.dart
```

### No @HiveType on Paper
Mixing `@freezed` and `@HiveType` on the same class causes build_runner errors. `Paper` is stored as a JSON map (`paper.toJson()`) in the Hive box and deserialized with `Paper.fromJson()`. No adapter registration needed in `main.dart`.

### Code generation
After any model/provider changes run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### ArXiv search query
Hardcoded in `AppConstants.searchQuery`:
```
cat:cs.AI OR cat:cs.LG OR cat:cs.CV OR cat:cs.CL
```

### Fetch count
- Default: 25, Min: 5, Max: 100
- Controlled via `fetchCountProvider` (StateProvider<int>)

## Running the app
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Testing

### Run all tests
```bash
flutter test
```

### Run a specific test file
```bash
flutter test test/models/paper_test.dart
```

### Run with verbose output
```bash
flutter test --reporter expanded
```

### Test structure
```
test/
  models/
    paper_test.dart              # Unit tests for Paper model (shortId, formattedDate, authorsPreview, JSON round-trip)
  services/
    xml_parser_test.dart         # Unit tests for XmlParser (feed parsing, PDF URL derivation, whitespace)
    arxiv_service_test.dart      # Unit tests for ArxivService with mocked http.Client
  providers/
    papers_notifier_test.dart    # Unit tests for PapersNotifier and ReadStatusNotifier with mocked services
```

### Mocking
Uses `mocktail` for mocks. Mock `ArxivService` and `StorageService`, then inject via `ProviderContainer` overrides:
```dart
final container = ProviderContainer(overrides: [
  arxivServiceProvider.overrideWithValue(mockArxiv),
  storageServiceProvider.overrideWithValue(mockStorage),
]);
```
