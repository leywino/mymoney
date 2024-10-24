part of 'accounts_cubit.dart';

class AccountsState {}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final List<Account> accounts;

  AccountsLoaded(this.accounts);
}

class AccountsError extends AccountsState {
  final String errorMessage;

  AccountsError(this.errorMessage);
}
