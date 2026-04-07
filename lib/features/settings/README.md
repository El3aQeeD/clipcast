# Settings Feature

User preferences, account settings, and app configuration.

## Architecture

```
settings/
├── data/
│   ├── models/       # DTOs — map JSON ↔ domain entities
│   ├── repository/   # Repository implementations
│   └── source/       # Remote & local data sources
├── domain/
│   ├── entities/     # Pure Dart domain models
│   ├── repository/   # Abstract repository interfaces
│   └── usecases/     # Business logic use cases
├── presentation/
│   ├── components/   # Reusable UI components (extracted from pages)
│   ├── controller/   # Cubit state management (ONLY Cubit)
│   └── pages/        # Full page widgets
└── README.md
```

## Rules

| Rule | Enforcement |
|------|-------------|
| State management | **Cubit ONLY** — never Bloc or other patterns without permission |
| Colors & fonts | **ALWAYS use tokens** — SemanticColors, ComponentColors, AppTypography |
| Raw values | **NEVER** use `Color(0x...)`, `fontFamily: '...'`, or `AppColors.xxx` |
| File size | **Max ~1000 lines** — extract into `components/` |
| Domain layer | **Pure Dart only** — no Flutter imports |
| Data flow | `source/ → repository/ → usecase → controller → page` |
