# AH Transport Gujranwala

Flutter fleet/trip/accounts management app. Offline-first, SQLite-backed.

## What's included in this build

Fully working: Dashboard (summary + 7-day profit chart), Vehicles (CRUD + expiry
warning), Drivers (CRUD), Customers (CRUD), Partners (add/list), Trip entry
(core feature, with dynamic expense rows and live profit calc), Trips list
(status filter, delete), Reports (daily/weekly/monthly/yearly/custom + PDF
export with signature block), Settings (dark mode, language toggle stub),
SQLite schema for all 10 tables, JSON backup export via share sheet.

Scaffolded but not wired up (clear TODO markers left in code, extend as needed):
PIN/biometric lock screen, push notifications for expiry reminders, full
Urdu translation strings, restore-from-backup.

---

## Build the APK using Codemagic (free, from your phone)

1. Push this code to a GitHub repo (`lib/`, `pubspec.yaml`, `android/`).
2. Go to codemagic.io → sign up with GitHub → add this repo → choose "Flutter App".
3. Add this workflow (`codemagic.yaml` in repo root or via their UI):

```yaml
workflows:
  android-workflow:
    name: AH Transport Android Build
    max_build_duration: 30
    environment:
      flutter: stable
    scripts:
      - name: Get Flutter packages
        script: flutter pub get
      - name: Build APK
        script: flutter build apk --release
    artifacts:
      - build/**/outputs/**/*.apk
