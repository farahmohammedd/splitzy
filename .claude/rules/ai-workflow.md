# AI-First Development Workflow

The developer owns every line that ships. Claude's job is to produce changes the developer
can fully review, understand, and explain. Speed never outranks understanding.
High-level source of truth: `CLAUDE.md`.

## 1. Understand

- Restate the task in one or two sentences and confirm scope if anything is ambiguous.
- Inspect the current project state and read the relevant existing code before writing
  anything.
- **Read the applicable rules before planning.** `architecture.md`, `flutter-dart.md` and
  `testing.md` are path-scoped (they auto-load only when Dart files are touched), but they are
  required rules: read them when planning or making any change that touches Dart code
  (`lib/`, `test/`, `integration_test/`).
- Check `CLAUDE.md` → Open Decisions. If the task depends on an open decision, stop and ask
  instead of assuming an answer.
- Identify which layer(s) and files the change touches. If that list includes anything
  outside the task's obvious scope, ask first.

## 2. Plan (before editing)

For anything beyond a trivial edit, present a short plan:

- Files to create / modify (and confirm no unrelated files are touched).
- Any new dependency, with justification (see `project-scope.md`).
- Any new pattern, layer, folder or shared abstraction — including shared refactoring of
  existing code (see `project-scope.md`).
- Any approved temporary scaffolding the step will add or remove.
- Tests to be added or updated.
- Any architectural decision being made, with the alternative considered.
- The package versions checked for version-sensitive APIs (see below).

### Approval means approval

Stop and wait for **explicit developer approval** before implementing:

- a new dependency;
- a new architectural pattern, layer or folder;
- a new shared abstraction (e.g. a new `core/` widget or theme-wide change);
- a significant architectural change.

Mentioning such a change in a plan or report does **not** count as approval. If the need
only becomes clear mid-implementation, stop, explain it, and wait.

### Package / API versions

Before using a version-sensitive API, verify it against the version actually installed
(`pubspec.lock` / `pubspec.yaml`, the package's installed README/CHANGELOG, or docs for that
exact version) — not against memory, old tutorials or examples. This matters especially for
the currently installed modern majors of Riverpod, GoRouter, Google Sign-In, the Firebase
packages and Freezed. If unsure about an API, say so.

## 3. Implement in reviewable steps

The goal is **reviewability, not an arbitrary line count**.

- Logic/architecture changes: keep each change small enough to review in one sitting; split
  larger work into sequential changes, each compiling and passing tests.
- UI screen implementations may naturally be larger, but must still be divided into logical
  reviewable parts where practical (e.g. shared extraction, background/decoration, screen,
  tests, wiring) — each identifiable in the report — and contain no unrelated work.
- Write the test alongside (or before) business logic.
- Prefer clear, boring code over clever code. No unexplained abstractions.
- Follow existing patterns in the codebase; do not introduce a second way of doing something.

## 4. Verify

Before reporting done:

1. `dart format` on changed files only.
2. `flutter analyze` — zero issues.
3. `flutter test` — all passing.
4. Run codegen if annotated classes changed.
5. For UI changes, inspect runtime behavior on an emulator/device.
6. Review your own diff (`git diff`) and remove anything unrelated to the task.

## 5. Report

End every change with a concise report:

- **What changed** — files created/modified, one line each; shared refactoring and temporary
  scaffolding listed separately.
- **Why** — the reasoning behind non-obvious decisions.
- **How to verify** — commands run and their actual results (never claim a pass you did not
  observe).
- **Follow-ups** — anything noticed but deliberately left out of scope, and any unresolved
  decision.

Then stop at the approved scope; do not continue into the next feature without approval.

## Reviewability guarantees

- No hidden changes: everything Claude touched appears in the report.
- No unexplained code: if the developer asks "why is this here?", there is a clear answer.
- When teaching moments arise (a Riverpod, Freezed, or architecture concept used for the
  first time), briefly explain it so the developer can maintain it independently.
- If Claude is uncertain about a fact (an API, a package behavior), it says so rather than
  guessing.
