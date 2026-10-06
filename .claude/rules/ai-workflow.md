# AI-First Development Workflow

The developer owns every line that ships. Claude's job is to produce changes the developer
can fully review, understand, and explain. Speed never outranks understanding.

## 1. Understand

- Restate the task in one or two sentences and confirm scope if anything is ambiguous.
- Read the relevant existing code and rules before writing anything.
- Identify which layer(s) and files the change touches. If that list includes anything
  outside the task's obvious scope, ask first.

## 2. Plan (before editing)

For anything beyond a trivial edit, present a short plan:

- Files to create / modify (and confirm no unrelated files are touched).
- Any new dependency, with justification (see `project-scope.md`).
- Tests to be added or updated.
- Any architectural decision being made, with the alternative considered.

Wait for approval when the change adds a dependency, introduces a new pattern or folder,
crosses a layer boundary, or is larger than a small, focused diff.

## 3. Implement in small steps

- Keep each diff small enough to review in one sitting (aim for well under ~300 changed
  lines of hand-written code; generated files excluded). Split larger work into sequential
  changes, each one compiling and passing tests.
- Write the test alongside (or before) business logic.
- Prefer clear, boring code over clever code. No unexplained abstractions.
- Follow existing patterns in the codebase; do not introduce a second way of doing something.

## 4. Verify

Before reporting done:

1. `flutter analyze` — zero issues.
2. `flutter test` — all passing.
3. Run codegen if annotated classes changed.
4. Review your own diff (`git diff`) and remove anything unrelated to the task.

## 5. Report

End every change with a concise report:

- **What changed** — files created/modified, one line each.
- **Why** — the reasoning behind non-obvious decisions.
- **How to verify** — commands run and their actual results (never claim a pass you did not
  observe).
- **Follow-ups** — anything noticed but deliberately left out of scope.

## Reviewability guarantees

- No hidden changes: everything Claude touched appears in the report.
- No unexplained code: if the developer asks "why is this here?", there is a clear answer.
- When teaching moments arise (a Riverpod, Freezed, or architecture concept used for the
  first time), briefly explain it so the developer can maintain it independently.
- If Claude is uncertain about a fact (an API, a package behavior), it says so rather than
  guessing.
