# ArXiv Research — Setup

## 1. Install Flutter (if not already installed)

```bash
# Option A — official installer (recommended)
# Download from: https://docs.flutter.dev/get-started/install/macos

# Option B — Homebrew
brew install --cask flutter
```

Verify: `flutter doctor`

## 2. Bootstrap the project

```bash
cd /Users/mircoboddecker/Documents/Claude/arxiv_research

# Generate platform files (ios, macos, android)
flutter create . --org com.mirco

# Install dependencies
flutter pub get
```

## 3. Run

```bash
# macOS desktop (fastest for local dev)
flutter run -d macos

# iOS simulator
open -a Simulator
flutter run -d iPhone

# All available devices
flutter devices
```

## Notes

- No API key required — uses the public ArXiv Atom API
- Read/unread status is persisted via `SharedPreferences`
- The generated files (`paper.freezed.dart`, `paper.g.dart`) are already included
  — no need to run `build_runner`
