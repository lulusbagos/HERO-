# HERO — Human Enterprise Resource Operations

> Mobile application for PT INDEXIM COALINDO  
> Built with **Flutter** · Designed for multi-role HR & GA workflows

---

## About

**HERO** is a premium mobile platform that streamlines all Human Resource and General Administration processes for PT INDEXIM COALINDO. It supports tiered approval chains, role-based access, and a dynamic menu system driven entirely by a backend database — enabling administrators to add or remove features without a new app release.

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
