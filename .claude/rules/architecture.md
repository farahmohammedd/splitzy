---
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
  - "integration_test/**/*.dart"
---

# Clean Architecture Boundaries

**Required project rules**, not optional guidance. This file is path-scoped and loads
automatically when Dart files are touched. Read it when planning or making any change that
touches Dart code (`lib/`, `test/`, `integration_test/`) — see `ai-workflow.md`.
High-level source of truth: `CLAUDE.md`.

## Layout

```
lib/
  main.dart, app.dart, injection_container.dart   # app root (see below)
  core/                     # application-wide or genuinely shared code only
    assets/                 # AppImages
    error/                  # shared Failure / AppException bases, ErrorReporter
                            # (+ Crashlytics implementation), runGuarded,
                            # global error handlers
    firestore/              # Firestore helpers shared by data layers
                            # (TimestampConverter)
    format/                 # non-money display formatting (formatMonthDay)
    money/                  # money display (formatEgp), shared by features
    router/                 # the app's single GoRouter and its route paths
    theme/                  # design system (colors, text styles, spacing, theme)
    widgets/                # widgets shared by multiple features
  features/
    <feature>/
      domain/               # pure Dart
        entities/           # entities (Freezed allowed)
        repositories/       # repository interfaces
        usecases/           # one use case per file
        failures/           # the feature's sealed failure type (e.g. AuthFailure)
        money/              # money calculations (e.g. splitEqually), pure Dart
        validation/         # input rules shared by use cases and forms
      data/
        datasources/        # one thin wrapper per SDK/service (Firebase, Hive)
        exceptions/         # the feature's AppException family (e.g. AuthException)
        mappers/            # SDK error → AppException translation
        models/             # DTOs (Freezed + json_serializable)
        repositories/       # repository implementations
      presentation/
        providers/          # <feature>_providers.dart (domain-typed providers) and
                            # Riverpod controllers/notifiers
        screens/            # screens and their route-level connector pages
        widgets/            # widgets used by the feature's screens
```

This layout follows the Cinefy reference project (`domain/entities|repositories|usecases`,
`data/datasources|models|repositories`, `presentation/providers|screens|widgets`).
`domain/failures/`, `domain/validation/`, `data/exceptions/` and `data/mappers/` are
Splitzy additions: each feature has its own failure and exception families on top of the
shared bases in `core/error/` (see Domain layer), and validation rules are shared by use
cases and forms. Tests mirror the same folders.

Folders are created only when the first real file that belongs in them is written — no
empty placeholder folders, and no `domain/`/`data/` folders (or subfolders) just for
symmetry. Remove empty folders that are no longer needed.

## What belongs in `core/`

Code goes into `core/` only when it is **application-wide** (e.g. theme, assets, routing) or
**genuinely shared by multiple features**. Do not put code in `core/` because it "might be
reused later": feature-specific code stays in its feature until a second feature actually
needs it, and moving it then is a planned shared refactoring (see `project-scope.md`).

## App root, injection container and provider wiring

Three distinct responsibilities — do not use the ambiguous term "composition root" for
any of them:

- **App root** (`main.dart`, `app.dart`, `injection_container.dart` and the router): the
  application composition layer (`CLAUDE.md` → Core). It connects features, routing,
  app-wide dependencies and application-wide infrastructure. Importing several features'
  `data` and `presentation` layers there does **not** violate the feature-isolation rule
  below.
- **Injection container** (`lib/injection_container.dart`): creates and configures
  dependency instances once — SDK clients → data sources → repository implementations →
  use cases — and exposes them as `ProviderScope` overrides. This is the only place `data`
  implementations are bound to `domain` interfaces. It is immutable and passed explicitly,
  never stored in a global.
- **Provider wiring** (`features/<feature>/presentation/providers/<feature>_providers.dart`):
  declares providers by domain type (repositories, use cases), supplied by the injection
  container's overrides, plus derived providers and controllers. Providers never construct
  `data` objects.

## Dependency rule

Dependencies point **inward only**:

```
presentation  ──►  domain  ◄──  data
```

