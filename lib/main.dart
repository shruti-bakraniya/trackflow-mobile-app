import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart';
import 'presentation/bloc/budget/budget_bloc.dart';
import 'presentation/bloc/statistics/statistics_cubit.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TrackFlowApp(di: InjectionContainer()));
}

class TrackFlowApp extends StatelessWidget {
  const TrackFlowApp({super.key, required this.di});
  final InjectionContainer di;

  @override
  Widget build(BuildContext context) {
    // Blocs live above the router so every screen (including pushed routes
    // like the add/edit form) shares the same instances.
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(create: (_) => di.createTransactionBloc()),
        BlocProvider<BudgetBloc>(create: (_) => di.createBudgetBloc()),
        BlocProvider<StatisticsCubit>(create: (_) => di.createStatisticsCubit()),
      ],
      child: MaterialApp.router(
        title: 'TrackFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
