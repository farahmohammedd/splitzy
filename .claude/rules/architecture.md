---
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
---

# Clean Architecture Boundaries

## Target layout (reference only — do not create until a feature needs it)

```
lib/
  core/                     # cross-cutting: errors, result types, router, theme, utils
  features/
    <feature>/
      domain/               # entities, repository interfaces, use cases — pure Dart
      data/                 # DTOs, data sources (Firebase), repository implementations
      presentation/         # screens, widgets, Riverpod controllers/providers
```

Folders are created only when the first real file that belongs in them is written.

## Dependency rule

Dependencies point **inward only**:

```
presentation  ──►  domain  ◄──  data
```

| Layer          | May import                                   | Must NOT import                                    |
| -------------- | -------------------------------------------- | -------------------------------------------------- |
| `domain`       | Dart SDK, `core` (pure parts), Freezed annotations | Flutter, Firebase, Riverpod, GoRouter, `data`, `presentation` |
| `data`         | `domain`, `core`, Firebase/Firestore SDKs     | `presentation`, Flutter widgets                    |
| `presentation` | `domain`, `core`, Flutter, Riverpod, GoRouter | Firebase SDKs, `data` internals (DTOs, data sources) |

- Wiring `data` implementations into `domain` interfaces happens **only in providers** (the
  composition root), never inside widgets or use cases.
- Features do not import another feature's `data` or `presentation` layer. Shared concepts
  move to `core` or are exposed via the other feature's `domain` layer.

## Domain layer

- Pure Dart. Must be runnable with `dart test` — no Flutter binding required.
- **Entities**: immutable (Freezed allowed), no JSON annotations, no Firestore types
  (`Timestamp`, `DocumentReference`, etc.).
- **Repository interfaces**: abstract classes describing what the domain needs, in domain terms.
- **Use cases**: one public operation each; hold the business rules (split calculation,
  balance computation, settlement simplification, validation).
- Return explicit results or throw domain-specific failures — never Firebase exceptions.

## Data layer

- **DTOs/models**: Freezed + json_serializable, with explicit `toEntity()` / `fromEntity()`
  mapping. Firestore-specific conversions (e.g. `Timestamp` ↔ `DateTime`) live here.
- **Data sources**: thin wrappers over FirebaseAuth / Firestore. No business rules.
- **Repository implementations**: implement domain interfaces, map DTOs ↔ entities, and map
  exceptions → domain failures.

## Presentation layer

- Screens and widgets render state and forward user intent. No business rules.
- Controllers/notifiers call use cases (or repositories for trivial reads) and expose
  `AsyncValue`/state to widgets.

## When unsure

If code does not clearly belong to one layer, or a boundary would need to be crossed, stop and
ask the developer rather than guessing.
