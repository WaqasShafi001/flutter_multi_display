# Contributing to flutter_multi_display

Thank you for considering contributing to `flutter_multi_display`! We welcome bug fixes, feature additions, and documentation improvements.

## How to Contribute

1. **Fork the Repository**:
   - Fork [flutter_multi_display](https://github.com/WaqasShafi001/flutter_multi_display).
2. **Create a Feature Branch**:
   - `git checkout -b feature/my-feature`
3. **Make Changes**:
   - Follow the coding style in the project.
   - Update tests in `test/` if applicable.
   - Update `example/` to reflect new features.
   - Update `README.md` and `CHANGELOG.md`.
4. **Run Tests**:
   - Run `flutter test` to ensure all tests pass.
   - Test on an Android device with multiple displays (e.g., RK3588).
5. **Commit Changes**:
   - Use clear commit messages: `git commit -m 'Add my feature'`.
6. **Push and Open a Pull Request**:
   - Push: `git push origin feature/my-feature`.
   - Open a PR with a clear description and link to related issues.
7. **Code Review**:
   - All PRs require approval from @WaqasShafi001.
   - Ensure tests pass and CI checks are green.

## Code Style
- Follow [Flutter style guidelines](https://dart.dev/guides/language/effective-dart/style).
- Use `dart format` to format code.

## Testing
- Add unit tests in `test/` for new features.
- Test on Android devices with multiple displays (primary + VGA/HDMI).
- Include logs from `flutter run --verbose` in bug reports.

## Reporting Issues
- Use the [issue templates](.github/ISSUE_TEMPLATE) for bug reports or feature requests.
- Include Flutter/Dart version, platform, and logs.

Thank you for helping improve `flutter_multi_display`!