# TrackFlow

[Download Android APK](https://github.com/shruti-bakraniya/trackflow-mobile-app/releases/download/v0.0.1/trackflow_v1.apk)

A glassmorphic budget & expense tracker built with **Flutter**, following a strict
layer-first **Clean Architecture** with **BLoC** state management, **go_router**
navigation and **sqflite** local persistence.

## App Preview

<p align="center">
  <video src="assets/videos/walk_through.mp4" width="320" height="640" controls autoplay loop muted>
    Your browser does not support the video tag.
  </video>
</p>

## Architecture

```
lib/
├── core/                 # cross-cutting, framework-level concerns
│   ├── constants/        # db/table names, category registry
│   ├── errors/           # Exceptions (data) + Failures (domain)
│   ├── router/           # go_router config (shell tabs + modal form)
│   ├── theme/            # colors, gradients, glassmorphism widgets
│   ├── usecases/         # base UseCase + hand-rolled Either
│   └── utils/            # money/date formatters
├── data/                 # how data is stored
│   ├── datasources/      # sqflite CRUD + DatabaseHelper (init/seed)
│   ├── models/           # DTOs with fromMap/toMap
│   └── repositories/     # repository impls (Exception → Failure)
├── domain/               # what the app does (pure Dart, no Flutter)
│   ├── entities/         # Transaction, Budget, Statistics
│   ├── repositories/     # abstract contracts
│   └── usecases/         # AddTransaction, GetStatistics, …
├── presentation/         # how it looks
│   ├── bloc/             # TransactionBloc, BudgetBloc, StatisticsCubit
│   ├── pages/            # Home, Activity, Statistics, Budgets, Add/Edit
│   └── widgets/          # glass cards, CustomPainter charts, nav, tiles
├── injection_container.dart   # manual DI — wires the object graph
└── main.dart
```

## Features

- **Transactions** — add/edit/delete with type, amount, category, date, note.
- **Persistence** — everything stored in sqflite; seeded on first launch.
- **Statistics** — period-scoped totals, a **CustomPainter** donut (expenses by
  category), cash-flow bars, a savings-rate ring and a trend bar chart.
- **Search & filter** — by text, type, category (multi-select) and time range.
- **Budgets** — per-category monthly limits with on-track / near / over states and
  non-disruptive warnings (home strip, ring colour, save-time toast).
- **Motion** — animated count-ups, sliding segmented thumbs, sweeping charts,
  press-scale feedback and a slide-up add/edit sheet.

## Dependencies — all from pub.dev verified publishers

| Package | Publisher |
|---|---|
| flutter_bloc / bloc / equatable | verygood.ventures |
| go_router | flutter.dev |
| sqflite | tekartik.com |
| path / intl | dart.dev |
| google_fonts | google.dev |
