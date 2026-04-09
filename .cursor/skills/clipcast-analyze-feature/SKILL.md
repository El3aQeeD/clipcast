---
name: clipcast-analyze-feature
description: >-
  Analyzes a feature in Clipcast before implementation. Reads related files, identifies architecture,
  reusable components, tokens, and Supabase integration points, then proposes a clean implementation
  path. Use when the user says "/analyze-feature", "analyze this feature", "plan this feature",
  "review before implementing", or wants a pre-implementation assessment.
---

# /analyze-feature — Clipcast

Analyze a feature before implementation following Clipcast standards.

## Step 1: Read

Read the related files for the target feature:
- `lib/features/<feature>/` (all layers: data, domain, presentation)
- `lib/shared/widgets/` for reusable components
- `lib/shared/cubits/` for shared state
- `lib/theme/tokens/` for design tokens
- `lib/app/di.dart` for DI registrations
- `lib/app/router.dart` for routing
- `lib/core/` for constants and error handling

## Step 2: Identify

| Category | What to Find |
|----------|-------------|
| Architecture | Current layer structure and patterns used |
| Widgets | Reusable shared widgets and feature-specific components |
| State | Relevant cubits and state models |
| Domain | Existing entities, use cases, repository interfaces |
| Data | Data sources, models, repository implementations |
| Tokens | Design tokens already in use for this feature's UI |
| Supabase | Integration points, queries, RLS considerations |

## Step 3: Propose

Propose the best clean implementation path following:
- Clean architecture (presentation / domain / data)
- Cubit-only state management
- Figma as source of truth
- Token-based design
- Reuse before create
- Secure Supabase usage
- No client-side secrets

## Step 4: Report

Return a structured report:

1. **Files inspected** — list of files read and their purpose
2. **Findings** — current structure, reusable assets, patterns detected
3. **Implementation plan** — ordered steps with layer placement
4. **Files to create or update** — with justification for each
5. **Risks or notes** — edge cases, security concerns, migration needs
