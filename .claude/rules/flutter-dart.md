---
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
  - "integration_test/**/*.dart"
---

# Flutter / Dart Conventions

## General Dart

- Follow [Effective Dart](https://dart.dev/effective-dart) and the repo's `analysis_options.yaml`.
  `flutter analyze` must report zero issues before a change is considered done.
- Do not silence lints with `// ignore:` without a comment explaining why.
- Prefer `final` locals and immutable data. Avoid `late` unless initialization is guaranteed.
- Never use `!` (null assertion) to paper over a nullability question — handle the null case.
- Use `sealed` classes and exhaustive `switch` expressions for closed sets of states/results.
- Naming: files `snake_case.dart`, types `UpperCamelCase`, members `lowerCamelCase`.
  One public top-level type per file where practical; file name matches the main type.
- Use package imports (`package:splitzy/...`) rather than deep relative paths across layers.
- Keep functions short and single-purpose. No dead code, commented-out code, or debug `print`s.

## Widgets

- Prefer `StatelessWidget` / `ConsumerWidget`. Use stateful widgets only for genuinely local,
  ephemeral UI state (animation controllers, text controllers, focus).
- Extract widgets into classes, not helper methods that return `Widget`.
- Use `const` constructors wherever possible.
- Widgets contain **no business logic** and make **no direct Firebase/Firestore calls**.
- Pull colors, text styles, and spacing from `Theme.of(context)`; avoid hard-coded magic values.

## Riverpod

- Providers are the composition root: they wire data sources → repositories → use cases →
  controllers. Domain classes never know Riverpod exists.
- Use `ref.watch` in `build`, `ref.read` in callbacks. Never `ref.read` inside `build`.
- Model async UI state with `AsyncValue` and handle loading, error, and data explicitly.
- Keep providers small and focused; do not create global mutable singletons.
- Whether to use `riverpod_generator` (`@riverpod`) is decided when Riverpod is added — once
  decided, use one style consistently.

## GoRouter

- Define routes in one place; reference them by named route / typed constants, not raw path
  strings scattered through widgets.
- Auth-based redirects live in the router's `redirect`, driven by an auth-state provider —
  not in individual screens.

## Freezed + json_serializable

- Use Freezed for immutable models and union/sealed states; use json_serializable for
  Firestore/JSON mapping.
- Generated files (`*.g.dart`, `*.freezed.dart`) are never hand-edited.
- After changing an annotated class, run
  `dart run build_runner build --delete-conflicting-outputs` and include regenerated output
  in the same change.
- Serialization annotations (`@JsonSerializable`, `fromJson`) belong on **data-layer DTOs**,
  not on domain entities. See `architecture.md`.

## Error handling

- Do not let Firebase exceptions leak past the data layer. Map them to domain failures.
- Never swallow errors silently (`catch (_) {}`); either handle, map, or rethrow.
