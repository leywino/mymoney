part of 'budgets_cubit.dart';

abstract class BudgetsState {}

class BudgetsLoading extends BudgetsState {}

class BudgetsLoaded extends BudgetsState {
  final List<Map<String, dynamic>> budgets;
  final List<Category> nonBudgetedCategories;

  BudgetsLoaded(this.budgets, this.nonBudgetedCategories);
}
class BudgetsError extends BudgetsState {
  final String message;

  BudgetsError(this.message);
}
