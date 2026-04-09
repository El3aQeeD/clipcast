---
name: clipcast-design-and-security-guard
description: >-
  Guards UI consistency and backend security in Clipcast. Use when building UI, styling widgets,
  integrating Supabase, or handling sensitive logic. Triggers: "design tokens", "colors", "typography",
  "spacing", "Figma", "Supabase", "security", "secrets", "edge function", "API key", "RLS",
  "raw color", "raw font".
---

# Clipcast Design and Security Guard

Use this skill when building UI or integrating backend logic in Clipcast.

## Design Token Enforcement

All styling must use centralized tokens — never raw values.

| Token Type | Source File | Example Usage |
|------------|-------------|---------------|
| Colors (primitive) | `lib/theme/tokens/primitives.dart` | `PrimitiveColors.cyan500` |
| Colors (semantic) | `lib/theme/tokens/semantic.dart` | `SemanticColors.textPrimary` |
| Colors (component) | `lib/theme/tokens/components.dart` | `ComponentColors.buttonPrimary` |
| Typography | `lib/theme/tokens/typography.dart` | `AppTypography.bodyMedium` |
| Spacing | `lib/theme/tokens/spacing.dart` | `AppSpacing.md`, `AppRadius.sm` |

## UI Rules

- Follow **Figma as the source of truth** — do not invent design decisions.
- Reuse shared components from `lib/shared/widgets/` before creating new ones.
- Keep consistent spacing, radius, typography, and component behavior.
- Prevent raw color hex values (e.g., `Color(0xFF...)`) in widgets.
- Prevent raw font sizes unless they come from `AppTypography`.

## Supabase Security Rules

- Supabase is the backend source of truth.
- **Never** expose secrets, service role keys, or privileged logic on the client.
- Prefer Supabase Edge Functions for sensitive operations (role escalation, privileged queries).
- Always think RLS-aware — assume the client operates under user-scoped permissions.
- Validate inputs server-side when security matters.

## Checklist

- [ ] Did I use existing tokens for colors, spacing, and typography?
- [ ] Did I reuse an existing widget before creating a new one?
- [ ] Does this match Figma?
- [ ] Is any secret exposed on the client?
- [ ] Should this logic live in an Edge Function instead?
- [ ] Does this implementation avoid unnecessary rebuilds or repeated calls?
- [ ] Is the solution secure, reusable, and maintainable?
