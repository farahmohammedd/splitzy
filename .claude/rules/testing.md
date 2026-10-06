---
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
  - "integration_test/**/*.dart"
---

# Testing Conventions

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

- `test/` mirrors `lib/`: `lib/features/x/domain/foo.dart` → `test/features/x/domain/foo_test.dart`.
- Test files end in `_test.dart`.
- Use `group()` per unit and descriptive test names stating behavior:
  `'splits remainder cents to the first members when amount is not divisible'`.
- Arrange / Act / Assert, one behavior per test.

## Practices

- Domain tests are pure Dart — no Flutter bindings, no Firebase, no network.
- Never hit real Firebase in unit or widget tests. Use fakes or mocks behind repository
  interfaces. Choosing a mocking/fake package (e.g. `mocktail`, `fake_cloud_firestore`) is a
  dependency decision and follows the justification rule in `project-scope.md`.
- Override Riverpod providers in tests via `ProviderContainer(overrides: ...)` /
  `ProviderScope(overrides: ...)`.
- Tests must be deterministic: no reliance on `DateTime.now()`, randomness, or ordering —
  inject clocks/ID generators where needed.
- Cover edge cases for money: zero, single member, uneven division, large amounts,
  negative/invalid input.
- Do not delete, skip, or weaken an existing test to make a change pass. If a test seems
  wrong, explain why and ask.

## Definition of done

`flutter analyze` is clean and `flutter test` passes. Report the actual results — if tests
fail or were not run, say so explicitly.
