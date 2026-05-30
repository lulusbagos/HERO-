# Roadmap

## Vision

HERO menjadi platform HR & GA terpadu PT INDEXIM COALINDO yang menggantikan proses manual, memotong waktu approval, dan memberikan visibilitas real-time kepada seluruh jenjang manajemen.

---

## Milestones

### v1.0 — Login & Foundation ✅ (May 2026)

- [x] Flutter project scaffold with feature-first folder structure
- [x] Premium animated login page (glassmorphism + ambient gradient)
- [x] Role-based access: Staff, Supervisor, Manager, HERO Admin
- [x] DB-driven menu architecture (repository pattern)
- [x] Lazy menu loading per role
- [x] Tiered approval data model design
- [x] Project documentation (README, ARCHITECTURE, FEATURES, CONTRIBUTING)

---

### v1.1 — Core HR Modules (Q3 2026)

- [ ] Attendance: clock-in/out with GPS verification
- [ ] Leave request form + balance display
- [ ] Announcement list with push notifications (FCM)
- [ ] Real REST API replacing MockMenuRepository
- [ ] JWT authentication + secure token storage

---

### v1.2 — Approval Engine (Q4 2026)

- [ ] Dynamic tiered approval engine (DB-configured chains)
- [ ] In-app approve/reject with comments
- [ ] Escalation on timeout
- [ ] Full approval audit trail
- [ ] Supervisor: overtime approval list + bulk action
- [ ] Manager: budget dashboard + department headcount

---

### v2.0 — Admin & Integration (Q1 2027)

- [ ] HERO Admin: user & role management
- [ ] Policy master (leave types, OT rules)
- [ ] Menu configurator UI (enable/disable per role without code change)
- [ ] Audit log viewer
- [ ] PDF/Excel report export
- [ ] BLoC state management migration
- [ ] Offline mode with SQLite cache

---

### v3.0 — Intelligence & Scale (H2 2027)

- [ ] HR analytics dashboard (charts, heatmaps)
- [ ] Smart attendance anomaly detection
- [ ] Self-service onboarding workflow
- [ ] Multi-company / multi-site support
- [ ] Localization (Indonesian / English)
- [ ] Accessibility (WCAG 2.1 AA)

---

## Technology Decisions

| Area | Current | Target (v2.0+) |
|---|---|---|
| State | `setState` + `FutureBuilder` | `flutter_bloc` |
| Auth | Mock | JWT + `flutter_secure_storage` |
| Data | `MockMenuRepository` | REST API + `dio` |
| Local DB | None | SQLite via `sqflite` |
| Notifications | None | Firebase Cloud Messaging |
| Analytics | None | Firebase Analytics |
