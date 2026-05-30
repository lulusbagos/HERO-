# Contributing Guide

## Prerequisites

| Tool | Minimum version |
|---|---|
| Flutter SDK | 3.x stable |
| Dart SDK | 3.x (bundled with Flutter) |
| Android Studio / VS Code | Latest |
| Git | 2.x |

---

## Getting Started

```bash
# 1. Fork dan clone repo
git clone https://github.com/lulusbagos/HERO-.git
cd HERO-

# 2. Install dependencies
flutter pub get

# 3. Run di emulator atau device
flutter run

# 4. Run static analysis
flutter analyze

# 5. Run tests
flutter test
```

---

## Branching Strategy

```
main          ← stable production code
develop       ← integration branch, PR target
feature/<name>← new features  (e.g. feature/attendance-module)
fix/<name>    ← bug fixes      (e.g. fix/login-animation-jitter)
chore/<name>  ← tooling/config (e.g. chore/update-flutter-sdk)
```

All PRs target `develop`. `develop` is merged to `main` on release.

---

## Commit Convention

```
<type>(<scope>): <subject>

Types: feat | fix | docs | style | refactor | test | chore
Scope: auth | home | menu | attendance | leave | approval | core | app

Examples:
feat(auth): add biometric login support
fix(home): prevent null menus causing empty screen
docs(arch): update tiered approval sequence diagram
```

---

## Adding a New Feature Module

1. **Create the folder** under `lib/features/<name>/`
2. **Add pages and widgets** following the existing pattern
3. **Register the route** in `lib/app/app_routes.dart`
4. **Add to MockMenuRepository** so it appears in the menu during development
5. **Write widget tests** in `test/features/<name>/`
6. Run `flutter analyze` and `flutter test` — both must pass before PR

---

## Code Style

- Follow `flutter_lints` rules — no suppressions without justification
- Prefer `const` constructors wherever possible
- Private widget classes start with `_` only when they are file-local helpers
- Reusable widgets go in `features/<feature>/widgets/` or `shared/widgets/`
- No business logic inside `build()` methods

---

## Asset Guidelines

| Asset type | Location | Naming |
|---|---|---|
| Company images | `assets/images/` | `snake_case.png` |
| Icons (custom SVG) | `assets/icons/` | `snake_case.svg` |
| Fonts | `assets/fonts/` | `FontName-Weight.ttf` |

Always declare new assets in `pubspec.yaml` under `flutter.assets`.

---

## Pull Request Checklist

- [ ] `flutter analyze` returns no issues
- [ ] `flutter test` passes
- [ ] New feature has at least one widget test
- [ ] Code follows the folder/layer conventions in [ARCHITECTURE.md](ARCHITECTURE.md)
- [ ] PR description explains *what* and *why*
