# T'Donuts — Flutter code test

A working slice of the T'Donuts customer app (the brief calls the brand
*J'Donuts*; the app ships under its own name, **T'Donuts**): fake login and
registration with real validation, an offline-first Home and Product detail,
and an animated Rewards screen. Android and iOS.

> **Fake OTP code: `123456`** (any other code fails; 3 wrong codes lock entry until *Resend*).

| | Version |
|---|---|
| Flutter | 3.47.0 (stable) |
| Dart | 3.13.0 |
| Tested on | Xiaomi Mi 10 (Android, physical), iPhone 17 Pro simulator |

---

## How to run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # ObjectBox bindings (also committed)
flutter run
```

Generated code (`lib/objectbox.g.dart`, `lib/l10n/generated/`) is committed, so
`flutter pub get && flutter run` works without the build step.

VS Code: `.vscode/launch.json` has *T'Donuts (debug / profile / release)*
configurations.

### App icon and splash

Source art lives in `assets/branding/` (not bundled into the app). The platform
files are generated and committed; regenerate after changing the art:

```bash
dart run flutter_launcher_icons          # config: flutter_launcher_icons.yaml
dart run flutter_native_splash:create    # config: flutter_native_splash.yaml
```

### Tests

```bash
flutter test          # unit + widget tests
flutter analyze       # must report "No issues found!"
flutter test integration_test -d <simulator-or-device-id>   # Register → Home → Product detail
(cd mock_server && dart test)                               # mock API
```

### Builds

```bash
flutter build apk --release        # build/app/outputs/flutter-apk/app-release.apk
flutter build ios --simulator      # build/ios/iphonesimulator/Runner.app (zip it to share)
```

---

## Architecture

Feature-first clean architecture. Each feature is split into three layers and
dependencies only point inwards:

```
presentation ──calls──▶ domain ◀──implements── data
 (Flutter, BLoC)     (pure Dart)          (ObjectBox, Dio, secure storage)
```

- **Domain** — entities, repository *interfaces*, use cases and validators.
  No Flutter imports, so it is unit-tested with plain `flutter test` and no device.
- **Data** — repository implementations, ObjectBox entities, data sources.
  Returns typed failures in a `Result`, never throws to the UI.
- **Presentation** — pages, widgets and blocs. Talks to use cases / repository
  interfaces only, so swapping the fake auth for a real API never touches a widget.

### Folder map

```
lib/
├─ main.dart                 # composition root: DI → restore session → runApp
├─ app.dart                  # MaterialApp.router: theme, locale, router
├─ core/
│  ├─ di/                    # get_it registrations (the only place services are built)
│  ├─ router/                # go_router, auth redirect guard, page transitions
│  ├─ database/              # ObjectBox store + versioned data migrations
│  ├─ network/               # Dio factory, retry interceptor, {data,error,meta} envelope
│  ├─ connectivity/          # connectivity_plus + real reachability probe
│  ├─ session/               # flutter_secure_storage session store
│  ├─ result/                # Result<T> sealed type + typed Failure hierarchy
│  ├─ theme/                 # design tokens (colours, spacing, type), light + dark
│  ├─ motion/                # every animation duration & curve (one file)
│  └─ widgets/               # shared UI building blocks
├─ features/
│  ├─ auth/                  # onboarding, phone, OTP, name, date of birth
│  │  ├─ domain/             #   validators, AuthRepository, use cases
│  │  ├─ data/               #   FakeAuthRepository, UserEntity (ObjectBox)
│  │  └─ presentation/       #   SessionCubit, AuthFlowCubit, step blocs, pages
│  ├─ home/                  # Home, section "see more" lists, shop list, catalogue sync
│  ├─ product/               # Product detail
│  ├─ member/                # member record shared by Home and Rewards
│  ├─ rewards/               # Rewards screen
│  ├─ profile/               # edit profile (photo, name, OTP-verified phone)
│  ├─ settings/              # menu: profile header, appearance, language, log out
│  └─ shell/                 # bottom-nav shell hosting the tabs
└─ l10n/                     # app_en.arb, app_my.arb (+ generated/)
```

---

## State management: BLoC

I chose **flutter_bloc**, using both of its flavours on purpose:

| Use | Why |
|---|---|
| **`Bloc`** (events → states) for flows with async submits (Phone, OTP, Date of birth) | Event transformers from `bloc_concurrency`. Submits use `droppable()`, so **a double tap on Continue sends exactly one request**: the second event is dropped while the first is in flight. This is enforced by the framework, not by a hand-rolled `isLoading` flag. |
| **`Cubit`** for simple state (theme/language, session, registration draft, quantity) | No events to transform, so methods that `emit` are clearer and shorter. |

Other reasons:

- **Testability:** blocs are plain Dart classes; `bloc_test` asserts the exact
  sequence of emitted states (see `test/features/auth/presentation/bloc/`).
- **Explicit state:** states are immutable (`Equatable`/sealed classes), so the UI
  is a pure function of state and every loading / error / empty case is a visible type.
- **Scoping:** a bloc's lifetime follows the widget tree. The registration draft
  (`AuthFlowCubit`) is provided by a go_router `ShellRoute` around the auth steps,
  so the back arrow returns to a step **with its values intact**, and leaving the
  flow disposes it.

App-wide blocs (`SessionCubit`, `PreferencesCubit`) are singletons from get_it,
provided at the root with `BlocProvider.value`. Screen blocs are created per route.

## Dependency injection: get_it

`get_it` is a service locator. All registrations live in
[`lib/core/di/injection.dart`](lib/core/di/injection.dart), grouped by layer:

```dart
getIt
  ..registerLazySingleton<AuthRepository>(() => FakeAuthRepository(getIt(), getIt()))
  ..registerFactory(() => RequestOtp(getIt()))
  ..registerLazySingleton(() => SessionCubit(RestoreSession(getIt()), LogOut(getIt())));
