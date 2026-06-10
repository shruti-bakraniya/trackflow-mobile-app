# TrackFlow

> A glassmorphic budget & expense tracker built with **Clean Architecture + BLoC** in Flutter.

TrackFlow lets you log income and expenses, set per-category monthly budgets, and visualise spending trends — all persisted locally with SQLite and wrapped in a frosted-glass UI with smooth micro-animations.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
  - [Clean Architecture Layers](#clean-architecture-layers)
  - [Architecture Diagram](#architecture-diagram)
- [Directory Structure](#directory-structure)
- [App Flow](#app-flow)
  - [Startup Sequence](#startup-sequence)
  - [Navigation Map](#navigation-map)
  - [Screen-by-Screen Flow](#screen-by-screen-flow)
- [State Management](#state-management)
  - [Why BLoC](#why-bloc)
  - [BLoC Overview](#bloc-overview)
  - [TransactionBloc (Event-driven)](#transactionbloc-event-driven)
  - [BudgetBloc (Event-driven)](#budgetbloc-event-driven)
  - [StatisticsCubit (Method-driven)](#statisticscubit-method-driven)
  - [State Flow Diagram](#state-flow-diagram)
- [Dependency Injection](#dependency-injection)
- [Error Handling Strategy](#error-handling-strategy)
- [Design System](#design-system)
- [Getting Started](#getting-started)
- [Testing](#testing)

---

## Features

| Area | Details |
|------|---------|
| **Transaction CRUD** | Add, edit, and delete income/expense entries with category, amount, date, and optional note |
| **Budget Limits** | Set per-category monthly spending caps; get amber (≥ 80%) and red (exceeded) warnings |
| **Dashboard** | Net balance hero card, monthly income/expense breakdown, budget alert strip, recent transactions |
| **Statistics** | Donut chart (expense by category), trend bar chart (income vs expense), period selector (week/month/year) |
| **Activity Feed** | Full transaction list with search, type filter, category filter, and date range filter |
| **Glassmorphism UI** | Frosted-glass cards with backdrop blur, sheens, drop shadows, and press-scale micro-animations |
| **Demo Seeding** | 20 realistic transactions + 6 budgets seeded on first launch so the app looks populated out of the box |

---

## Tech Stack

| Dependency | Version | Purpose |
|---|---|---|
| `flutter_bloc` / `bloc` | ^8.1.5 / ^8.1.4 | State management (BLoC pattern) |
| `equatable` | ^2.0.5 | Value equality for events, states, entities |
| `go_router` | ^14.2.0 | Declarative routing with `StatefulShellRoute` |
| `sqflite` | ^2.3.3 | Local SQLite persistence |
| `path` | ^1.9.0 | File path helpers for database location |
| `intl` | ^0.19.0 | Money & date formatting |
| `google_fonts` | ^6.2.1 | Manrope (UI) + Space Grotesk (numerals) typography |
| `bloc_test` | ^9.1.7 | BLoC testing utilities |
| `mocktail` | ^1.0.4 | Mocking framework for unit tests |

> **No `dartz`**: The project hand-rolls a minimal `Either` type using Dart 3 sealed classes to avoid unverified-publisher dependencies.

---

## Architecture Overview

### Clean Architecture Layers

TrackFlow follows a strict **three-layer Clean Architecture** where each layer only depends on the layer below it, and the domain layer depends on nothing external.

```
┌─────────────────────────────────────────────┐
│              PRESENTATION                   │
│   Pages • Widgets • BLoC (Bloc / Cubit)     │
│   Depends on: Domain                        │
├─────────────────────────────────────────────┤
│                DOMAIN                       │
│   Entities • Repository contracts           │
│   Use Cases • Either / Failure types        │
│   Depends on: nothing                       │
├─────────────────────────────────────────────┤
│                 DATA                        │
│   Models • Repository implementations      │
│   SQLite datasources • DatabaseHelper       │
│   Depends on: Domain (implements contracts) │
└─────────────────────────────────────────────┘
```

### Architecture Diagram

```
User → Page (Widget)
         ↓ dispatches event / calls method
       BLoC / Cubit
         ↓ calls
       UseCase
         ↓ calls
       Repository (abstract)
         ↓ implemented by
       RepositoryImpl
         ↓ delegates to
       LocalDataSource
         ↓ queries
       sqflite (DatabaseHelper)
```

---

## Directory Structure

```
lib/
├── main.dart                          # App entry point, creates DI container, runs TrackFlowApp
├── injection_container.dart           # Manual DI: wires datasources → repos → use cases → blocs
│
├── core/                              # Shared utilities, not tied to any feature
│   ├── constants/
│   │   ├── app_constants.dart         # Database name, version, table/column names
│   │   └── categories.dart            # AppCategory registry (id, label, icon, hue, type)
│   ├── errors/
│   │   ├── exceptions.dart            # Data-layer exceptions (DatabaseException, NotFoundException)
│   │   └── failures.dart              # Domain-layer failures (DatabaseFailure, ValidationFailure, …)
│   ├── router/
│   │   └── app_router.dart            # GoRouter config: StatefulShellRoute (4 tabs) + transaction-form
│   ├── theme/
│   │   ├── app_colors.dart            # Sage-green palette, glass fills, semantic colours
│   │   ├── app_gradients.dart         # Canvas wash, glass sheen, accent gradient, category glow
│   │   ├── app_theme.dart             # ThemeData builder, Manrope + Space Grotesk type helpers
│   │   └── glassmorphism.dart         # GlassCard widget (backdrop blur, sheen, shadow, press-scale)
│   ├── usecases/
│   │   ├── either.dart                # Hand-rolled Either<L,R> sealed class
│   │   └── usecase.dart               # UseCase<Type, Params> base + NoParams
│   └── utils/
│       └── formatters.dart            # Money formatting, relative date labels
│
├── domain/                            # Pure Dart — no Flutter, no I/O
│   ├── entities/
│   │   ├── transaction.dart           # Transaction entity, TransactionType enum
│   │   ├── budget.dart                # Budget, BudgetStatus, BudgetLevel
│   │   └── statistics.dart            # Statistics, CategorySlice, TrendPoint, StatsPeriod
│   ├── repositories/
│   │   ├── transaction_repository.dart  # Abstract CRUD contract
│   │   └── budget_repository.dart       # Abstract CRUD contract
│   └── usecases/
│       ├── add_transaction.dart       # Validates amount > 0 & category before persisting
│       ├── update_transaction.dart     # Validates then updates
│       ├── delete_transaction.dart     # Deletes by ID
│       ├── get_transactions.dart      # Returns full list sorted by date DESC
│       ├── get_statistics.dart        # Aggregates totals, donut slices, trend series
│       ├── get_budgets.dart           # Returns all budget limits
│       ├── set_budget.dart            # Creates or updates a category budget
│       └── delete_budget.dart         # Removes a category budget
│
├── data/                              # Concrete implementations + SQLite
│   ├── datasources/
│   │   ├── database_helper.dart       # Singleton DB connection, schema creation, demo seeding
│   │   ├── transaction_local_datasource.dart  # Raw CRUD for transactions table
│   │   └── budget_local_datasource.dart       # Raw CRUD for budgets table
│   ├── models/
│   │   ├── transaction_model.dart     # Entity subclass with toMap/fromMap (dates as yyyy-MM-dd)
│   │   └── budget_model.dart          # Entity subclass with toMap/fromMap
│   └── repositories/
│       ├── transaction_repository_impl.dart  # Exception→Failure mapping, ID generation
│       └── budget_repository_impl.dart       # Exception→Failure mapping
│
└── presentation/                      # Flutter UI + state management
    ├── bloc/
    │   ├── transaction/
    │   │   ├── transaction_bloc.dart   # CRUD events, search/filter, budget-aware toast feedback
    │   │   ├── transaction_event.dart  # TransactionsRequested, TransactionAdded, Search, Filter, …
    │   │   └── transaction_state.dart  # TransactionState (list, filters, computed getters, feedback)
    │   ├── budget/
    │   │   ├── budget_bloc.dart        # Load, set, remove budget limits
    │   │   ├── budget_event.dart       # BudgetsRequested, BudgetSet, BudgetRemoved
    │   │   └── budget_state.dart       # BudgetState (list, limitByCategory map)
    │   └── statistics/
    │       ├── statistics_cubit.dart   # Loads period-scoped stats, changePeriod()
    │       └── statistics_state.dart   # StatisticsState (Statistics entity, period, status)
    ├── pages/
    │   ├── main_scaffold.dart         # Shell: bottom nav, FAB, global toast listener
    │   ├── home_page.dart             # Dashboard: balance hero, budget alert strip, recent list
    │   ├── transactions_page.dart     # Activity feed with search, filter drawer
    │   ├── statistics_page.dart       # Donut + trend charts with period toggle
    │   ├── budgets_page.dart          # Per-category budget cards with progress rings
    │   └── add_edit_transaction_page.dart  # Slide-up form for creating/editing transactions
    └── widgets/
        ├── add_fab.dart               # Gradient floating action button
        ├── app_background.dart        # Full-screen gradient canvas
        ├── bottom_nav_bar.dart        # Frosted floating bottom nav with FAB notch
        ├── category_avatar.dart       # Circular icon with category hue
        ├── count_up_text.dart         # Animated counting number
        ├── feedback_toast.dart        # Budget-warning / success toast overlay
        ├── segmented_control.dart     # Period selector (Week / Month / Year)
        ├── track_chip.dart            # Filter chip used in Activity
        ├── transaction_tile.dart      # Single transaction row
        └── charts/
            ├── donut_chart.dart       # Custom-painted donut with category breakdown
            ├── trend_bar_chart.dart    # Income vs expense bar chart
            ├── progress_ring.dart     # Animated ring for budget usage
            └── linear_progress_bar.dart # Horizontal progress indicator
```

---

## App Flow

### Startup Sequence

```
main()
  ├── WidgetsFlutterBinding.ensureInitialized()
  ├── InjectionContainer()                 ← wires the full object graph
  │     ├── DatabaseHelper                 ← lazy-opens SQLite (creates/seeds on first run)
  │     ├── TransactionLocalDataSourceImpl
  │     ├── BudgetLocalDataSourceImpl
  │     ├── TransactionRepositoryImpl
  │     ├── BudgetRepositoryImpl
  │     └── 8 Use Cases
  └── runApp(TrackFlowApp)
        └── MultiBlocProvider              ← provides 3 blocs to the entire widget tree
              ├── TransactionBloc  → auto-dispatches TransactionsRequested
              ├── BudgetBloc       → auto-dispatches BudgetsRequested
              └── StatisticsCubit  → idle until Statistics page opens
```

On first launch, `DatabaseHelper._onCreate` creates two tables (`transactions`, `budgets`) and seeds 20 demo transactions + 6 budget limits so the dashboard, charts, and budget warnings are immediately populated.

### Navigation Map

```
StatefulShellRoute (IndexedStack — preserves tab state)
├── /home       → HomePage            (Tab 0: Dashboard)
├── /activity   → TransactionsPage    (Tab 1: Activity feed)
├── /stats      → StatisticsPage      (Tab 2: Charts)
└── /budgets    → BudgetsPage         (Tab 3: Budget limits)

Top-level route (slide-up modal):
└── /transaction-form → AddEditTransactionPage
      ├── extra: null       → "Add" mode
      └── extra: Transaction → "Edit" mode
```

**Navigation is powered by `go_router`'s `StatefulShellRoute.indexedStack`**: each tab maintains its own navigator state, so switching tabs preserves scroll position and doesn't rebuild the widget tree. The transaction form is a top-level route (not nested inside any branch), so it slides up as a full-screen modal over any tab.

### Screen-by-Screen Flow

#### Home (Dashboard)

1. `BlocBuilder<TransactionBloc>` reads the current month's income, expense, and balance from computed state getters (`monthIncome`, `monthExpense`, `monthBalance`).
2. **Balance hero card** — animated count-up of net balance, with income/expense mini-stat pills.
3. **Budget alert strip** — `BlocBuilder<BudgetBloc>` + `TransactionBloc` cross-reference budgets with monthly spend; surfaces the worst over/near-limit category as a tappable amber/red banner.
4. **Recent activity** — last 5 transactions displayed as `TransactionTile` widgets inside a `GlassCard`. Tapping opens the edit form.
5. **See all** → navigates to the Activity tab. **Budget alert tap** → navigates to the Budgets tab.

#### Activity (Transactions List)

1. `BlocBuilder<TransactionBloc>` renders `state.filtered` — the full transaction list after applying active search, type filter, category filter, and date range filter.
2. **Search bar** dispatches `SearchQueryChanged` events.
3. **Filter drawer** dispatches `TypeFilterChanged`, `CategoryFilterToggled`, and `DateRangeFilterChanged` events. An active-filter badge shows the count.
4. **Clear filters** dispatches `FiltersCleared`.
5. Tapping a transaction opens the edit form via `context.push('/transaction-form', extra: transaction)`.
6. Swipe-to-delete dispatches `TransactionDeleted`.

#### Statistics

1. On first build, calls `StatisticsCubit.load()` which invokes `GetStatistics` use case.
2. `GetStatistics` fetches all transactions → filters by period (week/month/year) → computes:
   - `totalIncome` and `totalExpense`
   - `expenseByCategory` → list of `CategorySlice` (for donut chart)
   - `trend` → list of `TrendPoint` (for bar chart)
3. **Period segmented control** calls `changePeriod()` which reloads with the new period.
4. **Donut chart** — custom-painted ring showing category spend proportions.
5. **Trend bar chart** — side-by-side income/expense bars per time bucket.

#### Budgets

1. `BlocBuilder<BudgetBloc>` displays all per-category budget limits with progress rings.
2. Cross-references `TransactionBloc.state.monthSpendByCategory` to compute spent/limit ratios.
3. Each budget card shows a `ProgressRing` (green = OK, amber ≥ 80%, red = exceeded).
4. Users can add/edit budget limits (dispatches `BudgetSet`) or remove them (dispatches `BudgetRemoved`).

#### Add/Edit Transaction Form

1. Receives an optional `Transaction` via `GoRouter.extra`:
   - **null** → add mode (empty form, defaults to expense).
   - **Transaction** → edit mode (pre-filled fields).
2. On save, dispatches `TransactionAdded` or `TransactionUpdated` to `TransactionBloc`.
3. The bloc writes to SQLite, reloads the full list, then computes budget-aware feedback:
   - If the saved expense pushes a category **over** its monthly budget → red "exceeded" toast.
   - If the category is now **≥ 80%** of budget → amber "heads up" toast.
   - Otherwise → green "Transaction saved" toast.
4. The toast is rendered by `MainScaffold`'s `BlocListener` which listens for `state.feedback` changes.
5. On success, `context.pop()` dismisses the slide-up modal.

---

## State Management

### Why BLoC

The app uses the `flutter_bloc` package which implements the **BLoC (Business Logic Component)** pattern. This was chosen for:

- **Predictable unidirectional data flow**: Events go in → State comes out.
- **Separation of concerns**: Business logic lives in blocs, not widgets.
- **Testability**: Bloc tests can assert state sequences without any Flutter dependencies.
- **Equatable states**: States use `Equatable` so `BlocBuilder` only rebuilds when values actually change.

### BLoC Overview

All three blocs are provided at the **root of the widget tree** (above the router) via `MultiBlocProvider`, ensuring every screen — including the pushed transaction form — shares the same instances.

| Component | Type | Responsibility |
|---|---|---|
| `TransactionBloc` | `Bloc<Event, State>` | CRUD, search/filter, budget-aware feedback |
| `BudgetBloc` | `Bloc<Event, State>` | Budget limit CRUD |
| `StatisticsCubit` | `Cubit<State>` | Period-scoped statistical aggregation |

### TransactionBloc (Event-driven)

The most complex bloc in the app. Handles transaction CRUD, search and filtering, and cross-references budget limits to produce budget-aware toast feedback.

**Events:**

| Event | Trigger | Effect |
|---|---|---|
| `TransactionsRequested` | App start, after mutations | Loads all transactions from SQLite |
| `TransactionAdded` | Save button (add mode) | Validates → inserts → reloads → emits budget feedback |
| `TransactionUpdated` | Save button (edit mode) | Validates → updates → reloads → emits budget feedback |
| `TransactionDeleted` | Swipe-to-delete | Deletes → reloads → emits "deleted" feedback |
| `SearchQueryChanged` | Search bar input | Updates `query` in state → `filtered` getter re-computes |
| `TypeFilterChanged` | Filter toggle (Income/Expense) | Updates `typeFilter` in state |
| `CategoryFilterToggled` | Category chip tap | Toggles category in `categoryFilter` set |
| `DateRangeFilterChanged` | Date range selector | Updates `range` in state |
| `FiltersCleared` | Clear button | Resets all filters to defaults |

**State shape:**

```dart
TransactionState {
  status           // initial → loading → loaded / failure
  transactions     // List<Transaction> — full list, newest first
  query            // search text
  typeFilter       // null (all) | expense | income
  categoryFilter   // Set<String> of active category IDs
  range            // DateRangeFilter (all / 7d / 30d / this month)
  feedback         // TransactionFeedback? (one-shot toast)
  errorMessage     // String? for failure states

  // Computed getters:
  filtered         → applies search + all filters to transactions
  monthIncome      → sum of income for current month
  monthExpense     → sum of expense for current month
  monthBalance     → monthIncome - monthExpense
  monthSpendByCategory → Map<categoryId, spent> for current month
  activeFilterCount    → number of active filters (for badge)
}
```

**Budget-aware feedback flow:**

```
TransactionAdded / TransactionUpdated
  → UseCase validates and persists
  → Bloc reloads full list from DB
  → If saved tx is an expense in the current month:
      → Fetches budgets via GetBudgets
      → Computes BudgetStatus for that category
      → If over limit   → FeedbackTone.danger
      → If ≥ 80% limit  → FeedbackTone.warning
      → Otherwise       → FeedbackTone.success
  → Emits new state with TransactionFeedback
  → MainScaffold's BlocListener shows toast
```

### BudgetBloc (Event-driven)

Simpler bloc that manages per-category monthly budget limits.

**Events:**

| Event | Trigger | Effect |
|---|---|---|
| `BudgetsRequested` | App start | Loads all budgets from SQLite |
| `BudgetSet` | Save budget dialog | Creates or updates (upsert) a budget limit |
| `BudgetRemoved` | Delete budget action | Removes a category's budget |

**State shape:**

```dart
BudgetState {
  status        // initial → loading → loaded / failure
  budgets       // List<Budget>
  errorMessage  // String?

  // Computed:
  limitByCategory → Map<categoryId, limit> for quick lookups
}
```

### StatisticsCubit (Method-driven)

Uses `Cubit` instead of `Bloc` because it has no complex events — just a `load()` method and a `changePeriod()` shortcut.

**Methods:**

| Method | Trigger | Effect |
|---|---|---|
| `load({period?})` | Statistics page open, period change | Runs `GetStatistics` use case → emits computed `Statistics` |
| `changePeriod(p)` | Segmented control tap | Calls `load(period: p)` |

**State shape:**

```dart
StatisticsState {
  status       // initial → loading → loaded / failure
  period       // StatsPeriod (week / month / year)
  statistics   // Statistics entity (totals, slices, trend points)
  errorMessage // String?
}
```

### State Flow Diagram

```
┌──────────────┐    dispatches    ┌──────────────┐    calls    ┌──────────┐
│    Widget    │ ──────────────→ │     BLoC     │ ─────────→ │ UseCase  │
│  (Page/UI)   │                  │  (Bloc/Cubit) │            │          │
└──────┬───────┘                  └──────┬───────┘            └────┬─────┘
       │                                 │                         │
       │    rebuilds on state change      │    calls               │
       │ ←────────────────────────────────│    ↓                   │
       │                                 │  Repository              │
       │                                 │    ↓                   │
       │                                 │  DataSource             │
       │                                 │    ↓                   │
       │                                 │  SQLite (sqflite)       │
       │                                 │                         │
       │        new state emitted         │   Either<Failure, T>   │
       │ ←────────────────────────────────│ ←─────────────────────│
```

---

## Dependency Injection

TrackFlow uses a **manual DI container** (`InjectionContainer`) — no service locator or code generation. The container is constructed once in `main()` and wires the full object graph bottom-up:

```
DatabaseHelper
  → TransactionLocalDataSourceImpl  →  TransactionRepositoryImpl
  → BudgetLocalDataSourceImpl       →  BudgetRepositoryImpl
                                          ↓
                                    8 Use Cases
                                          ↓
                                    3 BLoC factories
```

Each bloc receives only the use cases it needs (constructor injection). Lower layers never import from layers above — the container is the single place where abstractions are bound to concrete implementations.

---

## Error Handling Strategy

Errors flow through two distinct layers:

| Layer | Mechanism | Types |
|---|---|---|
| **Data** | `throw` exceptions | `DatabaseException`, `CacheException`, `NotFoundException` |
| **Domain** | Return `Either<Failure, T>` | `DatabaseFailure`, `ValidationFailure`, `UnexpectedFailure`, `CacheFailure` |

**Flow:**

1. Datasources throw raw exceptions.
2. Repository implementations catch them in a `_guard()` wrapper and return `Left(Failure(...))`.
3. Use cases may add validation checks (e.g., `AddTransaction` rejects amount ≤ 0) and return `Left(ValidationFailure(...))`.
4. Blocs `fold()` the `Either` result: `Left` → emit error state or toast; `Right` → emit success state.

This means widgets **never** see raw exceptions — only typed, user-friendly failure messages.

---

## Design System

| Token | Value | Usage |
|---|---|---|
| **Background** | `#519F7D` (sage green) | Full-screen canvas gradient |
| **Accent** | `#0F5A3C` (deep teal) | Buttons, FAB, active states |
| **Glass Fill** | `white @ 80%` | Frosted card backgrounds |
| **Glass Stroke** | `white @ 65%` | Card borders |
| **Ink** | `#143A2B` | Primary text on glass |
| **Typography** | Manrope (UI) + Space Grotesk (numbers) | via `google_fonts` |
| **Semantic** | `#15894F` income, `#D2553F` expense, `#FBB F24` warn, `#F43F5E` over | Budget alerts, charts |

The `GlassCard` widget handles frosted glass rendering: `BackdropFilter` blur, translucent fill, hairline border, top sheen gradient, drop shadow, and a press-scale animation (`AnimatedScale` 0.955× on tap-down) for tactile feedback.

---

## Getting Started

```bash
# Clone the repository
git clone https://github.com/your-username/trackflow-mobile-app.git
cd trackflow-mobile-app

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

**Requirements:**
- Flutter SDK `≥ 3.12.1`
- Dart SDK `≥ 3.12.1`
- iOS 12+ or Android 5.0+

---

## Testing

The project includes `bloc_test` and `mocktail` as dev dependencies for unit and widget testing.

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

**Test strategy:**

- **Domain tests** — unit-test use cases with mocked repositories.
- **BLoC tests** — assert state sequences with `blocTest()` using mocked use cases.
- **Widget tests** — render pages with pre-seeded bloc states to verify UI output.
