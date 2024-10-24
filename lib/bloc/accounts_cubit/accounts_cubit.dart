import 'package:bloc/bloc.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/account_model.dart';

part 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final DatabaseHelper _databaseHelper;

  AccountsCubit(this._databaseHelper) : super(AccountsInitial());

  Future<void> fetchAccounts() async {
    try {
      emit(AccountsLoading());
      final accounts = await _databaseHelper.getAllAccounts();
      emit(AccountsLoaded(accounts));
    } catch (e) {
      emit(AccountsError('Failed to fetch accounts: $e'));
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      await _databaseHelper.insertAccount(account);
      fetchAccounts();
    } catch (e) {
      emit(AccountsError('Failed to add account: $e'));
    }
  }

  Future<void> deleteAccount(int accountId) async {
    try {
      await _databaseHelper.deleteAccount(accountId);
      fetchAccounts();
    } catch (e) {
      emit(AccountsError('Failed to delete account: $e'));
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _databaseHelper.updateAccountBalance(account.id!, account.balance);
      fetchAccounts();
    } catch (e) {
      emit(AccountsError('Failed to update account: $e'));
    }
  }
}