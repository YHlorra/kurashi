# kurashi (暮らし)

Android + iOS app — Todo +Periodic Reminders + Fridge. Lunar-calendar aware, local-first, minimal Helvetica aesthetic.

![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

## Overview

Three tabs, one local database, zero cloud:

| Tab | What it does |
|-----|-------------|
| **Todo** | Today's agenda, habits, subscription anchors |
| **Subscription** | Festivals, birthdays, bills, custom recurring reminders — all lunar-calendar native |
| **Fridge** | Food in, food out, expiry tracking, restock list, change history |

Built for **Chinese users** who care about lunar dates. No accounts, no tracking, no ads.

## Tech Stack

- **Flutter** 3.41.x · Dart 3.12+
- **Riverpod** 2.x (code-gen) — state management
- **go_router** + StatefulShellRoute — 3-tab navigation with per-tab state preservation
- **isar_plus** — local database (community fork of Isar)
- **lunar** (6tail) — Chinese lunar calendar (solar↔lunar conversion, lunar birthdays/festivals)
- **flutter_local_notifications** + **workmanager** — scheduled reminders
- **share_plus** — JSON export & system share

## Architecture

```
lib/
├── app.dart                      # Root widget
├── main.dart                     # Entry point (warms up Isar before runApp)
├── core/                         # Pure infrastructure — depends on no feature/
│   ├── database/                 # Isar provider + schemas
│   ├── designsystem/             # Colors, theme, icons, fields, segmented control
│   ├── lunar/                    # Lunar service + presets
│   ├── navigation/               # go_router config
│   └── notifications/            # Notification scheduler + background worker
├── data/
│   ├── models/                   # Isar @collection entities
│   └── repositories/             # Abstract interfaces + Fake / Isar implementations
└── feature/
    ├── todo/                     # Todo + habits
    ├── subscription/             # Festivals / birthdays / bills / custom
    └── fridge/                   # Food inventory + change log + shopping list
```

**Repository pattern**: UI depends only on abstract repository interfaces (`FridgeRepository`, `TodoRepository`, etc.). Swapping Fake → Isar is a one-line provider override — UI code doesn't move.

## Getting Prerequisites

```bash
# Install Flutter 3.41.x — https://docs.flutter.dev/get-started/install

# Verify
flutter doctor
```

## Build & Run

```bash
# Install dependencies
flutter pub get

# Generate Isar collection code (required after adding new collections)
dart run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze

# Run tests
flutter test

# Run on Android emulator
flutter run -d <android-emulator>

# Run on iOS simulator
flutter run -d <ios-simulator>
```

### Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Project Structure

- `android/` — Android platform code
- `ios/` — iOS platform code
- `web/` — Web placeholder (for `flutter run -d chrome` preview)
- `windows/` — Windows placeholder
- `assets/` — App icons, splash images, fonts (Inter · JetBrains Mono · Noto Sans SC)
- `test/` — Unit & widget tests

## Known Constraints

- **Android + iOS only** — no desktop or web targets in v1
- **Local storage only** — no cloud sync, no accounts, no collaboration
- **Lunar-native** — solar↔lunar conversion, lunar birthdays, lunar festivals
- **Isar write policy** — all mutations go through `isar.write(() { ... })`

## License

[MIT](LICENSE)
