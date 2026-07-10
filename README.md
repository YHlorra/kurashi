<a id="readme-top"></a>

**[English](README.md) | [中文](README.zh-CN.md)**

<br />
<div align="center">
  <h3 align="center">kurashi (暮らし)</h3>
  <p align="center">
    Todo + Periodic Reminders + Fridge — lunar-calendar aware, local-first, Android + iOS.
    <br />
    Built for personal daily life. No accounts, no cloud, no ads.
    <br />
    <br />
    <a href="#getting-started">Get Started</a>
    ·
    <a href="#usage">Usage</a>
    ·
    <a href="https://github.com/kurashi-app/kurashi/issues">Report Issue</a>
  </p>
</div>

<details>
<summary>Table of Contents</summary>
<ol>
<li><a href="#about-the-project">About The Project</a></li>
<li><a href="#built-with">Built With</a></li>
<li><a href="#getting-started">Getting Started</a>
<ul>
<li><a href="#prerequisites">Prerequisites</a></li>
<li><a href="#installation">Installation</a></li>
</ul>
</li>
<li><a href="#usage">Usage</a>
<ul>
<li><a href="#todo">Today's Agenda</a></li>
<li><a href="#subscription">Periodic Reminders</a></li>
<li><a href="#fridge">Fridge Management</a></li>
</ul>
</li>
<li><a href="#testing">Testing</a></li>
<li><a href="#deployment">Deployment</a></li>
<li><a href="#roadmap">Roadmap</a></li>
<li><a href="#contributing">Contributing</a></li>
<li><a href="#license">License</a></li>
<li><a href="#acknowledgments">Acknowledgments</a></li>
</ol>
</details>

## About The Project

**kurashi** (暮らし — "daily living" in Japanese) is a personal life management app for **Android + iOS**. Three tabs, one local database, zero cloud.

| Tab | What you get |
|-----|-------------|
| **Today** | Daily agenda blending todos, habits, and subscription anchors in one scroll |
| **Subscription** | Recurring reminders for festivals, birthdays, bills, and custom intervals — all lunar-calendar native |
| **Fridge** | Food inventory with expiry tracking, smart restock suggestions, full change history (JSON-exportable) |

