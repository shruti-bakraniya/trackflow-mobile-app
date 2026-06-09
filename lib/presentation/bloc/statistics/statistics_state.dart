part of 'statistics_cubit.dart';

enum StatisticsStatus { initial, loading, loaded, failure }

class StatisticsState extends Equatable {
  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.period = StatsPeriod.month,
    this.statistics = Statistics.empty,
    this.errorMessage,
  });

  final StatisticsStatus status;
  final StatsPeriod period;
  final Statistics statistics;
  final String? errorMessage;

  StatisticsState copyWith({
    StatisticsStatus? status,
    StatsPeriod? period,
    Statistics? statistics,
    String? Function()? errorMessage,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      period: period ?? this.period,
      statistics: statistics ?? this.statistics,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, period, statistics, errorMessage];
}
