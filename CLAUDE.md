# Splitzy

Splitzy is a Flutter expense-splitting app. Users sign in, form groups, record shared
expenses, and see who owes whom.

## Current phase

**Setup only.** The AI-first workflow and project rules are being established.
No application features are implemented yet. Do not build features until the developer
explicitly asks for a specific one.

## Agreed stack

| Concern            | Choice                                           |
| ------------------ | ------------------------------------------------ |
| UI framework       | Flutter                                          |
| State management   | Riverpod                                         |
| Authentication     | Firebase Authentication (incl. Google Sign-In)   |
| Database           | Cloud Firestore                                  |
| Navigation         | GoRouter                                         |
| Architecture       | Clean Architecture (domain / data / presentation)|
| Models             | Freezed + json_serializable                      |

These are decisions, not suggestions. Do not propose alternatives unless asked.
Note that none of these packages are installed yet; adding each one is its own reviewed change.

## Non-negotiables

1. **Every change must be reviewable and understandable by the developer.** If a diff cannot
   be explained in a few sentences, it is too big — split it.
2. **Small, focused diffs.** One concern per change.
3. **No new dependencies without a written justification** and explicit developer approval.
4. **Do not modify unrelated files.** No drive-by refactors, reformatting, or renames.
5. **Core business logic must be testable** — pure Dart, no Flutter/Firebase imports.
6. **Never commit, push, or touch Firebase config/secrets** unless explicitly asked.

## Detailed rules

Rules live in `.claude/rules/` and are loaded automatically:

- `project-scope.md` — scope control, what is in/out of bounds, change hygiene
- `flutter-dart.md` — Flutter/Dart, Riverpod, GoRouter, Freezed conventions
- `architecture.md` — Clean Architecture layers and dependency boundaries
- `testing.md` — what must be tested and how
- `ai-workflow.md` — how Claude plans, implements, verifies, and reports work

## Commands

```bash
flutter pub get          # install dependencies
flutter analyze          # static analysis — must be clean before a change is done
dart format .            # format (only files you changed)
flutter test             # run all tests
```

Code generation (once Freezed / json_serializable / riverpod_generator are added):

```bash
dart run build_runner build --delete-conflicting-outputs
```
