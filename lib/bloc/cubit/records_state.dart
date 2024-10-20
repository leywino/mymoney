part of 'records_cubit.dart';

abstract class RecordsState {}

class RecordsLoading extends RecordsState {}

class RecordsLoaded extends RecordsState {
  final Map<String, List<Transaction>> groupedTransactions;

  RecordsLoaded(this.groupedTransactions);
}

class RecordsError extends RecordsState {
  final String errorMessage;

  RecordsError(this.errorMessage);
}