```

Rules followed in this codebase:

- **Register against interfaces** (`AuthRepository`, `SessionStorage`,
  `NetworkStatus`), so replacing the fake back end with a real one is a
  one-line change here. Nothing else changes.
- **`registerLazySingleton`** for stateful services (store, Dio, repositories,
  app-wide cubits); **`registerFactory`** for stateless use cases and per-screen blocs.
- **Only the composition root calls `getIt`** (`main.dart`, `injection.dart` and
  route builders). Widgets never call `getIt` or construct services. They get
  blocs through `BlocProvider`, which keeps them testable with fakes.
- Async setup (opening ObjectBox, running migrations) happens once in
  `configureDependencies()` before `runApp`.

## Navigation: go_router

- **Auth redirect guard:** [`auth_guard.dart`](lib/core/router/auth_guard.dart) is a
  pure function of `(SessionState, location)`, unit-tested in isolation. The
  router's `refreshListenable` follows `SessionCubit`, so screens never navigate
  after sign-in or sign-out. The guard sends the user to the right place:
  - signed out on a private route → Onboarding
  - just registered → Welcome (once)
  - signed in on Onboarding/auth steps → Home
- **`/product/:id`** opens Product detail for any product, deep links included.
- **`/section/:key`** is a Home section's "see more" list (all its products,
  vertically); **`/shops`** is the shop list behind *Explore now*.
- **`/settings/profile`** edits the profile. Tapping the photo on Home switches
  to the Settings tab rather than pushing the editor over Home.
- `/register/{phone,otp,name,dob}` and `/login/{phone,otp}` share one `ShellRoute`.
- The bottom-nav tabs use `StatefulShellRoute.indexedStack`, so each tab keeps
  its own stack and scroll position.

## Local data and session

- **ObjectBox** stores users, preferences and (Task 2) the catalogue. Schema
  changes are migrated automatically by ObjectBox from `lib/objectbox-model.json`
  (stable UIDs make renames safe; commit this file). On top of that,
  `DatabaseMigrator` keeps a `DbMetaEntity.schemaVersion` and runs **versioned
  data migrations** exactly once, in order, inside a write transaction.
- **Session** (user id + token) lives in **flutter_secure_storage** (Keychain /
  Android Keystore), never in ObjectBox. It is restored before the first frame, so
  a relaunch while signed in opens Home and a signed-out launch opens Onboarding,
  with no splash flicker.

## Network

Dio is built in [`dio_factory.dart`](lib/core/network/dio_factory.dart) with:

- **Timeouts:** connect 5 s, receive 10 s, send 10 s.
- **Retry:** [`RetryInterceptor`](lib/core/network/retry_interceptor.dart) retries
  *GET only* (a POST is never repeated) on timeouts, connection errors and
  408/429/5xx, with exponential backoff (400 ms, 800 ms, 1.6 s).
- **Logging:** `LogInterceptor` in debug builds only.

## Theme and language

- Light, Dark and System themes from one set of design tokens
  (`AppColors` `ThemeExtension`, spacing/radius/type scales). Widgets read
  `context.colors.*`; no hard-coded colours.
- English (default) and Myanmar via `gen-l10n` ARB files. Switch either in
  **Settings** (each opens a bottom sheet over the tab bar); the choice is saved
  in ObjectBox and applied before the first frame.

---

## Task 1: auth flow

| Field | Rule |
|---|---|
| Phone | After `+95`, strip spaces, dashes and one leading `0`; must be `9` + 7–9 digits (`09254135592` → `+959254135592`). |
| OTP | 6 digits; only `123456` passes; 3 wrong codes lock entry until Resend; 5:00 resend countdown. |
| First name | Required, 1–50 characters (grapheme clusters) after trim, letters and spaces incl. Myanmar script, no digits (Latin or Myanmar). |
| Last name | Optional, same character rules. |
| Date of birth | Real calendar date (no 31 April, 29 Feb only in leap years), not in the future, age ≥ `DateOfBirthRules.minimumAge` (13). |

All validators are pure functions in `features/auth/domain/validators/`, each
rule covered by unit tests. Use cases re-validate before calling the repository.

`FakeAuthRepository` waits `FakeAuthConfig.latency` (1 s), stores users in
ObjectBox and the session in secure storage. Log in with an unregistered number
fails with an inline *Register instead* link; registering an existing number
offers *Log in instead*.

---

## Status

- [x] Core: theme tokens, motion constants, l10n, Dio, connectivity, ObjectBox, session
- [x] Settings: theme, language, log out, profile edit
- [x] Auth domain + fake repository + router guard (with tests)
- [x] Task 1 screens: Onboarding, Phone, OTP, Name, Date of birth, Welcome (with widget tests)
- [x] Task 2: offline-first Home, Product detail, mock server (+ integration test)
- [x] Task 3: Rewards motion
- [x] Unit, widget and integration tests; release `.apk` and simulator `.app` builds

## Offline strategy

**The UI reads only the local database. The network only *updates* the database.**

```
            ┌───────────── watch() streams ─────────────┐
            ▼                                           │
   Home / Product / Rewards  ◀── BLoC ──  ObjectBox (single source of truth)
                                            ▲         ▲
             first launch: bundled seed ────┘         │ refresh (background + pull)
             assets/seed/catalog.json                 │ Dio → GET /v1/{products,sections,banners,shops}
                                                      └── mock_server ({data, error, meta})
