---
name: clipcast-flutter-architecture
description: >-
  Enforces clean architecture in the Clipcast Flutter project. Use when working on architecture,
  layer separation, state management, repository patterns, or use case design. Triggers: "architecture",
  "clean architecture", "layer", "cubit", "repository", "use case", "domain", "data layer",
  "presentation layer", "state management".
---

# Clipcast Flutter Architecture

Use this skill when working on Flutter architecture in Clipcast.

## Layer Rules

| Layer | Location | Contains |
|-------|----------|----------|
| **Presentation** | `lib/features/<feature>/presentation/` | Pages, components, controllers (Cubits), states |
| **Domain** | `lib/features/<feature>/domain/` | Entities, repository interfaces, use cases |
| **Data** | `lib/features/<feature>/data/` | Models, repository implementations, data sources |
| **Shared** | `lib/shared/` | Cross-feature widgets, cubits, models, utils |
| **Core** | `lib/core/` | Constants, errors, network utilities |
| **Theme** | `lib/theme/` | App theme, design tokens (primitives, semantic, components, typography, spacing) |

## Enforcement Rules

- Keep presentation, domain, and data layers **strictly separated**.
- Business logic lives in **use cases** (domain) or **cubits** (presentation) — never in widgets.
- Repository **interfaces** live in domain; **implementations** live in data.
- UI must never depend directly on data source implementations.
- Use **Cubit only** for state management — no Bloc, Provider, Riverpod, or GetX.
- Widgets should be clean, presentation-focused, and compose shared components.

## Checklist

- [ ] Is this code placed in the correct layer?
- [ ] Is UI free from business logic?
- [ ] Is state handled by Cubit only?
- [ ] Are repository abstractions in `domain/` and implementations in `data/`?
- [ ] Are data models separated from domain entities?
- [ ] Is the code reusable and testable?
- [ ] Is there duplication that can be removed?
- [ ] Does DI registration in `lib/app/di.dart` follow the existing pattern?
