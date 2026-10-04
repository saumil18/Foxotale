# FoxOtale

Two Flutter apps for independent and boutique hotels: a brand-forward **Guest App**
for direct booking, and a calmer, denser **Staff App** for property setup, daily
operations and management intelligence.

Only the Staff App exists today. It runs on an in-memory repository — there is no
backend and no authentication yet.

## Layout

The split follows Solution Design §8.

```
apps/
  staff_app/            the Staff App (the only app so far)
packages/
  foxotale_ui/          Design System v1 in code — tokens, shared widgets,
                        brand assets and the licensed fonts
  foxotale_domain/      pure Dart: property/booking/room/task models, the
                        role-permission matrix, Indian currency formatting
docs/
  design-system/        Design System v1 (PDF)
  foxotale/             the approved Solution Design and architecture documents
```

`packages/foxotale_api` is named in the Solution Design but not created yet; it
arrives with the first real client rather than as an empty folder.

## Running the Staff App

```bash
cd apps/staff_app
flutter pub get
flutter run
```

## Tests

Each package tests itself.

```bash
(cd apps/staff_app && flutter test)
(cd packages/foxotale_ui && flutter test)
```

## Things worth knowing before changing code

- **Colour literals in widgets are a bug.** Every colour comes from
  `FoxColors` in `foxotale_ui`, and each token carries a measured contrast
  ratio that the Design System PDF documents.
- **Unauthorised actions are hidden, not disabled.** `Permissions` transcribes
  the PRD §7 matrix cell by cell; the role hierarchy governs visibility scope,
  not capability inheritance.
- **Intelligence data is entered by hand in v1.** OTA/PMS auto-feeds are
  Phase 3, so report screens need data-entry views, not just dashboards.