```

1. **Seed on first launch.** `SeedImporter` imports `assets/seed/catalog.json`
   (products, sections, banners, shops, member, tiers, challenges) **before the
   first frame**, so a first launch in airplane mode shows a full Home. The seed
   is versioned (`"version"`, stored in `DbMetaEntity.seedVersion`), so a future
   app release can ship a newer seed.
2. **Reactive reads.** Repositories expose ObjectBox `query().watch()` streams.
   `HomeBloc` subscribes to each section independently (`emit.onEach`), so
   every section has its **own skeleton, empty and error state**.
3. **Refresh writes, never renders.** `RefreshCatalog` → `CatalogRepository.refresh()`:
   - checks real reachability first (`connectivity_plus` + a TCP probe); offline,
     it returns `NetworkFailure` immediately and cached data stays on screen;
   - fetches the four resources **in parallel**; either all succeed and parse, or
     nothing is written;
   - replaces the catalogue in **one ObjectBox transaction**, so the watch
     streams emit once with consistent data;
   - keeps each row's bundled `imageAsset` (the server doesn't know app assets).
4. **When it runs.** On Home start and when connectivity returns (throttled to
   once per 5 min), and on **pull-to-refresh** (`force: true`, always). Background
   failures are silent; only a pull-to-refresh reports its error.
5. **Offline banner.** `ConnectivityCubit` (app-wide) slides a small pill in
   while offline. Reachability is a real probe (TCP to public resolvers on
   ports 443 and 53, in parallel, so a network that blocks one still counts as
   online). The cubit keeps only the newest result, so a slow stale probe
   can't flip it back, and while offline it re-checks every 10 s, so one
   failed probe never leaves the banner stuck.
6. **Images.** `AppNetworkImage`: disk cache via `cached_network_image`, then
   the bundled seed asset (placeholder and offline first launch), then a
   painted donut as the error state. Images seen once render in airplane mode.
7. **One member record.** Home and Rewards read the same `MemberEntity`
   (680,000 pts → Silver, 500 to Gold). The mock-ups disagree; the data decides.

### Run the mock server (optional)

```bash
cd mock_server && dart pub get
dart run bin/server.dart                    # http://0.0.0.0:8080/v1
dart run bin/server.dart --latency 800 --fail-rate 0.3   # slow, flaky network
```

The server's catalogue (`mock_server/data/catalog.json`) differs from the
bundled seed on purpose: Coconut Donut costs 3,400 instead of 3,200, so a
successful sync is visible. Edit the file while the app runs and pull to
refresh.

Every product is in **both** catalogues (a sync replaces the whole catalogue,
so a seed-only product would vanish), and every photo is in both
`assets/images/catalog/` and `mock_server/public/images/products/`. Bump the
seed's `"version"` when you change it so existing installs re-import it.

- **iOS Simulator / Android emulator:** works out of the box (`localhost` / `10.0.2.2`).
- **Physical Android phone:** `adb reverse tcp:8080 tcp:8080`, then
  `flutter run --dart-define=API_BASE_URL=http://localhost:8080`.