| Layer          | May import                                   | Must NOT import                                    |
| -------------- | -------------------------------------------- | -------------------------------------------------- |
| `domain`       | Dart SDK, `core/error/failures.dart` (the only `core` file allowed), Freezed annotations | Flutter, Firebase, Hive, Riverpod, GoRouter, `data`, `presentation`, any other `core` file |
| `data`         | `domain`, `core`, Firebase/Firestore SDKs, Hive | `presentation`, Flutter widgets                    |
| `presentation` | `domain`, `core`, Flutter, Riverpod, GoRouter | Firebase SDKs, Hive, `data` internals (DTOs, data sources) |

`domain` imports only `core/error/failures.dart` (the shared `Failure` base it extends) — an
explicit allowlist, not "any pure-Dart file". The rest of `core` stays out of `domain`:
`core/theme`, `core/widgets`, `core/assets` and `core/router` depend on Flutter; in
`core/error`, `run_guarded.dart` (Riverpod), `global_error_handlers.dart` (Flutter) and
`crashlytics_error_reporter.dart` (Firebase) are not pure Dart, and `exceptions.dart`
(data-layer errors) and `error_reporter.dart` (infrastructure) are not domain concepts.
Allowing another `core` file is an explicit decision recorded here.

- Wiring `data` implementations into `domain` interfaces happens **only in the injection
  container** (above), never inside widgets, providers or use cases.
- Features do not import another feature's `data` or `presentation` layer (the app root is
  exempt, above). Shared concepts move to `core` or are exposed via the other feature's
  `domain` layer.

## Domain layer

- Pure Dart. Must be runnable with `dart test` — no Flutter binding required.
- **Entities**: immutable (Freezed allowed), no JSON annotations, no Firestore types
  (`Timestamp`, `DocumentReference`, etc.).
- **Repository interfaces**: abstract classes describing what the domain needs, in domain terms.
- **Use cases**: one public operation each, created when the operation has business rules
  (split calculation, balance computation, settlement simplification, validation).
  Operations without rules (e.g. sign-out, observing auth state) call the repository
  directly; do not create pass-through use cases.
- Failures extend the shared `Failure` base (`core/error/failures.dart`, which also defines
  `NetworkFailure` and `UnexpectedFailure`); each feature adds its own `sealed` family
  (e.g. `AuthFailure`). They are thrown by repositories/use cases — never Firebase
  exceptions — and controllers turn them into `AsyncError` through `runGuarded`
  (`core/error/run_guarded.dart`).

## Data layer

- **DTOs/models**: Freezed + json_serializable, with explicit `toEntity()` / `fromEntity()`
  mapping. Firestore-specific conversions (e.g. `Timestamp` ↔ `DateTime`) live here.
- **Data sources**: one per external SDK/service (e.g. `FirebaseAuthDataSource`,
  `GoogleSignInDataSource`). Thin: one method per SDK call, may return SDK types (e.g.
  `User`), no business rules. Each data source translates its own SDK's errors into the
  feature's `AppException` family (`data/exceptions/`) through a mapper (`data/mappers/`),
  keeping the original stack trace (`Error.throwWithStackTrace`); any other error passes
  through unchanged. Nothing above the data sources sees SDK error types.
- **SDK-type boundary**: Firebase SDK types (e.g. `User`, `UserCredential`,
  `FirebaseAuthException`) must never leak into `domain` or `presentation`. Data sources
  translate SDK exceptions (above); repositories map SDK data types (e.g. `User` →
  `AppUser`) before anything crosses out of `data`. The injection container is the one
  exception outside `data`: it may create SDK clients (e.g. `FirebaseAuth.instance`) and
  pass them to data sources, solely to construct dependencies.
- **Repository implementations**: implement domain interfaces, coordinate one or more data
  sources, map DTOs/SDK types ↔ entities, and map `AppException`s → `Failure`s (keeping the
  original stack trace). Errors that are not `AppException`s pass through unchanged and
  become `UnexpectedFailure` in `runGuarded`.

## Presentation layer

