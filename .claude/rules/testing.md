---
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
  - "integration_test/**/*.dart"
---

# Testing Conventions

**Required project rules**, not optional guidance. This file is path-scoped and loads
automatically when Dart files are touched. Read it when planning or making any change that
touches Dart code (`lib/`, `test/`, `integration_test/`) — see `ai-workflow.md`.
High-level source of truth: `CLAUDE.md`.

## What must be tested

| Code                                         | Requirement                                  |
| -------------------------------------------- | -------------------------------------------- |
| Domain use cases & business rules            | **Required** unit tests, in the same change  |
| Money math (splits, rounding, balances, settlements) | **Required**, including edge cases   |
| Repository implementations / DTO mapping     | Required unit tests with fakes/mocks         |
| Riverpod controllers/notifiers               | Required for non-trivial state transitions   |
| Widgets / screens                            | Widget tests for meaningful behavior and states (loading, error, data) |
| End-to-end flows                             | Integration tests only when explicitly requested |

A change that adds or modifies business logic without tests is **not done**.

## Structure

- `test/` mirrors `lib/`, including the layer subfolders:
  `lib/features/x/domain/usecases/foo.dart` → `test/features/x/domain/usecases/foo_test.dart`.
- Test files end in `_test.dart`.
- Shared test doubles live in `test/helpers/` (e.g. `fake_auth_repository.dart`). They are
  not test files (no `_test.dart` suffix), contain no assertions, and never touch real
  Firebase.
- Use `group()` per unit and descriptive test names stating behavior:
  `'splits remainder cents to the first members when amount is not divisible'`.
- Arrange / Act / Assert, one behavior per test.

## Practices

- Domain tests are pure Dart — no Flutter bindings, no Firebase, no network.
- Never use real Firebase services in unit or widget tests. Use fakes or mocks behind
  repository interfaces; use **mocktail** for mocks where needed. Any other test package
  (e.g. a fake Firestore) is a dependency decision (see `project-scope.md`).
- No test may create Firebase SDK singletons (`FirebaseAuth.instance`, etc.). Tests that
  pump `SplitzyApp` or read container-supplied providers use
  `InjectionContainer(authRepository: FakeAuthRepository(), errorReporter: FakeErrorReporter()).overrides`
  (fakes from `test/helpers/`), or override individual providers.
- Use a hand-written fake for a repository interface shared by many tests (app, router,
  controller tests). Use mocktail mocks to verify interactions in use-case, repository and
  data-source tests. Mocking Firebase SDK classes (`FirebaseAuth`, `User`,
  `UserCredential`) is limited to data-layer and injection-container tests.
- Override Riverpod providers in tests via `ProviderContainer(overrides: ...)` /
  `ProviderScope(overrides: ...)`.
- Tests must be deterministic: no reliance on `DateTime.now()`, randomness, or ordering —
  inject clocks/ID generators where needed.
- Cover edge cases for money: zero, single member, uneven division, large amounts,
  negative/invalid input. In particular (see `CLAUDE.md` → Money):
  - equal split: leftover piastres go to the first members in order; shares always sum
    to the amount;
  - custom split: rejected when shares do not sum to the amount or any share is negative;
  - amount limits: 0, 1 piastre, the maximum, above the maximum;
  - balances: a group's balances always sum to zero.

## Widget tests

- Test meaningful user-visible behavior: what renders, what a tap/entry does, which callback
  fires, how state changes.
- Find widgets by `Key`, semantics, visible text or stable widget types — not by
  implementation internals (e.g. how an image provider is wrapped).
- Do not make assertions depend on internal rendering details.
- Do not assert text-dependent layout fit (e.g. "fits without scrolling") in widget tests:
  the test font's glyph metrics differ from real fonts. Verify that on a device instead;
  widget tests still cover overflow and reachability.
- In widget tests where screen size or layout matters (responsive layouts, overflow,
  reachability, positioning), set the test surface explicitly (`tester.view.physicalSize`,
  `devicePixelRatio`) and reset it with `addTearDown`. Unit tests and widget tests that do
  not depend on size need not set it. Always clear accessibility/text-scale test values you
  set.
- Every test must be capable of failing if the behavior it covers is removed or broken. If a
  test would still pass without the behavior, fix or remove it.

## Changing or removing tests

- Do not delete, skip, or weaken a test to make a change pass, or merely because the
  implementation changed.
- A test may be removed only when the behavior it covers was intentionally removed, or the
  test is demonstrably invalid (e.g. it cannot fail). Report every removal and its reason
  (same rule as `CLAUDE.md`).
- If a test seems wrong, explain why and ask before changing its expectation.

## Definition of done

`flutter analyze` is clean and `flutter test` passes. Report the actual results — if tests
fail or were not run, say so explicitly.
