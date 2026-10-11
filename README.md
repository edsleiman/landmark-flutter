# Landmark — Flutter app (Android & iOS)

A from-scratch Flutter/Dart rewrite of the original SwiftUI "Landmark" real
estate app, so it now runs on both Android and iOS from one codebase.

## Important: this project was built, not run, in this environment

This Claude Code session's sandbox blocks outbound access to
`storage.googleapis.com` (confirmed via two separate 403 policy denials),
which is where the Flutter/Dart SDK's prebuilt binaries are hosted. That
means the Flutter toolchain itself (`flutter`, `dart`, `flutter pub get`,
`flutter run`) could not be installed or executed here — only the project
source could be written and version-controlled. You'll need a machine with
normal internet access (your Mac is fine) to actually build and run it.

## One-time setup on your own machine

1. Install Flutter if you haven't already: https://docs.flutter.dev/get-started/install
2. Get this project onto your machine (copy the folder, or `git clone` if you
   push this repo somewhere first).
3. **Generate the platform folders.** This repo only has the Dart source
   (`lib/`) and `pubspec.yaml` — no `android/` or `ios/` folders exist yet,
   because those are normally scaffolded by `flutter create`, which couldn't
   run here. From inside the project folder, run:
   ```
   flutter create .
   ```
   This adds the missing `android/` and `ios/` folders without touching your
   existing `lib/` code or `pubspec.yaml`.
4. **Add the required permission strings and deep-link registration.**
   `flutter create` doesn't add these on its own, so run the included script
   right after step 3 — it edits the two files `flutter create` just
   generated:
   ```
   python3 scripts/configure_platforms.py
   ```
   This adds, to **`ios/Runner/Info.plist`**:
   - `NSFaceIDUsageDescription`, `NSCameraUsageDescription`,
     `NSPhotoLibraryUsageDescription`
   - a `CFBundleURLTypes` entry registering the `landmarkapp` URL scheme

   and to **`android/app/src/main/AndroidManifest.xml`**:
   - `<uses-permission>` for `CAMERA` and `USE_BIOMETRIC`
   - an `<intent-filter>` on `MainActivity` for `landmarkapp://verify`

   and to **`MainActivity.kt`/`.java`**:
   - switches the base class from `FlutterActivity` to
     `FlutterFragmentActivity` — the `local_auth` plugin (biometric login)
     requires this, and fails at runtime with
     `PlatformException(no_fragment_activity, ...)` without it.
     `flutter create` always generates plain `FlutterActivity`, so this
     step is never optional on Android.

   It's safe to re-run (it skips anything already present). Review the
   diff afterward (`git diff ios/ android/`) — if it couldn't find
   `MainActivity` automatically (unlikely, but manifests do vary), it says
   so and you'll need to add that one `<intent-filter>` block by hand.
5. Install dependencies and run:
   ```
   flutter pub get
   flutter run
   ```

## What's included in this first pass

- **Auth**: login, sign-up (buyer/seller/both toggle, customer-only — matching
  the original requirement that realtor/admin/developer accounts aren't
  self-registered), biometric login via `local_auth` (Face ID / Touch ID /
  Android biometrics) for a previously-logged-in email.
- **Four personas**, each with its own tab layout: Customer, Realtor, Admin,
  Developer (`lib/screens/role_based_root_screen.dart`).
- **Listings**: browse, search, full filter screen, sort, the complete
  22-category Beirut amenities taxonomy (`lib/models/feature_catalog.dart`,
  ported verbatim), property detail with grouped amenities display.
- **Listing creation** (seller/admin): camera capture using the OS's own
  native camera UI (accept/retake built in) plus a photo-library picker,
  via `image_picker` — mirrors the original UIImagePickerController approach.
- **Viewing requests & verification**: buyer requests a viewing (tracked
  record), realtor either captures a signature on-screen (`signature`
  package) or sends a one-time verification link
  (`landmarkapp://verify?token=...`, handled via `app_links` deep linking) —
  both update the same auditable appointment record the admin can see.
- **Realtor negotiation**: submit/counter/accept/decline offers, then close
  the sale with a committed final price.
- **Commission ledger**: every closed sale is recorded permanently with
  seller, buyer, realtor, date, price, and the developer's commission rate
  *as it stood at the time of the sale* (changing the rate later never
  rewrites past sales). Only the developer persona can edit the standard
  rate (default 1%).
- **Admin dashboard**: stats (listings, appointments, sales, commission
  owed), and drill-ins to the full appointments audit trail and the ledger.

## Mock backend, by design

Like the original Swift version, there's no real server yet — data persists
on-device via `shared_preferences` (`lib/services/*_service.dart`). This is
intentionally the same mock-vs-real split as before, so swapping in a real
backend later means replacing the bodies of these service classes, not the
UI or state-management layer (`lib/providers/*_store.dart`, built with
`provider`/`ChangeNotifier`).

## Demo accounts (password: `password` for all)

| Email | Role |
|---|---|
| buyer@demo.com | Customer — Buyer |
| seller@demo.com | Customer — Seller |
| buyerseller@demo.com | Customer — Buyer & Seller |
| realtor@demo.com | Realtor |
| admin@demo.com | Admin |
| developer@demo.com | Developer (you) |

## Not built yet (same scope cut as the Swift version's first pass)

- Map view of listings.
- Push/email delivery of the verification link (currently uses `share_plus`
  to hand off the link via the OS share sheet — SMS/WhatsApp/email/AirDrop
  all work through that, just not an automatic email send).
- A real backend / API (everything is on-device mock persistence today).
- App icon / launch icon and the splash logo image itself — drop a PNG at
  `assets/images/landmark_logo.png` (the splash screen already references
  it and falls back to a generic icon if it's missing).

## Project structure

```
lib/
  models/        Property, User, Viewing/Offer, Sale, FeatureCatalog
  services/      Mock on-device "backend" (shared_preferences-based)
  providers/     ChangeNotifier stores (state management, via `provider`)
  screens/       UI, organized by persona (auth/, customer/, realtor/, admin/, shared/)
  widgets/       Reusable UI (PropertyCard, SignaturePad, etc.)
```