- Screens and widgets render state and forward user intent. No business rules.
- Controllers/notifiers call use cases where they exist, otherwise the repository, and
  expose `AsyncValue`/state to widgets. The concrete patterns (controller shape,
  Page/Screen split, navigation) are in `flutter-dart.md` → Presentation patterns.

## Error handling

Every error follows one path, and each layer translates it once:

```
SDK error ─► mapper ─► AppException ─► repository ─► Failure ─► runGuarded ─► AsyncError ─► messageFor() ─► UI
(data source)          (data)                        (domain)   (controller)                 (widget)
```

1. **Data source**: catches its SDK's exception type (e.g. `FirebaseException`,
   `GoogleSignInException`) and rethrows the mapper's `AppException` with the original
   stack trace (`Error.throwWithStackTrace`). See Data layer.
2. **Repository**: catches `AppException` and rethrows the matching `Failure`, keeping the
   stack trace. Shared exceptions map to shared failures (`NetworkException` →
   `NetworkFailure`); the feature's `sealed` exception family maps through an
   **exhaustive** `switch`, so a new exception type does not compile until it is mapped; an
   unknown `AppException` becomes `UnexpectedFailure`. Any other error passes through.
3. **Controller**: wraps the call in `runGuarded` (`core/error/run_guarded.dart`):
   - a `Failure` → `AsyncError(failure)`, **not reported** (an expected outcome);
   - anything else → reported to `ErrorReporter.recordNonFatal` with its original stack
     trace and the `reason` (the operation, e.g. `'Logging in'`), then
     `AsyncError(UnexpectedFailure())`, so the UI never shows technical details.
4. **Widget**: shows `messageFor(error)` (`core/error/failures.dart`): a `Failure`'s own
   message, or the generic fallback for anything else.

A user cancellation is not an error: the data source signals it with a dedicated
`AppException` outside the feature's error family (e.g. `GoogleSignInCancelledException`),
and the repository turns it into a "nothing happened" result (e.g. `null`), never a
`Failure`.

### Expected vs unexpected errors

