import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/transaction/transaction_bloc.dart';
import '../widgets/app_background.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/feedback_toast.dart';

/// App shell: hosts the four tab branches in an [IndexedStack] (via go_router's
/// [StatefulNavigationShell]), the floating bottom nav + FAB, and the global
/// budget-warning toast listener.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (a, b) => b.feedback != null && a.feedback != b.feedback,
      listener: (context, state) {
        if (state.feedback != null) showAppToast(context, state.feedback!);
      },
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SafeArea(bottom: false, child: navigationShell),
          bottomNavigationBar: AppBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: (i) => navigationShell.goBranch(
              i,
              initialLocation: i == navigationShell.currentIndex,
            ),
            onAdd: () => context.push('/transaction-form'),
          ),
        ),
      ),
    );
  }
}
