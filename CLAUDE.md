# Splitzy

Splitzy is a Flutter expense-splitting application.

Users can:

- create an account and sign in
- create and manage groups
- add members
- record shared expenses
- split expenses equally or by custom amounts
- view balances
- settle debts (future)
- sync application data with Firebase/Firestore
- use the application with appropriate loading, empty and error states
  (offline use is future work)

The project is being developed as an AI-first Flutter project.

The developer is responsible for understanding and approving all shipped code.
Claude is the implementation assistant, not the owner of architectural decisions.

---

## Current Phase

The project is currently in active implementation.

Completed foundations:

- Flutter project setup
- project rules and AI-first workflow
- approved dependency stack
- centralized asset management
- centralized theme/design system
- Launch (loading), Splash, Login and Sign Up UI
- GoRouter navigation (`lib/core/router/`)
- Android application ID `com.splitzy.app`
- Firebase configured for Android (FlutterFire) and initialized in `main()`
- Google Sign-In: Implemented and working.
- Firebase Crashlytics: Integrated and working.
- Profile tab with log out; Home with the bottom navigation bar
- Groups: Create Group, the Groups tab and group cards with the user's balance
- Expenses: Add Expense with equal and custom splits
- Group details: the group's total, the user's share and balance, every
  member's balance and its expenses
- Home balance card: what the user is owed and owes across groups
- Firestore security rules for groups and expenses (`firestore.rules`)

Current temporary state:

- The Activity tab shows "Coming soon".
- Home's Recent Activity section always shows "No activity yet".

Authentication, groups, expenses and balances are implemented. Feature folders
follow the layout in `.claude/rules/architecture.md` → Layout.
Settlements, editing or deleting data and offline persistence are implemented
only when explicitly requested as the next approved step.

Do not assume that a UI screen means its backend functionality exists.

Always inspect the current codebase before deciding what has already been implemented.

---

## Open Decisions

The following decisions have **not** been finalized. Do not assume an answer, and do not
settle one implicitly while implementing something else. If a task depends on an open
decision, stop, explain the options and ask the developer to decide. Once decided, record
the decision in the relevant rule file and remove it from this list.

The numbers are stable IDs that rule files refer to (e.g. "Open Decisions #6"): a decided
item is removed without renumbering the others.

- **#2 Hive cache policy** (before offline persistence): what is cached, invalidation and
  sync. The maintenance status of the installed `hive` package should also be checked
  before Hive is first used.
- **#3 Environment configuration** (before the first `.env` usage): how `.env` is
  provided given that it is git-ignored. (Where initialization lives is decided —
  see `.claude/rules/architecture.md` → App initialization.)
- **#6 Localization**: when (if ever) to introduce a localization package.
- **#7 CI scope**: what the approved GitHub Actions CI runs, and when it is set up. (CI
  needs the git-ignored Firebase configuration files — see Firebase.)

Decided: #1 Money (see Money and Expense Calculations); #4 Firestore data model and
security (see `.claude/rules/architecture.md` → Firestore data model); #5 Firebase
configuration files are not committed (see Firebase); #8 design references in
`docs/design/references/` are committed (see Assets).

---

## Future (not now)

Not to be implemented until the developer decides otherwise:

- Groups shared between registered users (members found by name or email). For now
  members are names only and a group belongs to its creator, who is its first member.
