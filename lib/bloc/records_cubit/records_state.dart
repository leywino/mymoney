part of 'records_cubit.dart';

abstract class RecordsState {}

class RecordsLoading extends RecordsState {}

class RecordsAnalyticsLoaded extends RecordsState {
  final Map<String, List<Transaction>> groupedTransactions;
  final Map<int, double> categoryTotals;
  final double totalSpent;

  RecordsAnalyticsLoaded(this.groupedTransactions, this.categoryTotals, this.totalSpent);
}

class RecordsError extends RecordsState {
  final String errorMessage;

  RecordsError(this.errorMessage);
}