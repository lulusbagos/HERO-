# HERO — Human Enterprise Resource Operations

> Mobile application for PT INDEXIM COALINDO  
> Built with **Flutter** · Designed for multi-role HR & GA workflows

---

## About

**HERO** is a premium mobile platform that streamlines all Human Resource and General Administration processes for PT INDEXIM COALINDO. It supports tiered approval chains, role-based access, and a dynamic menu system driven entirely by a backend database — enabling administrators to add or remove features without a new app release.

---

## Latest Session Handover

This section is the quickest way to continue development after the latest UI work.

### Completed in this session

- Notification bell in Home header is now clickable and opens **Notification Center**
- Notification Center has premium card UI, clean hierarchy, and smooth tap feedback
- Notification content supports HTML rendering (`flutter_html`)
- Read vs unread notifications now use different visual states (color, border, emphasis)
- Quick Access now has professional **Edit** flow with bottom sheet menu selector
- Quick Access can be customized up to 8 menu items
- **Her Registration** color has been normalized to the same blue family as core primary menus

### Files touched

- `lib/features/home/pages/home_shell.dart`
- `pubspec.yaml`
- `pubspec.lock`

### Local run (source project)

```bash
flutter pub get
flutter run
```

### Device deploy flow used by team

```powershell
# 1) sync source to deploy project
Copy-Item "D:\4. PROJECT\6. Android\HRGA\lib\features\home\pages\home_shell.dart" "D:\4. PROJECT\13. Mobile\HERO\lib\features\home\pages\home_shell.dart" -Force

# 2) install dependencies in deploy project
Set-Location "D:\4. PROJECT\13. Mobile\HERO"
flutter pub get

# 3) run to physical Samsung device
$env:GRADLE_USER_HOME = "D:\.gradle-hero"
flutter run -d RR8M601DR3Z
```

### Notes for next continuation

- Keep `GRADLE_USER_HOME` pinned to `D:\.gradle-hero` for stable Android builds on this machine.
- If adding/removing dependencies, run `flutter pub get` in both source and deploy project when both are used.
- Notification Center data is currently mock/local state in Home shell and can be swapped to API later without changing card UI structure.

---

## Quick Start

```bash
# clone
git clone https://github.com/lulusbagos/HERO-.git
cd HERO-

# install dependencies
flutter pub get

# run on a connected device or emulator
flutter run
```

---

## Project Structure

```
lib/
├── main.dart                         # Entry point (minimal)
├── app/
│   ├── hero_app.dart                 # MaterialApp, theme, routing
│   ├── app_theme.dart                # Centralised colour/typography tokens
│   └── app_routes.dart               # Named-route registry
├── core/
│   ├── enums/app_role.dart           # AppRole enum (staff → heroAdmin)
│   ├── models/app_menu_item.dart     # Menu item data model
│   ├── repositories/menu_repository.dart  # Abstract menu contract
│   └── services/auth_service.dart    # Authentication logic
└── features/
    ├── auth/
    │   ├── pages/login_page.dart     # Animated login page
    │   └── widgets/                  # GlowOrb, CompanyLogo, UniformVisual, LoginCard
    ├── home/pages/home_shell.dart    # Post-login shell with lazy-loaded menu
    └── menu/
        ├── pages/menu_screen.dart    # Individual module placeholder
        └── repositories/mock_menu_repository.dart  # Mock DB (swap for real API)

assets/images/
├── indexim_logo.png                  # PT INDEXIM COALINDO logo
└── indexim_uniform_person.png        # Company uniform visual

docs/
├── ARCHITECTURE.md                   # Layered architecture deep-dive
├── FEATURES.md                       # Feature list & roadmap
├── CONTRIBUTING.md                   # How to contribute
└── ROADMAP.md                        # Release milestones
```

---

## Roles

| Role | Access |
|---|---|
| **Staff** | Attendance, leave, announcements |
| **Supervisor** | Staff menus + approve overtime |
| **Manager** | Supervisor menus + budget review + tiered approval |
| **HERO Admin** | Full access + user management + policy master |

---

## Key Concepts

- **Role-based access** — menus are fetched per role at runtime from the database
- **Tiered approval** — approval chains configured in DB, never hardcoded
- **Lazy loading** — feature modules loaded on demand via `FutureBuilder` + repository pattern
- **DB-driven menus** — swap `MockMenuRepository` with an API implementation, zero UI changes needed

---

## Assets

Place company assets in `assets/images/` then declare in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

---

## Documentation

| Doc | Description |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Folder structure, layer rules, data flow |
| [docs/FEATURES.md](docs/FEATURES.md) | Feature status per version |
| [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) | Branch strategy, commit convention, PR checklist |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Planned milestones v1.0 → v3.0 |

---

*© PT INDEXIM COALINDO · All rights reserved*
