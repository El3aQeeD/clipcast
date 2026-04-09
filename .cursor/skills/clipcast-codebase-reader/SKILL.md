---
name: clipcast-codebase-reader
description: >-
  Reads and inspects the existing Clipcast codebase before implementing any feature or refactor.
  Use when starting any new feature, refactor, or modification to identify reusable widgets, cubits,
  repositories, services, and tokens. Triggers: "implement", "build", "add feature", "refactor",
  "before coding", "inspect first", "read codebase".
---

# Clipcast Codebase Reader

Use this skill before implementing any feature or refactor in Clipcast.

## Instructions

1. **Read the related files first** — never start coding without inspecting the existing structure.
2. **Identify reusable assets:**
   - Shared widgets in `lib/shared/widgets/`
   - Cubits and state models in the relevant feature's `presentation/controller/`
   - Repositories and data sources in `data/`
   - Domain entities and use cases in `domain/`
   - Design tokens in `lib/theme/tokens/`
3. **Detect the current architecture pattern** already used in that feature.
4. **Minimize unnecessary file creation** — extend existing files when possible.
5. **Extend existing clean patterns** instead of creating parallel ones.

## Checklist

Before proposing or writing any code, answer these:

- [ ] What files already handle this feature?
- [ ] Is there already a shared widget for this in `lib/shared/widgets/`?
- [ ] Is there already a cubit or state model for this?
- [ ] Are there tokens/constants already defined for styling in `lib/theme/tokens/`?
- [ ] Can I extend an existing file instead of duplicating?
- [ ] Am I keeping consistency with the existing codebase patterns?

## Output

After inspection, propose the **cleanest minimal implementation** — list files to modify vs. create, and justify each decision.
