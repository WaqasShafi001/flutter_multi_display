# Changelog

## 0.0.1
- Initial release of `flutter_multi_display`.
- Features:
  - Multi-display support for Android (up to 3 displays).
  - Shared state management with `SharedState` and `flutter_bloc` integration.
  - Port-based display sorting.
  - State persistence and reactive updates.
- Example app with login UI, customer display, and ads display.

## 0.0.2
- Updated LICENSE file with correct MIT license details.

## 0.0.3
- **Enhanced Example App**
  - Rebuilt complete example in `example/lib/` using structured architecture:
    - `apps/` for `MainApp`, `CustomerApp`, and `AdsApp`.
    - `state/` for `UserState` and `HeightState` shared state management.
    - `pages/` for modular screen UI (login, home, height input, etc.).
  - Updated `main.dart` with three proper entrypoints: `main`, `screen1Main`, and `screen2Main`.
  - Improved example readability and real-world usability for multi-display projects.
  - Optimized code to reflect best practices for `FlutterMultiDisplay().setupMultiDisplay(...)`.