Designed and built for **personal use**. The developer maintains it to solve their own daily friction — lunar dates for Chinese holidays, no subscription tracking in existing apps, food waste from forgotten fridge items. Everything local-first: no accounts, no tracking, no ads, no collaboration. Just your data on your device.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [![Flutter][Flutter-shield]][Flutter-url]
* [![Dart][Dart-shield]][Dart-url]
* [![Riverpod][Riverpod-shield]][Riverpod-url]
* [![Isar][Isar-shield]][Isar-url]
* [![Lunar][Lunar-shield]][Lunar-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Prerequisites

* Flutter 3.41.x (stable channel) — [Install guide](https://docs.flutter.dev/get-started/install)
* Dart 3.12+
* Android Studio / Xcode (for platform builds)
* A physical device or emulator

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/kurashi-app/kurashi.git
   cd kurashi
   ```
2. Install dependencies
   ```sh
   flutter pub get
   ```
3. Run code generation (required for Isar collections and Riverpod providers)
   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run on a connected device or emulator
   ```sh
   flutter run -d <device-id>
   ```

List available devices:
```sh
flutter devices
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

### Today

The default screen. Combines three data sources into one chronologically sorted list:

* **Todos** — tasks with optional due dates and times
* **Habits** — weekly frequency goals (e.g., "read 30 min, 3x/week") with checkin
* **Subscription anchors** — upcoming reminders from the Subscription tab, surfaced when relevant

Completed todos disappear from today's view immediately.

### Subscription

Create recurring reminders for anything that repeats:

| Type | Examples | Calendar |
|------|----------|----------|
| Chinese festivals | Spring Festival, Mid-Autumn, Qingming | Lunar |
| Western festivals | Mother's Day, Thanksgiving | Solar |
| Birthdays | "Dad's birthday, lunar 7/8, remind 3 days before" | Lunar or Solar |
| Bills | "Credit card payment, 5th of each month" | Solar |
| Custom | "Change water filter every 180 days" | Smart interval |
| Home | "Replace smoke alarm battery yearly" | Solar |
| Pets | "Heartworm prevention, every 30 days" | Solar |
| Documents | "Driver's license renewal, 90 days before" | Solar |
| Health | "Annual checkup", "Dental cleaning every 6 months" | Solar |
| Vehicle | "Oil change yearly", "Insurance renewal" | Solar |

Active reminders are sorted by days-until and shown in the Today tab.

### Fridge

Manage food inventory and reduce waste:

* **Add items** — with name, quantity, expiry date, and tag (vegetable / fruit / meat / custom)
* **Expiry tracking** — items nearing expiry surface in the restock list
* **Smart restock** — items with restock enabled auto-suggest when stock runs low (custom per-item threshold)
* **Change history** — every add / edit / delete / undo is logged with before/after values. Export to JSON for analysis
* **Retention policy** — set log retention to 30 days, 90 days, or forever

#### Build Release APK

```sh
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Install on a device:
```sh
adb install build/app/outputs/flutter-apk/app-release.apk
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Testing

```sh
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

89 unit & widget tests covering repository behavior, lunar calendar calculations, notification scheduling, and widget rendering.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Deployment

This project uses [GitHub Actions](.github/workflows/build.yml) for CI:

* **Static analysis** + **test suite** on every push and PR
* **Release APK** built automatically after tests pass (artifact attached to the run)

The workflow uses Flutter 4.41.4 on `ubuntu-latest` with Java 17.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Roadmap

- [x] Today tab with todos + habits + subscription anchors
- [x] Subscription reminders (lunar and solar)
- [x] Fridge inventory with expiry tracking
- [x] Change log with JSON export
- [x] Restock suggestions
- [x] Retention policy
- [ ] JSON import (restore from export)
- [ ] Multi-batch expiry per item (e.g., 3 eggs used one by one)
- [ ] Theming beyond monochrome
- [ ] Widget / home screen quick-add

Roadmap reflects the developer's personal needs. New features are prioritized by daily friction, not popularity.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

This is a **personal project** — the developer builds it for their own daily life. Issues and suggestions are welcome, but features are prioritized by personal need.

If something doesn't work for you:

1. Check if it's a personal-preference mismatch (the app is opinionated by design)
2. Search existing issues
3. Open a new issue with: what you expected, what happened, steps to reproduce

Pull requests that align with the app's direction (local-first, minimal, personal-scale) may be considered. Large architectural changes or social/cloud features likely won't fit.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the MIT License. See `LICENSE` for details.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments

* [lunar](https://github.com/6tail/lunar-flutter) — Chinese lunar calendar calculations
* [IconPark](https://iconpark.oceanengine.com/) — outline icon set
* [Inter](https://rsms.me/inter/) / [JetBrains Mono](https://www.jetbrains.com/lp/mono/) / [Noto Sans SC](https://fonts.google.com/noto) — bundled typefaces

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- Shields -->
[Flutter-shield]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[Flutter-url]: https://flutter.dev
[Dart-shield]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[Dart-url]: https://dart.dev
[Riverpod-shield]: https://img.shields.io/badge/Riverpod-0F52BA?style=for-the-badge&logo=flutter&logoColor=white
[Riverpod-url]: https://riverpod.dev
[Isar-shield]: https://img.shields.io/badge/Isar-3DDC84?style=for-the-badge&logo=dart&logoColor=white
[Isar-url]: https://isar.dev
[Lunar-shield]: https://img.shields.io/badge/Lunar_Calendar-8B0000?style=for-the-badge&logoColor=white
[Lunar-url]: https://github.com/6tail/lunar-flutter
[license-shield]: https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge
[license-url]: ./LICENSE
<!-- TODO: Replace OWNER/REPO after setting up GitHub remote -->
<!-- [version-shield]: https://img.shields.io/github/v/tag/OWNER/REPO?style=for-the-badge -->
<!-- [version-url]: https://github.com/OWNER/REPO/releases -->
<!-- [last-commit-shield]: https://img.shields.io/github/last-commit/OWNER/REPO?style=for-the-badge -->
<!-- [last-commit-url]: https://github.com/OWNER/REPO/commits/main -->
<!-- [ci-shield]: https://img.shields.io/github/actions/workflow/status/OWNER/REPO/build.yml?style=for-the-badge -->
<!-- [ci-url]: https://github.com/OWNER/REPO/actions -->
