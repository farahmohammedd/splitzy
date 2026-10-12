# Project Conventions & Scope

High-level source of truth: `CLAUDE.md`. This file details scope, change hygiene,
dependencies, secrets, Git and domain conventions. If it ever contradicts `CLAUDE.md`, stop
and report the conflict.

## Scope control

- Do exactly what the current task asks — nothing more. If you notice something else worth
  doing, mention it in your report; do not do it.
- Do not implement application features (auth, groups, expenses, balances, settle-up, etc.)
  until the developer explicitly requests that specific feature.
- Do not create speculative scaffolding: no empty folders, placeholder classes, "for later"
  abstractions, or TODO-driven stubs — except approved temporary scaffolding (below).
- If a task is ambiguous or would require touching files outside its obvious scope, stop and
  ask before proceeding.

## Temporary scaffolding

Temporary code (e.g. temporary navigation, placeholder destinations, no-op callbacks) is
allowed **only when the developer explicitly requests or approves it** for an intermediate
step. When it is approved:

- Keep it clearly identifiable (a marked section or clearly named class).
- Put it in the smallest appropriate area — e.g. all temporary navigation wiring lives in the
  app root, not spread across screens.
- Add a comment where needed saying what will replace it.
- List it in the step report.
- Never silently turn temporary code into permanent architecture; replacing it is its own
  planned step.

## Shared refactoring

Extracting shared UI or infrastructure is allowed when the **current approved task genuinely
requires it** (e.g. a widget or animation now used by multiple screens, or a style repeated
across screens that belongs in the theme). It must:

- be identified in the plan **before** implementation — a new shared abstraction needs
  approval (see `ai-workflow.md`);
- stay scoped to what the current task needs — not an excuse for unrelated cleanup;
- be reported separately from the feature work in the final summary, including every
  existing file it touched.

## Change hygiene

- **One concern per change.** A dependency addition, a refactor, and a feature are separate
  concerns; keep them in separately reviewable parts.
- **Do not modify unrelated files.** No drive-by reformatting, import reordering, renames, or
  comment edits in files the task does not require.
- Run `dart format` only on files you changed — never on the whole repo as a side effect.
- Never edit generated files (`*.g.dart`, `*.freezed.dart`); change the source and regenerate.

### Platform folders

`android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`:

- Do not hand-edit platform files as part of unrelated work.
- Tool-generated platform changes caused by approved dependency or Flutter commands (e.g.
  regenerated plugin registrants after `flutter pub get`) are allowed and must be reported.
- Hand edits to platform folders require explicit scope/approval when actually needed.

## Dependencies

The approved dependencies are those in `pubspec.yaml`. Adding a package requires, **before**
the change is made:

1. Why it is necessary, and why the SDK / existing stack cannot solve the problem.
2. Whether it is a runtime or dev dependency.
3. Compatibility with the installed Flutter/Dart versions (see `CLAUDE.md`).
4. Package health: maintainer, popularity, last publish date, platform support.
5. Explicit developer approval.

Do not add a package merely for convenience. Never upgrade, downgrade, or remove existing
dependencies as a side effect.

## Secrets, environment & Firebase

- Never hard-code API keys, credentials or private configuration in source code, and never
  commit or print service-account files or tokens.
- `.env` is local configuration and is git-ignored — never commit it. A `.env.example` with
  placeholder values only may be committed to document required keys.
- `flutter_dotenv` bundles `.env` into the app, so `.env` must hold nothing that is unsafe to
  expose to a client. Conversely, do not describe inherently public client configuration as
  a secret.
- Do not run `flutterfire configure` or create/modify `firebase_options.dart`,
  `google-services.json`, or `GoogleService-Info.plist` unless explicitly asked. These
  files are git-ignored and never committed (decided — the repository is public; see
  `CLAUDE.md` → Firebase). Never force-add them (`git add -f`).

## Git / GitHub

- Do not commit, push, merge, open pull requests, or rewrite history unless the developer
  explicitly asks.
- Use a dedicated branch for feature/step work substantial enough to benefit from isolation
  and review. Propose the branch name (e.g. `feat/login-ui`) in the plan; create it only once
  the plan is approved.
- Use Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`, with an
  optional scope such as `feat(ui):`) and explain *why*, not just *what*.
- Before committing, inspect `git status` and `git diff`: only intended changes, generated
  files included when required, tests passing, analyzer clean. Keep unrelated changes out of
  the commit.

## Domain conventions

- **Money is never a `double`.** Represent amounts as integer minor units (e.g. piastres,
  cents) plus a currency code. Money calculations are pure Dart, deterministic and tested.
- Money rules are decided — see `CLAUDE.md` → Money and Expense Calculations (currency,
  limits, payer, equal/custom splits, balances, display).
- Use clear domain language consistently: `Group`, `Member`, `Expense`, `Split`, `Balance`,
  `Settlement`. Do not introduce synonyms for existing concepts.