- Settlements, search, notifications.
- Receipt scanning — cancelled until the developer decides otherwise.
- Editing and deleting groups and expenses.
- The Activity tab and Home's Recent Activity.
- Forgot Password.
- Offline use (see Open Decisions #2).
- A custom app icon and display name.

---

## Core Development Principles

1. Every shipped change must be understandable and reviewable by the developer.
2. Work in small, focused, reviewable steps.
3. Do not make unrelated changes.
4. Do not introduce architecture, dependencies or patterns without justification
   and approval when required by the rules.
5. Prefer simple, explicit solutions over unnecessary abstraction.
6. Do not implement future features "while you are here".
7. Do not silently change previously approved architectural decisions.
8. When requirements are ambiguous, stop and ask instead of guessing.
9. Verify changes with formatting, analysis and tests.
10. Never weaken or delete tests just to make a change pass.

---

## Approved Technology Stack

| Concern | Choice |
|---|---|
| UI framework | Flutter |
| Language | Dart |
| State management | Riverpod 3 |
| State code generation | riverpod_generator |
| Authentication | Firebase Authentication |
| Social authentication | Google Sign-In |
| Database | Cloud Firestore |
| Crash reporting | Firebase Crashlytics |
| Navigation | GoRouter |
| Architecture | Clean Architecture |
| Models | Freezed + json_serializable |
| Local cache | Hive |
| Environment configuration | flutter_dotenv |
| Testing | flutter_test + mocktail |
| Code generation | build_runner |
| CI | GitHub Actions |

These are approved project decisions.

Do not propose replacing them with alternative technologies unless the developer
explicitly asks for alternatives.

---

## Flutter / Dart Environment

Current project environment:

- Flutter: 3.38.4
- Dart: 3.10.3

Target platform: Android is the only officially supported platform. Firebase is
configured for Android only (`DefaultFirebaseOptions.currentPlatform` throws on
other platforms). Supporting another platform is an explicit decision that
includes re-running FlutterFire configuration.

Package APIs and implementation decisions must be compatible with the versions
actually installed in the project.

Before using an unfamiliar or version-sensitive API, verify it against the
installed package version rather than relying on examples written for older
versions.
---
## Architecture

Splitzy follows Clean Architecture.

The intended dependency direction is:

```
presentation → domain ← data
```

### Domain

Contains pure business logic and business models.

Domain code must not depend on:

- Flutter
- Firebase
- Firestore
- Hive
- Riverpod
- UI widgets

### Data

Contains external implementations such as:

- Firebase/Firestore data sources
- Hive local data sources
- repository implementations
- DTO/data models when required

External framework details must not leak into the domain layer.

### Presentation

Contains:

- screens
- widgets
- UI state
- Riverpod providers/controllers
- presentation-specific models when necessary

Widgets should not contain business logic.

### Core

`core/` contains application-wide infrastructure or genuinely shared code.

A piece of code should not be placed in `core/` merely because it might be
reused someday.

Prefer keeping feature-specific code inside its feature until it is genuinely
shared or application-wide.

The application/root composition layer is allowed to connect features and
application-wide infrastructure.

Dependency instances are created in a central `lib/injection_container.dart`
(app root) and supplied to Riverpod through `ProviderScope` overrides. Riverpod
providers expose them by domain type; no service locator package is used.

---

## State Management

Riverpod 3 with code generation is the approved state-management approach.

Use:

- `@riverpod` functions for providers/derived values where appropriate
- `@riverpod` classes extending the generated notifier base for mutable state
- `keepAlive` only when there is a clear lifecycle reason

Generated provider files must be produced by `build_runner`.

Never manually edit generated `.g.dart` files.

Generated files must be committed together with the source change that produces
them.

Do not introduce another state-management solution.

---

## Navigation

GoRouter is the approved navigation solution.

Navigation is centralized in the app's single router,
`lib/core/router/app_router.dart` (route paths in `lib/core/router/app_routes.dart`),
rather than scattered across individual screens.

Authentication-aware redirects belong to the routing/application layer.

Temporary navigation is allowed only when explicitly approved for an intermediate
implementation step. Temporary navigation must be clearly marked and reported.

---

## Models and Serialization

Use Freezed for immutable models where appropriate.

Use json_serializable for data serialization.

Generated files:

- `.freezed.dart`
- `.g.dart`

must never be edited manually.

Run code generation after changes that require generated output:

```bash
dart run build_runner build --force-jit
```

`--force-jit` is required: without it, compiling the build script fails with
"`dart compile` does not support build hooks". The installed `build_runner` (2.15.1)
no longer accepts `--delete-conflicting-outputs` (it is ignored with a warning).

Generated files are part of the source change and must be reviewed and committed
with it.

---

## Firebase

Firebase Authentication and Cloud Firestore are the approved backend services.
Firebase Crashlytics is the approved crash-reporting service and is already
integrated.

Firebase-specific code belongs in the data/infrastructure side of the application.

Do not expose Firebase-specific types in the domain layer.

Firebase errors must be translated into application/domain-appropriate errors
before crossing out of the data layer.

Secrets must never be committed. The Firebase configuration files
(`android/app/google-services.json`, `lib/firebase_options.dart`, `firebase.json`, and
`ios/Runner/GoogleService-Info.plist` if iOS is ever added) are **not committed**: the
repository is public. They are git-ignored and exist only locally. They are client
configuration rather than secrets — access is protected by Firebase Security Rules and
the registered SHA fingerprints — but are kept out of the public repository anyway.

On a new machine or clone, regenerate them with `flutterfire configure` (project
`splitzy-f611f`, Android only), or copy them from an existing setup. Run
`flutterfire configure` only when the developer asks (see
`.claude/rules/project-scope.md`).

Google Sign-In (Android) requires, in the Firebase project: the Google provider enabled
in Firebase Authentication, and the SHA-1 (required) and SHA-256 fingerprints of the
signing key registered for `com.splitzy.app`. `android/app/google-services.json` must be
downloaded after that, so it contains a web OAuth client (`client_type: 3`). Every new
signing key (e.g. a release key) needs its fingerprints registered and a refreshed file.

The approved Firestore data model and security approach are documented in
`.claude/rules/architecture.md` → Firestore data model. The security rules live in
`firestore.rules` (committed). They are deployed by pasting the file into the Firebase
console (Firestore Database → Rules → Publish); there is no Firebase CLI setup. Any
change to `firestore.rules` must be republished, and the developer is told so.

---

## Local Cache

Hive is the approved local cache.

Firestore remains the source of truth for synchronized application data.

Hive must:

- remain behind data-layer abstractions
- not be accessed directly from presentation
- not become a second source of truth
- be used only where offline/read-performance requirements justify it

The exact cache policy must be defined before implementing offline persistence.

---

## Money and Expense Calculations

Money must never be represented using `double`.

Store monetary values as integer minor units plus a currency code.

Example:

100.50 EGP → 10050 piastres.

All calculations involving:

- equal splits
- custom splits
- balances
- settlements

must be deterministic and testable as pure Dart logic.

Money calculations belong outside widgets.

Decided (Money, Open Decision #1):

- Currency: EGP only, app-wide. Other currencies are future work.
- Representation: integer piastres (`int`) plus the currency code.
- Expense amount: at least 1 piastre, at most EGP 1,000,000.
- Payer: exactly one member pays the whole expense.
- Split types, chosen per expense:
  - equal: amount ÷ members; leftover piastres go one each to the first members in the
    order they were added to the group;
  - custom amounts: every share ≥ 0 and the shares sum to the amount exactly, otherwise
    the expense is rejected.
- Balance of a member = total they paid − total of their shares. Positive: they are owed.
  Negative: they owe. A group's balances always sum to zero.
- Display: `EGP 1,234.50`, by a small tested pure-Dart formatter (no formatting package).
- Settlements (recording a payment) are future work.

---

## UI / Design System

The application uses a centralized design system.

Use the existing:

- `AppColors`
- `AppBrandColors`
- `AppTextStyles`
- `AppSpacing`
- `AppRadius`
- `AppSizes`
- `AppTheme`
- `AppImages`

Do not introduce repeated hard-coded colors, spacing, radii, sizes or typography
when an existing design-system value applies.

Hex color values belong in the centralized color definitions.

Widgets should consume theme/design-system values rather than directly depending
on raw color constants.

If a visual value is genuinely screen-specific, keep it local and explain why.

---

## Reference-Driven UI

When implementing a screen that has a design reference:

1. Read the actual reference file from `docs/design/references/`.
2. Do not rely on a textual description of the image when the actual reference
   is available.
3. Match the reference's visual hierarchy, spacing, composition and assets.
4. Map colors to the existing design system whenever possible.
5. Use approved assets through `AppImages`.
6. Do not place reference images inside the application bundle.
7. Verify the implementation on an emulator/device.
8. Report meaningful differences between the implementation and the reference.

Reference images are design sources, not runtime assets.

---

## Responsive UI

UI must work across different screen sizes.

At minimum, consider:

- 320×568
- 390×844
- 1024×768
- short-height devices
- increased text scale

Use:

- `SafeArea` where appropriate
- scrolling when content can exceed available height
- centralized sizing constants
- constraints instead of fragile fixed positioning

Do not allow content to:

- overflow
- become inaccessible
- sit behind decorative elements
- disappear on short screens

Reference-based positioning must remain responsive.

---

## Animations

Animations should improve clarity and polish without distracting from the task.

Use the established animation pattern where applicable.

Animations must respect reduced-motion settings.

When reduced motion is requested:

- entrance animations should be skipped or completed immediately
- route transitions should not introduce unnecessary motion

Do not use arbitrary `Timer`/`Future.delayed` calls solely to control visual
animation timing when a testable animation mechanism can be used instead.

---

## Accessibility

Accessibility is part of the UI definition of done.

Consider:

- meaningful semantic labels
- appropriate button semantics
- decorative elements excluded from semantics
- decorative elements not intercepting interaction
- readable contrast
- text scaling
- reduced motion
- no inaccessible overflow

Do not add semantic labels that duplicate visible text unnecessarily.

---

## Testing

Core business logic must be tested.

Especially test:

- money calculations
- equal splitting
- custom split validation
- balances
- settlements
- important state transitions

Unit tests should use pure Dart logic whenever possible.

Do not use real Firebase services in unit/widget tests.

Use mocktail for mocking where mocks are necessary.

Widget tests should verify meaningful user-visible behavior rather than implementation
details.

Tests must be capable of failing when the behavior they cover is broken.

Do not delete or weaken a test simply because it becomes inconvenient.

A test may be removed only when the behavior it covers was intentionally removed,
or the test is demonstrably invalid (e.g. it cannot fail). Report every removal and
its reason.

---

## Dependencies

Do not add dependencies without:

1. explaining why the dependency is necessary
2. identifying whether it is runtime or development-only
3. checking compatibility with the installed Flutter/Dart versions
4. considering whether the existing stack can solve the problem
5. receiving developer approval when required by project rules

Do not add a package merely for convenience.

The currently approved dependencies are already listed in `pubspec.yaml`.

---

## Assets

Application assets are centralized through `AppImages`.

Use the centralized asset paths rather than repeating raw asset strings throughout
the application.

Design/reference files belong under:

```
docs/design/references/
```

Design references are committed to Git (decided), so the design source travels with the
code. They are never bundled into the app.

Runtime assets belong under:

```
assets/
```

Do not duplicate assets unnecessarily.

---

## Environment Variables and Secrets

`.env` is local configuration and must not contain secrets that cannot safely be
exposed to a client application.

`.env` must not be committed.

`.env.example` should document required configuration without containing real
secrets.

Never hard-code API keys, credentials or private configuration into source code.

---

## Code Quality

Before considering a change complete:

```bash
dart format <changed files>
flutter analyze
flutter test
```

Run code generation when required:

```bash
dart run build_runner build --force-jit
```

Install dependencies with `flutter pub get`.

Do not format unrelated files.

Do not ignore analyzer warnings or errors.

Do not use `!` merely to silence null-safety problems.

Prefer explicit null handling.

Prefer `const` constructors/widgets where applicable.

Keep widgets focused on presentation.

---

## Git / GitHub

Git history must remain understandable.

Use a separate branch for a feature/step when the workflow calls for it.

Use meaningful Conventional Commit messages.

Example:

```
feat(ui): implement loading splash and login screens
```

Do not commit, push, merge or open pull requests unless the developer explicitly
asks.

Before a commit, verify:

- the diff contains only intended changes
- generated files are included when required
- tests pass
- analyzer is clean

Never hide unrelated changes inside a feature commit.

---

## AI-First Workflow

Claude must follow this workflow:

1. Inspect the current project state.
2. Understand the requested change.
3. Identify affected files and architectural boundaries.
4. Plan the smallest reasonable implementation.
5. Identify new dependencies, patterns, layers or shared abstractions.
6. Ask for approval when project rules require it.
7. Implement in small reviewable batches.
8. Run formatting, analysis and tests.
9. Inspect runtime behavior when UI is involved.
10. Report exactly what changed.
11. Explain important architectural and implementation decisions.
12. Stop at the approved scope.

Claude must not:

- continue into the next feature without approval
- silently expand scope
- invent requirements
- hide uncertainty
- modify unrelated code
- edit generated files manually
- delete tests to make verification pass

The developer reviews the diff and owns the final decision on shipped code.

---

## Rule Files

Detailed rules are stored in:

- `.claude/rules/project-scope.md` — scope control, change hygiene, dependencies, secrets, Git
- `.claude/rules/flutter-dart.md` — Flutter/Dart, Riverpod, GoRouter, Freezed conventions
- `.claude/rules/architecture.md` — Clean Architecture layers and dependency boundaries
- `.claude/rules/testing.md` — what must be tested and how
- `.claude/rules/ai-workflow.md` — how Claude plans, implements, verifies and reports work

If this file and a detailed rule appear to conflict, stop and report the conflict
rather than silently choosing one.

Keep this file as the high-level source of truth and keep detailed implementation
rules in the appropriate scoped rule file.

---

## Definition of Done

A change is not considered complete merely because the code compiles.

The relevant definition of done includes:

- requested behavior implemented
- architecture boundaries respected
- design/reference requirements satisfied
- responsive behavior checked
- accessibility/reduced-motion requirements considered
- tests added/updated where required
- generated code updated when required
- `flutter analyze` clean
- `flutter test` passing
- runtime behavior verified for UI changes
- no unrelated changes
- developer-facing report provided

---

## When Uncertain

Do not guess when a decision affects:

- architecture
- dependencies
- data model
- security
- navigation architecture
- state management
- money calculations
- Firebase behavior
- shared/core abstractions

Explain the uncertainty and ask for a decision.
