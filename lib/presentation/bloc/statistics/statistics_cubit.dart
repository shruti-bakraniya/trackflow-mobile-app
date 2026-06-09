import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/statistics.dart';
import '../../../domain/usecases/get_statistics.dart';

part 'statistics_state.dart';

/// Derives period-scoped [Statistics] via the [GetStatistics] use case.
/// The Statistics screen refreshes this whenever transactions change.
class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit({required GetStatistics getStatistics})
      : _getStatistics = getStatistics,
        super(const StatisticsState());

  final GetStatistics _getStatistics;

  Future<void> load({StatsPeriod? period}) async {
    final p = period ?? state.period;
    emit(state.copyWith(status: StatisticsStatus.loading, period: p));
    final result = await _getStatistics(p);
    result.fold(
      (failure) => emit(state.copyWith(
        status: StatisticsStatus.failure,
        errorMessage: () => failure.message,
      )),
      (stats) => emit(state.copyWith(
        status: StatisticsStatus.loaded,
        statistics: stats,
        errorMessage: () => null,
      )),
    );
  }

  void changePeriod(StatsPeriod period) => load(period: period);
}