| Kind | Examples | Shown to the user | Reported to Crashlytics |
| --- | --- | --- | --- |
| Expected — a `Failure` | wrong password, no connection, email in use | its own `message` | no |
| Unexpected — anything else | a bug, an unknown SDK state | generic `UnexpectedFailure` message | yes, non-fatal |
| Uncaught — reached no handler | an exception in `build`, an unawaited future | nothing app-specific (Flutter's error widget for build errors) | yes, fatal |

### Reporting

- `ErrorReporter` (`core/error/error_reporter.dart`) is the only reporting API the app uses.
  `CrashlyticsErrorReporter` is its only implementation and the only class that uses the
  Crashlytics SDK. It is created in the injection container, passed to repositories by
  constructor, and read by controllers through `errorReporterProvider`.
- Reporting never throws and never delays the user: calls are not awaited
  (`unawaited(...)`), and a failure to report is only logged locally.
- `recordNonFatal` ignores `Failure`s. `recordFatal` reports everything, a `Failure`
  included (it should have been handled).
- **Uncaught errors**: `installGlobalErrorHandlers` (see App initialization) hooks
  `FlutterError.onError` and `PlatformDispatcher.instance.onError`, prints the error as
  Flutter would, and reports it as fatal. Errors handled by `runGuarded` never reach them,
  so nothing is reported twice.
- **Secondary operations**: a best-effort step after the main operation has already
  succeeded (e.g. saving the display name after registration, ending the Google session
  after sign-out) must not fail that operation. Catch its error, log it with
  `developer.log` (`name: 'splitzy.<feature>'`), report it as non-fatal with a clear
  `reason`, and continue.
- Never swallow an error silently (`catch (_) {}`): handle, map, report or rethrow.

### Adding errors to a feature

1. `data/exceptions/<feature>_exceptions.dart`: a `sealed` `<Feature>Exception extends
   AppException` with one `final class` per case, plus an "unknown" case that keeps the SDK
   code for debugging.
2. `data/mappers/<sdk>_exception_mapper.dart`: one function from the SDK exception to
   `AppException`, switching on the error code.
3. `domain/failures/<feature>_failure.dart`: a `sealed` `<Feature>Failure extends Failure`,
   each case with its user-facing `message` (see `flutter-dart.md` → User-facing text); the
   "unknown" case shows the generic message and keeps the code in `toString()` only.
4. The repository's exhaustive `switch` maps every exception case to a failure case.
5. Tests: the mapper (every code), the repository mapping (every case, stack trace kept),
   and each failure's message.

## Firestore and Hive roles

- **Firestore is the source of truth** for synchronized application data.
- **Hive is only a local cache / offline support.** It lives behind data-layer abstractions
  (local data sources used by repository implementations); presentation and domain never
  depend on Hive directly, and Hive must not become a second source of truth.
- **Unresolved** (`CLAUDE.md` → Open Decisions #2): the cache policy (what is cached,
  invalidation, sync) must be defined and approved before offline persistence is implemented.

## Firestore data model

Decided (`CLAUDE.md` → Open Decisions #4). Database `(default)`, location
`europe-west1`, created in production mode (locked until `firestore.rules` is published).

```
groups/{groupId}
  ownerId:   string     the creator's Firebase Auth uid
  name:      string     1–50 characters
  members:   list       ordered; each { id: string, name: string }
                        the first member is the owner, with id == ownerId
  createdAt: timestamp  server time
  expenses/{expenseId}  (Expenses phase)
    description, amount (int piastres), currency ('EGP'), paidBy (member id),
    splitType ('equal' | 'custom'), shares (map member id → int piastres),
    createdAt
```

- **One top-level `groups` collection**, each group naming its owner. Sharing a group
  with registered users later (`CLAUDE.md` → Future) adds a member-uid list; no data moves.
- **Members are names only**, stored in the group in the order they were added (the
  equal-split remainder rule depends on that order). Member ids are generated by the
  data layer; the owner's member id is their uid, so "you" can be found in a group.
- **A group has 2–50 members** (the owner plus at least one other). Group and member
  names are 1–50 characters after trimming; member names are unique within a group,
  ignoring case.
- **Expenses store each member's share** at creation, so later membership changes never
  rewrite past expenses. Balances are computed on the device from the expenses and are
  never stored.
- **Security** (`firestore.rules`): signed-in users read and create only groups they own
  (`ownerId == request.auth.uid`); a new group must have exactly the fields above, a
  1–50 character name, 2–50 members and `createdAt == request.time`. Only a group's
  owner reads and adds its expenses; a new expense must have exactly the fields above, a
  1–50 character description, an amount of 1–100,000,000 piastres, currency `EGP`, split
  type `equal` or `custom`, one share per group member (the payer included) and
  `createdAt == request.time`. That the shares add up to the amount is enforced by the
  app (`AddExpenseUseCase`): rules cannot add up a map's values. Updating and deleting
  groups and expenses are denied until those features are built.
- **Queries must match the rules**: every group query filters on
  `ownerId == <signed-in uid>`; otherwise Firestore rejects the whole query.

## App initialization

Firebase, Hive and environment (`.env`) initialization must happen in one deliberate
application-level location — never scattered across screens or features. That location
is `main()` (`lib/main.dart`), in this order:

1. `WidgetsFlutterBinding.ensureInitialized()`;
2. `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`;
3. `await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode)` — the
   only place Crashlytics collection is decided (there is no manifest setting); set on
   every launch because the plugin persists the value;
4. create the injection container (`InjectionContainer.create()`);
5. `installGlobalErrorHandlers(container.errorReporter)` — after Firebase and before
   `runApp`, so every uncaught error from the first frame on is reported;
6. `runApp(ProviderScope(overrides: container.overrides, ...))`.

Future
initialization (Hive, `.env`, Google Sign-In) is added there or inside the container's
creation; extracting a bootstrap function is its own planned step.
**Unresolved** (`CLAUDE.md` → Open Decisions #3): how `.env` is provided.

## When unsure

If code does not clearly belong to one layer, or a boundary would need to be crossed, stop and
ask the developer rather than guessing.
