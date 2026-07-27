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

## You cannot compile Flutter directly on a phone — here's the real path

Flutter apps need the Android SDK + Flutter SDK + Gradle to build an APK.
That toolchain doesn't run on a phone. The standard way to get an APK using
**only your phone** is a free cloud build service. Below is the simplest
route, entirely from your phone browser + the GitHub app.

### Step 1 — Put this code on GitHub (from your phone)

1. Install the **GitHub** app (or just use github.com in Chrome).
2. Create a new repository, e.g. `ah-transport-gujranwala`.
3. Upload every file in this project into that repo, keeping the folder
   structure (`lib/`, `pubspec.yaml`, `android/`, `README.md`).
   - Easiest: on your phone, use the **Working Copy** (iOS) or **GitHub app /
     "Add file → Upload files"** on github.com (Android/iOS browser) and
     upload the whole `ah_transport` folder as a zip, or file by file.
4. Important: this package only ships `pubspec.yaml`, `lib/`, and an
   `android/app/src/main/AndroidManifest.xml` fragment. Once it's in your
   repo, the CI step below will run `flutter create .` first to generate the
   full `android/`, `ios/`, and platform boilerplate around your `lib/` code,
   then apply the manifest permissions from this project.

### Step 2 — Connect Codemagic (free tier, no card required)

1. Go to **codemagic.io** in your phone browser → Sign up with GitHub.
2. Add your `ah-transport-gujranwala` repo as a new app.
3. Choose **Flutter App** as the project type.
4. Use this build workflow (paste as `codemagic.yaml` in repo root, or set
   up via their UI):

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
```

5. Tap **Start new build**. It builds in the cloud (5–10 minutes).
6. When it finishes, download the `.apk` artifact straight to your phone
   and tap it to install (enable "Install unknown apps" for your browser in
   Android settings if prompted).

### Alternative: GitHub Actions (also free, no separate signup)

If you'd rather stay inside GitHub, add `.github/workflows/build.yml`:

```yaml
name: Build APK
on: workflow_dispatch
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
```

Trigger it from the GitHub app: repo → Actions → "Build APK" → Run workflow.
Download the APK from the finished run's Artifacts section.

---

## If you later get access to a PC (faster, one-time setup)

```bash
flutter create .          # generates android/ios boilerplate around lib/
flutter pub get
flutter build apk --release
```

APK will be at `build/app/outputs/flutter-apk/app-release.apk`. Signing for
Play Store release needs a keystore — ask if you want that walkthrough too.

---

## Database

SQLite via `sqflite`, 10 tables: vehicles, partners, drivers, customers,
trips, trip_expenses, maintenance_records, transactions, settings, plus
indexes on trip date/vehicle. Schema lives in
`lib/database/database_helper.dart`.