- Without the server the app is fully functional on seed data.

## Animations

All durations and curves are named constants in
[`lib/core/motion/app_motion.dart`](lib/core/motion/app_motion.dart); Reduce
Motion (`MediaQuery.disableAnimations`) shortens or skips them through
`context.motion(...)` (and auto-play/drift are switched off).

| Where | What moves |
|---|---|
| Onboarding | Six donut circles drift in one by one (scale + fade); title and buttons enter staggered |
| Registration steps | Shared-axis page transitions; the progress ring animates 25 → 50 → 75 → 100% and morphs into a check |
| Inputs | Focus/error states animate; OTP boxes shake and clear on a wrong code |
| Buttons | Scale on press (`PressableScale`); Continue morphs into a loading state |
| Welcome | Donut tiles slide in staggered, then the title fades up |
| Home | Skeleton shimmer while loading; sections enter staggered; endless banner carousel (below) |
| Product | Hero image from any tile (Home rows and "see more" lists); the quantity and the Add to cart total animate on change |
| Rewards | One master timeline replays each time the tab opens: badge pops in, tier ladder rungs slide in in order and the line to the next tier fills to progress, the points ring sweeps while the total counts up to 680,000; tabs slide their indicator and cross-slide the card list; challenge cards enter staggered, the donut colours in by quarters and the coffee arc fills to 9/12; a complete challenge's Earn button pulses |

- **Bottom nav:** the pink pill appears on the tapped tab at once (no slide),
  starting at the tab's narrow width, and grows over 300 ms (`easeOutCubic`)
  while the label is revealed with an ellipsis; the other tabs reflow in the
  same motion. The bar is inset over a band beside its upper half (grey on
  Home and Rewards, white on Order, Wallet and Settings) and a pink strip under its lower half.
- **Banner carousel:** endless, 78% page width so both neighbours peek in,
  side pages shrink towards the centre page; auto-advances every 5 s with a
  500 ms ease-in-out slide and pauses while dragged.

## Image credits

No client design images are used or committed.

- **Onboarding circles** (`assets/images/onboarding/`): original art made by the
  author in **Canva Pro** (Canva Content License). Each circle was cut from the
  944 × 1680 composition into its own transparent layer, so every circle can drift
  in independently. The layer positions are measured on that canvas in
  `DriftingDonutCircles._layers`.
- **Catalogue photos** (`assets/images/catalog/`, mirrored in
  `mock_server/public/images/`): products, banners and shops made by the author
  in **Canva Pro**. Donuts and drinks were cut out from their white background
  (solid mask, donut holes punched, feathered edge) so they also sit on dark-mode
  cards. Scene photos and banners are cropped JPEGs.
- **Bakery photos** (croissants, milk bread, cinnamon roll, cake slices) and the
  **Gingerbread Donut Box**: made by the author in Canva. The bakery items' white
  background was removed by a flood fill from the image edges (white icing
  inside an item is kept) and they were scaled to 640 px; seasonal boxes are
  800 × 800 JPEG scenes.
- **App icon and splash** (`assets/branding/`): Canva art by the author. The
  icon's baked-in black corners were filled with its pink; the Android
  adaptive icon and Android 12 splash use padded copies so circle masks never
  clip the wordmark.
- How to make more images in the same styles:
  [`docs/canva-image-assets.md`](docs/canva-image-assets.md).
- The Rewards challenge art reuses two of those photos: a greyscale copy with
  colour sweeping in by quarters (`SweepReveal`), and an arc painted over the
  iced coffee.
- Welcome tiles and image fallbacks are donuts drawn in code with `CustomPainter`
  (`lib/core/widgets/donut_art.dart`).

## Known gaps

- **Bottom-nav motion differs from the brief.** The brief asks for the pill to
  *slide* between tabs; this build makes it appear on the tapped tab and grow
  (a deliberate design change, see Animations).
- **Brand name.** The app is branded *T'Donuts* (name, icon, splash, copy)
  instead of the brief's *J'Donuts*, so wording differs from the mock-ups.
- **Beyond the brief:** *Explore now* opens a shop list (the brief allows no
  action), Home sections have a "see more" list, and Settings has a fuller menu
  whose unbuilt items (orders, favourites, promotions, about, terms, privacy,
  e-wallet) show a "Soon" chip and a coming-soon snackbar.
- Order and Wallet tabs are placeholders, as the brief allows. Add to cart
  gives visual feedback only; the cart is not persisted.
- The app version shown in Settings is a constant, not read from the build.
- Not tested on a physical iPhone (iOS Simulator only). No CI workflow.

## Time spent

_To be completed._
