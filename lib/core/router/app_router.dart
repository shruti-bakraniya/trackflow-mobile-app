import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/transaction.dart';
import '../../presentation/pages/add_edit_transaction_page.dart';
import '../../presentation/pages/budgets_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/main_scaffold.dart';
import '../../presentation/pages/statistics_page.dart';
import '../../presentation/pages/transactions_page.dart';

/// Centralised go_router configuration.
///
/// A [StatefulShellRoute] powers the four-tab bottom navigation (each tab keeps
/// its own navigation state), while `/transaction-form` is a top-level route
/// presented as a slide-up modal for both Add and Edit.
class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(child: _HomeTab()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activity',
                pageBuilder: (context, state) => const NoTransitionPage(child: _ActivityTab()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                pageBuilder: (context, state) => const NoTransitionPage(child: StatisticsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/budgets',
                pageBuilder: (context, state) => const NoTransitionPage(child: BudgetsPage()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/transaction-form',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) {
          final existing = state.extra is Transaction ? state.extra as Transaction : null;
          return CustomTransitionPage(
            fullscreenDialog: true,
            transitionDuration: const Duration(milliseconds: 420),
            reverseTransitionDuration: const Duration(milliseconds: 320),
            transitionsBuilder: (context, animation, _, child) {
              final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
              return SlideTransition(
                position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
                child: child,
              );
            },
            child: AddEditTransactionPage(existing: existing),
          );
        },
      ),
    ],
  );
}

/// Home tab wired to navigate to edit / activity.
class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) {
    return HomePage(
      onOpenTransaction: (t) => context.push('/transaction-form', extra: t),
      onSeeAll: () => context.go('/activity'),
      onOpenBudgets: () => context.go('/budgets'),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab();
  @override
  Widget build(BuildContext context) {
    return TransactionsPage(
      onOpenTransaction: (t) => context.push('/transaction-form', extra: t),
    );
  }
}
