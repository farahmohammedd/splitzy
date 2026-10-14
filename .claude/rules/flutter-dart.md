---
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
  - "integration_test/**/*.dart"
---

# Flutter / Dart Conventions

**Required project rules**, not optional guidance. This file is path-scoped and loads
automatically when Dart files are touched. Read it when planning or making any change that
touches Dart code (`lib/`, `test/`, `integration_test/`) — see `ai-workflow.md`.
High-level source of truth: `CLAUDE.md`.

## General Dart

- Follow [Effective Dart](https://dart.dev/effective-dart) and the repo's `analysis_options.yaml`.
  `flutter analyze` must report zero issues before a change is considered done.
- Do not silence lints with `// ignore:` without a comment explaining why.
- Prefer `final` locals and immutable data. Avoid `late` unless initialization is guaranteed.
- Never use `!` (null assertion) to paper over a nullability question — handle the null case.
- Use `sealed` classes and exhaustive `switch` expressions for closed sets of states/results.
- Naming: files `snake_case.dart`, types `UpperCamelCase`, members `lowerCamelCase`.
  One public top-level type per file where practical; file name matches the main type.
- Keep functions short and single-purpose. No dead code, commented-out code, or debug `print`s.

### Imports

One convention (not currently enforced by a lint — follow it manually):

- Use `package:splitzy/...` imports when crossing between top-level areas: the `lib/` root
  (`main.dart`, `app.dart`), `core/`, and each `features/<feature>/`. Tests always use
  `package:` imports.
- Relative imports are allowed only within the same area (e.g. `core/widgets/` →
  `core/theme/`, or files inside one feature).

## User-facing text

- No localization package for now; adding one is an explicit architectural decision.
- Until then, user-facing strings live in the widget that displays them, with two
  deliberate exceptions: error texts live on the error type itself — `Failure.message`
  (`core/error/failures.dart` and each feature's failure family) and
  `ValidationError.message` (`domain/validation/`). Widgets show them through
  `messageFor(error)` / `.message` and never build error texts of their own. This is
  temporary: when localization is decided (`CLAUDE.md` → Open Decisions #6), moving these
  texts to the presentation layer is its own planned step.
- If the same string is needed in more than one place, define it once rather than
  duplicating it.

## Widgets

- Prefer `StatelessWidget` / `ConsumerWidget`. Use stateful widgets only for genuinely local,
  ephemeral UI state (animation controllers, text controllers, focus).
- Extract widgets into classes, not helper methods that return `Widget`.
- Use `const` constructors wherever possible.
- Widgets contain **no business logic** and make **no direct Firebase/Firestore/Hive calls**.

## Design system

The existing Splitzy design system is authoritative: `AppColors`, `AppBrandColors`,
`AppTextStyles`, `AppSpacing`, `AppRadius`, `AppSizes`, `AppTheme`, `AppImages`.

- Raw hex values belong only in `core/theme/app_colors.dart` (`AppColors`; third-party brand
  marks such as the Google "G" use `ThirdPartyBrandColors` there, never for app UI).
- Widgets consume theme values — `Theme.of(context).colorScheme`, `.textTheme`,
  component themes — and `context.brandColors` for brand colors with no Material slot. Only
  the theme itself (and tests) reference `AppColors` directly.
- Do not repeat design-system values inside screens: use `AppSpacing`, `AppRadius`,
  `AppSizes` and `TextTheme` styles. Opacity variants of theme colors are fine via a named
  constant.
- Genuinely screen-specific values (e.g. decorative shape geometry measured from a reference)
  may stay local when justified with a short comment.
- If the same visual style is needed by multiple screens, put it in the theme/design system
  instead of repeating per-screen overrides.
- Runtime asset paths come only from `AppImages`.

## Reference-driven UI

Reference images in `docs/design/references/` are **design sources, not runtime assets**:
they stay out of `assets/` and are never bundled. When a screen has a reference:

1. Read the actual reference file before implementation.
2. Check whether it has changed since it was last used (e.g. modification time/size).
3. Treat it as the visual source of truth — not a textual description of it.
4. Measure/inspect composition, proportions and spacing (e.g. sample pixel positions and
   colors) rather than guessing.
5. Map every color to the design system; propose a design-system change if none fits.
6. Use runtime assets through `AppImages` (check that PNGs have real transparency).
7. Verify the result on an emulator/device.
8. Report meaningful remaining differences from the reference.

## Responsive UI

At minimum verify each screen at **320×568, 390×844, 1024×768, 320×568 with increased text
scale (2×)**, and on the **short 360×640 emulator** when practical — widget tests cover
overflow and reachability; the device covers real-font fit.

- Use `SafeArea` where appropriate; decorations may extend edge to edge behind system bars.
- Allow scrolling whenever content can exceed the available height.
- Size content from layout constraints with clamps; cap wide layouts with
  `AppSizes.maxContentWidth`.
- Avoid fragile percentage positioning of content. Background decorations may be placed as
  fractions of the screen, but a decoration that must stay clear of specific content is
  anchored to that content instead.
- Content must not overflow, sit behind decorations, or disappear on short screens; important
  controls (primary actions, form fields) must remain reachable.
- A breakpoint/threshold used in more than one place becomes a named constant rather than a
  duplicated magic number.

## Animations & reduced motion

Animations are subtle and purposeful. The established pattern:

- One `AnimationController` per screen, sliced into staggered `Interval`s.
- Use the shared `FadeSlideIn` widget where a fade-and-slide entrance fits. Other entrance
  effects (e.g. the Launch screen's fade + scale logo) may use Flutter's transition widgets
  directly when they suit the design better; do not duplicate `FadeSlideIn` locally.
- Read `MediaQuery.disableAnimationsOf(context)`. When reduced motion is requested, entrances
  are skipped/completed immediately (pass `AlwaysStoppedAnimation<double>(1)`), and route
  transitions use no motion (e.g. `Duration.zero`).
- An animation that also gates behavior (e.g. a minimum loading duration) uses
  `AnimationBehavior.preserve` so reduced-motion settings cannot shorten the behavior.
- Do not use `Timer`/`Future.delayed` only to control visual timing when a testable animation
  approach can be used.
- Dispose every controller.

## Accessibility

Accessibility is part of the UI definition of done:

- Meaningful images and icon-only buttons have semantic labels/tooltips; buttons keep their
  button semantics.
- Decorative elements are wrapped in `ExcludeSemantics` and do not intercept interaction
  (`IgnorePointer`).
- Do not add semantic labels that duplicate visible text (exclude the duplicate instead).
- Maintain sufficient contrast (e.g. text on gold is dark, never white).
- Support text scaling: labels wrap rather than overflow.
- Respect reduced motion (above); no inaccessible overflow.

## Riverpod

Riverpod 3 is the state-management solution; do not introduce another.

- Use `riverpod_generator` (`@riverpod`):
  - `@riverpod` functions for providers/derived values where appropriate;
  - `@riverpod` classes extending the generated notifier base (`_$Name`) for mutable state.
- Use `keepAlive` only when there is a clear lifecycle reason, and document that reason in a
  comment.
- Generated `.g.dart` files are produced by `build_runner`, never edited by hand, and
  committed with the source change that produces them.
- Use `ref.watch` for reactive dependencies (e.g. in `build`); use `ref.read` for one-time or
  imperative access (e.g. in callbacks). Never `ref.read` inside `build`.
- Dependency instances are created in `lib/injection_container.dart` and supplied through
  `ProviderScope` overrides; providers expose them by domain type and build controllers and
  derived state on top (see `architecture.md`). Domain classes never know Riverpod exists.
- Model async UI state with `AsyncValue` and handle loading, error, and data explicitly.
- Keep providers small and focused; do not create global mutable singletons.

## Presentation patterns

The auth feature established these; new features follow them.

### Controllers

An operation the user triggers (log in, register, sign out, ...) has one `@riverpod`
controller class in `presentation/providers/<operation>_controller.dart`, auto-disposed
(no `keepAlive`), with this shape:

```dart
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {} // idle: AsyncData(null)

  Future<void> logIn({required String email, required String password}) async {
    if (state.isLoading) return; // ignore repeated submits
    state = const AsyncLoading();
    final result = await runGuarded(
      () => ref.read(signInUseCaseProvider)(email: email, password: password),
      reporter: ref.read(errorReporterProvider),
      reason: 'Logging in',
    );
    if (ref.mounted) state = result; // success may already have disposed it
  }
}
```

- State is `AsyncValue<void>`: idle/done, loading, or an error holding a `Failure` (see
  `architecture.md` → Error handling).
- It calls a use case when one exists, otherwise the repository.
- It **never navigates**. A successful operation changes app state (e.g. the auth state)
  and the router's `redirect` moves the user.
- When several screens start the same operation and must not share its state, use a
  Riverpod **family**: `build` takes a parameter (e.g. `build(GoogleSignInOrigin origin)`)
  and each screen watches its own instance (`googleSignInControllerProvider(origin)`).
- Each controller has a unit test with `ProviderContainer.test` covering success, loading,
  an expected failure, an unexpected error (reported, generic message) and the
  repeated-submit guard.

### Page / Screen split

A route's UI is two widgets in `presentation/screens/`, each file named after its type:

| | `<Name>Page` (`<name>_page.dart`) | `<Name>Screen` (`<name>_screen.dart`) |
| --- | --- | --- |
| Type | `ConsumerWidget` | `StatelessWidget` / `StatefulWidget` |
| Knows Riverpod | yes: watches controllers, `ref.read` in callbacks | no |
| Job | connects controllers to the screen: forwards intents, passes `isSubmitting` and `errorMessage: messageFor(error)` down | layout, form fields and validation, local UI state; every action is a callback |
| Tested by | the router tests (`test/core/router/app_router_test.dart`) | its own widget test, with no providers |

- A Page that runs more than one operation shows one error at a time: starting an attempt
  resets the others with `ref.invalidate(...)`, so the message shown is the latest one.
- A screen with no controller (e.g. Splash, Launch) has no Page.
- **Decided**: cross-feature connector widgets (`HomeRoute`, `GroupsRoute`,
  `NewGroupRoute`, `AddExpenseRoute`, `GroupDetailsRoute`) live in
  `lib/core/router/home_shell.dart`, part of the app root.
- **Unresolved**: where presentation input models (e.g. `SignUpDetails`) live. Decide
  before adding another one.

### Navigation

- Screens and Pages never call `context.go`/`push`/`pop` themselves. Navigation is passed
  in as callbacks (`onBack`, `onSignUp`, ...), wired in `app_router.dart`.
- Auth-driven moves happen only through the router's `redirect` (see GoRouter).

## GoRouter

- Define routes in one place; reference them by named route / typed constants, not raw path
  strings scattered through widgets.
- Auth-based redirects live in the router's `redirect`, driven by an auth-state provider —
  not in individual screens.
- GoRouter is in place: the app's single router is `lib/core/router/app_router.dart`, with
  route paths in `lib/core/router/app_routes.dart`. All navigation goes through it; any new
  temporary navigation requires explicit approval (see `project-scope.md`).

## Freezed + json_serializable

- Use Freezed for immutable models and union/sealed states; use json_serializable for
  Firestore/JSON mapping.
- Generated files (`*.g.dart`, `*.freezed.dart`) are never hand-edited.
- After changing an annotated class, run
  `dart run build_runner build --force-jit` (see `CLAUDE.md`) and include regenerated output
  in the same change.
- Serialization annotations (`@JsonSerializable`, `fromJson`) belong on **data-layer DTOs**,
  not on domain entities. See `architecture.md`.

## Error handling

The full error path, reporting rules and how to add errors to a feature are in
`architecture.md` → Error handling. In short:

- Do not let Firebase exceptions leak past the data layer: data sources map them to
  `AppException`s, repositories map those to `Failure`s.
- Controllers use `runGuarded`; widgets show `messageFor(error)`.
- Never swallow errors silently (`catch (_) {}`); handle, map, report or rethrow.
