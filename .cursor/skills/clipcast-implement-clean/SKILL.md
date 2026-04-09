---
name: clipcast-implement-clean
description: >-
  Implements a feature or change as a senior Flutter engineer following Clipcast standards.
  Enforces clean architecture, Cubit-only state, token-based design, Figma alignment, and
  secure Supabase usage. Use when the user says "/implement-clean", "implement this cleanly",
  "build this feature", or wants a standards-compliant implementation.
---

# /implement-clean — Clipcast

Implement a request as a senior Flutter engineer for Clipcast.

## Pre-Implementation (mandatory)

Before writing any code:

1. **Inspect** the related files in the target feature directory.
2. **Identify** reusable widgets, cubits, tokens, repositories, and patterns.
3. **Check** for duplicate widgets, services, or patterns that already exist.

## Implementation Rules

| Rule | Detail |
|------|--------|
| Architecture | Clean architecture — presentation, domain, data separated |
| State | Cubit only — no Bloc, Provider, Riverpod, GetX |
| Design | Token-based only — use `lib/theme/tokens/` for all styling |
| UI Source | Figma is the source of truth — do not invent designs |
| Backend | Supabase is the backend — respect RLS, no client-side secrets |
| Reuse | Extend existing components before creating new ones |
| Performance | Use `const`, avoid rebuilds, no heavy logic in `build` |
| DI | Register new dependencies in `lib/app/di.dart` following existing patterns |
| Routing | Add routes in `lib/app/router.dart` following existing patterns |

## Implementation Steps

1. **Read** existing code for the feature.
2. **Map** the implementation to the correct layers:
   - Entities and repository interfaces → `domain/`
   - Models, data sources, repository implementations → `data/`
   - Pages, components, cubits, states → `presentation/`
3. **Implement** with minimal, clean changes.
4. **Register** dependencies in DI and add routes as needed.
5. **Verify** consistency with the codebase — naming, structure, patterns.

## Post-Implementation Checklist

- [ ] Layers are correctly separated
- [ ] Cubit-only state management
- [ ] All styling uses design tokens
- [ ] No raw colors, font sizes, or spacing values
- [ ] Shared widgets reused where applicable
- [ ] No secrets or privileged logic on client
- [ ] DI registrations added for new classes
- [ ] Routes added for new pages
- [ ] Code is testable and maintainable
