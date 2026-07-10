**[中文](README.zh-CN.md) | [English](README.en.md)**

<h1 align="center">kurashi</h1>

<p align="center">
  暮らし — Todo + Periodic Reminders + Fridge<br>
  Lunar-calendar native · Local-first · Android + iOS
</p>

<p align="center">
  <a href="https://github.com/YHlorra/kurashi/actions"><img src="https://img.shields.io/github/actions/workflow/status/YHlorra/kurashi/build.yml?logo=github&label=Build" alt="Build"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-black" alt="MIT License"></a>
</p>



- [What it is](#what-it-is)
- [Why I built this](#why-i-built-this)
- [Quick start](#quick-start)
- [Features](#features)
- [Known limits](#known-limits)
- [Testing](#testing)
- [Roadmap](#roadmap)
- [About the author](#about-the-author)
- [License](#license)

## What it is

**kurashi** (Japanese: 暮らし, "daily living") is a life management app for **Android + iOS**. Three tabs, one local database, zero cloud sync.

| Tab | What it does |
|-----|-------------|
| **Today** | Merges todos, habit check-ins, and upcoming reminders into one chronological list |
| **Subscription** | Create recurring reminders for festivals, birthdays, bills, and custom intervals — native lunar + solar calendar support |
| **Fridge** | Food inventory with expiry tracking, smart restock suggestions, full change log with JSON export |

> [!NOTE]
> All data lives on your device. No accounts, no ads, no tracking, no collaboration. Your data stays yours.

## Why I built this

Mainstream calendar apps are either bloated with moon-phase horoscope ads, or lack lunar calendar support. Calendar apps can't handle reminders like "lunar birthday, notify 3 days before." Food goes bad in the fridge because nobody tracks it.

kurashi exists to fix these three daily frictions — a clean, opinionated tool that works at your pace. Feature priority is determined by real daily pain, not popularity.

## Quick start

### Prerequisites

- Flutter 3.41.x (stable) — [Install guide](https://docs.flutter.dev/get-started/install)
- Dart 3.12+
- Android Studio or Xcode (for platform builds)
- A physical device or emulator

### Run locally

```sh
git clone https://github.com/YHlorra/kurashi.git
cd kurashi
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d <device-id>
```

> [!NOTE]
> `build_runner` is required — both Isar code generation and Riverpod provider generation depend on it. After the first run, use `dart run build_runner watch` for incremental rebuilds.

List available devices:

```sh
flutter devices
```

### Build for release

```sh
# Release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# iOS (no codesign, simulator only)
flutter build ios --debug --no-codesign
```

## Features

### Today

Combines three data sources into one chronologically sorted scrolling list:

- **Todos** — tasks with optional due dates and times (down to HH:mm precision)
- **Habits** — weekly frequency goals (e.g., "read 30 min, 3x/week") with check-in tracking
- **Subscription anchors** — upcoming reminders surface in Today when relevant

Completed items disappear from Today's view immediately.

### Subscription

Create recurring reminders for anything that repeats:

| Type | Examples | Calendar |
|------|----------|----------|
| Chinese festivals | Spring Festival, Mid-Autumn, Qingming | Lunar |
| Western festivals | Mother's Day, Thanksgiving | Solar |
| Birthdays | "Dad's birthday, lunar 7/8, remind 3 days before" | Lunar or Solar |
| Bills | "Credit card payment, 5th of each month" | Solar |
| Custom | "Change water filter every 180 days" | Smart interval |

Includes Home / Pets / Documents / Health / Vehicle category templates. Active reminders sorted by days-until and surfaced in Today.

### Fridge

Food inventory management to reduce waste:

- **Add items** — name, quantity, expiry date, tag (vegetable / meat / fruit / custom)
- **Expiry tracking** — items nearing expiry auto-surface in the restock list
- **Smart restock** — auto-generates shopping list based on per-item stock threshold
- **Change log** — every add / edit / delete / undo logged with before/after values. JSON-exportable
- **Retention policy** — configure log retention: 30 days, 90 days, or forever

### Architecture

Feature-first directory structure with abstract Repository layer between UI and database:

```
lib/
├── app.dart                      # MaterialApp root widget
├── main.dart                     # Entry: warm up Isar + init notifications
├── core/                         # Infrastructure (no feature deps)
│   ├── database/                 # Isar provider + schema
│   ├── designsystem/             # Theme, icons, shared components
│   ├── lunar/                    # Lunar service + festival presets
│   ├── navigation/               # go_router
│   └── notifications/            # Notification scheduler + workmanager
├── data/
│   ├── models/                   # Isar collections
│   └── repositories/             # Abstract interfaces + Fake/Isar impls
└── feature/
    ├── todo/                     # Today tab
    ├── subscription/             # Subscription tab
    └── fridge/                   # Fridge tab
```

The Repository abstraction makes swapping Fake (in-memory mock) → Isar (real persistence) a one-liner provider change — UI layer untouched.

## Known limits

- ✅ Android + iOS on physical devices
- ✅ Lunar + solar calendar dual-track
- ✅ Local notifications + workmanager background keep-alive
- ✅ JSON export
- ❌ No Web / desktop (Isar_plus supports Android/iOS only)
- ❌ No cloud sync / multi-device
- ❌ No JSON import (export exists, import not yet implemented)
- ❌ No multi-batch expiry (e.g., 3 eggs used one by one)
- ❌ No home screen widgets / quick-add

## Testing

14 test files covering repository behavior, lunar calendar calculations, notification scheduling, and widget rendering.

```sh
# Run all tests
flutter test

# With coverage
flutter test --coverage

# Static analysis
flutter analyze
```

CI runs on GitHub Actions:

- Every push / PR triggers analyze + format check + test
- Release APK auto-built after tests pass (artifact retained 30 days)
- PRs additionally build a Debug APK for quick verification

## Roadmap

- [x] Today tab with todos + habits + subscription anchors
- [x] Lunar + solar dual-track reminders
- [x] Fridge inventory with expiry tracking
- [x] Change log with JSON export
- [x] Smart restock suggestions
- [x] Log retention policy
- [ ] JSON import (restore from export)
- [ ] Multi-batch expiry per item
- [ ] Theming beyond monochrome
- [ ] Home screen widgets / quick-add

Roadmap reflects the developer's personal priorities, driven by daily friction.

## About the author

kurashi is a personal project built to solve daily-life frictions.

<!-- TODO: Add your name / social links -->

## License

MIT © kurashi. See [LICENSE](./LICENSE) for details.


