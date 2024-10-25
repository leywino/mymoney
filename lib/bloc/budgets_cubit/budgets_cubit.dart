import 'package:bloc/bloc.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/budgeting_model.dart';
import 'package:mymoney/models/transaction_model.dart';
import 'package:mymoney/models/category_model.dart';

part 'budgets_state.dart';

class BudgetsCubit extends Cubit<BudgetsState> {
  final DatabaseHelper _databaseHelper;
  DateTime selectedMonth = DateTime.now();

  BudgetsCubit(this._databaseHelper) : super(BudgetsLoading()) {
    fetchBudgetsForMonth(selectedMonth);
  }

  Future<void> fetchBudgetsForMonth(DateTime month) async {
    try {
      emit(BudgetsLoading());

      List<Transaction> allTransactions = await _databaseHelper.getAllTransactions();
      List<Budgeting> allBudgets = await _databaseHelper.getAllBudgets();
      List<Category> allExpenseCategories = await _databaseHelper.getCategoriesByTypeList('expense');

      List<Transaction> currentMonthTransactions = allTransactions.where((transaction) {
        DateTime transactionDate = DateTime.parse(transaction.date);
        return transactionDate.month == month.month && transactionDate.year == month.year;
      }).toList();

      Map<int, double> categorySpentMap = {};
      for (var transaction in currentMonthTransactions) {
        if (transaction.amount < 0) { 
          categorySpentMap[transaction.categoryId] = 
            (categorySpentMap[transaction.categoryId] ?? 0) + transaction.amount.abs();
        }
      }

      List<Map<String, dynamic>> updatedBudgets = [];
      for (var budget in allBudgets) {
        double spentAmount = categorySpentMap[budget.categoryId] ?? 0.0;
        double remainingAmount = budget.budgetAmount - spentAmount;

        updatedBudgets.add({
          'budget': budget,
          'spentAmount': spentAmount,
          'remainingAmount': remainingAmount > 0 ? remainingAmount : 0,
        });
      }

      List<Category> nonBudgetedCategories = allExpenseCategories.where((category) {
        return !allBudgets.any((budget) => budget.categoryId == category.id);
      }).toList();

      emit(BudgetsLoaded(updatedBudgets, nonBudgetedCategories));
    } catch (e) {
      emit(BudgetsError("Failed to load budgets: $e"));
    }
  }


  void moveMonth(bool isNext) {
    selectedMonth = isNext
        ? DateTime(selectedMonth.year, selectedMonth.month + 1)
        : DateTime(selectedMonth.year, selectedMonth.month - 1);

    fetchBudgetsForMonth(selectedMonth);
  }


  Future<void> setBudget(int categoryId, double amount) async {
    try {
      await _databaseHelper.insertBudget(Budgeting(
        categoryId: categoryId,
        budgetAmount: amount,
      ));

      fetchBudgetsForMonth(selectedMonth);
    } catch (e) {
      emit(BudgetsError("Failed to set budget: $e"));
    }
  }
}
