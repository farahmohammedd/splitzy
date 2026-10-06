# Project Conventions & Scope

## Scope control

- Do exactly what the current task asks — nothing more. If you notice something else worth
  doing, mention it in your report; do not do it.
- Do not implement application features (auth, groups, expenses, balances, settle-up, etc.)
  until the developer explicitly requests that specific feature.
- Do not create speculative scaffolding: no empty feature folders, placeholder classes,
  "for later" abstractions, or TODO-driven stubs.
- If a task is ambiguous or would require touching files outside its obvious scope, stop and
  ask before proceeding.

## Change hygiene

- **One concern per change.** A dependency addition, a refactor, and a feature are three
  separate changes.
- **Do not modify unrelated files.** No drive-by reformatting, import reordering, renames, or
  comment edits in files the task does not require.
- Run `dart format` only on files you changed — never on the whole repo as a side effect.
- Never edit generated files (`*.g.dart`, `*.freezed.dart`); change the source and regenerate.
- Never edit platform folders (`android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`)
  unless the task is specifically about platform configuration.

## Dependencies

Adding a package to `pubspec.yaml` requires, **before** the change is made:

1. What problem it solves and why the SDK / existing packages are insufficient.
2. Whether it is a runtime or dev dependency.
3. Package health: maintainer, popularity, last publish date, null-safety, platform support.
4. Explicit developer approval.

The agreed-stack packages (Riverpod, Firebase Auth, Google Sign-In, Firestore, GoRouter,
Freezed, json_serializable and their codegen companions) are pre-approved in principle, but
each is still added in its own focused change when the developer asks for it.

Never upgrade, downgrade, or remove existing dependencies as a side effect.

## Secrets & Firebase

- Never commit or print API keys, service-account files, or tokens.
- Do not run `flutterfire configure` or create/modify `firebase_options.dart`,
  `google-services.json`, or `GoogleService-Info.plist` unless explicitly asked.

## Git

- Do not commit, push, create branches, or rewrite history unless the developer asks.
- When asked to commit, use Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`,
  `test:`, `docs:`) with a message that explains *why*, not just *what*.

## Domain conventions

- **Money is never a `double`.** Represent amounts as integer minor units (e.g. cents) plus a
  currency code. Rounding and remainder distribution in splits must be explicit and tested.
- Use clear domain language consistently: `Group`, `Member`, `Expense`, `Split`, `Balance`,
  `Settlement`. Do not introduce synonyms for existing concepts.
