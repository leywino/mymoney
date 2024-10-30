import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mymoney/bloc/budgets_cubit/budgets_cubit.dart';
import 'package:mymoney/components/show_set_budget_dialogue.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/budgeting_model.dart';
import 'package:mymoney/models/category_model.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetsCubit>().fetchBudgetsForMonth(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGray,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  BlocBuilder<BudgetsCubit, BudgetsState>(
                    builder: (context, state) {
                      final cubit = context.read<BudgetsCubit>();
                      return Text(
                        'Budgeted categories: ${_getMonthName(cubit.selectedMonth.month)}, ${cubit.selectedMonth.year}',
                        style: const TextStyle(
                          color: AppColors.lightYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: AppColors.lightYellow,
                  ),
                ],
              ),
              _buildBudgetedCategoriesSection(),
              const SizedBox(height: 20),
              // Not budgeted categories section
              const Column(
                children: [
                  Text(
                    'Not budgeted this month',
                    style: TextStyle(
                      color: AppColors.lightYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(
                    color: AppColors.lightYellow,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildNotBudgetedCategoriesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetedCategoriesSection() {
    return BlocBuilder<BudgetsCubit, BudgetsState>(
      builder: (context, state) {
        if (state is BudgetsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BudgetsLoaded) {
          if (state.budgets.isEmpty) {
            return const Center(
              child: Text(
                'Currently, no budget is applied for this month.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            );
          }

          return Column(
            children: state.budgets.map((budgetData) {
              final budget = budgetData['budget'] as Budgeting;
              final spentAmount = budgetData['spentAmount'];
              final remainingAmount = budgetData['remainingAmount'];

              return _buildBudgetCard(budget.categoryId, budget.budgetAmount,
                  spentAmount, remainingAmount);
            }).toList(),
          );
        } else if (state is BudgetsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildBudgetCard(int categoryId, double budgetAmount,
      double spentAmount, double remainingAmount) {
    final databaseHelper = DatabaseHelper();

    return Card(
      color: AppColors.customOliveGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Fetch and display the category icon
                FutureBuilder<Category?>(
                  future: databaseHelper.getCategoryWithId(categoryId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.error),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final category = snapshot.data!;
                      return CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(
                            categoryAssetIconList[category.iconNumber]),
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.category),
                      );
                    }
                  },
                ),
                const SizedBox(width: 12),

                // Display category name and current month
                FutureBuilder<Category?>(
                  future: databaseHelper.getCategoryWithId(categoryId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return const Text("Error loading category",
                          style: TextStyle(color: Colors.red));
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final category = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              color: AppColors.lightYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '(${DateFormat.MMM().format(DateTime.now())}, ${DateTime.now().year})',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Text("Unknown Category",
                          style: TextStyle(color: Colors.grey));
                    }
                  },
                ),

                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Add options like edit or delete budget
                  },
                  icon:
                      const Icon(Icons.more_vert, color: AppColors.lightYellow),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Display budget, spent, and remaining amounts
            Row(
              children: [
                Text(
                  'Limit: ₹${budgetAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.lightYellow, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  'Remaining: ₹${remainingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.lightYellow, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Spent: ₹${spentAmount.toStringAsFixed(2)}',
              style:
                  const TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Progress bar indicating budget usage
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.beige,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Container(
                  height: 10,
                  width: _calculateProgressBarWidth(spentAmount, budgetAmount),
                  decoration: BoxDecoration(
                    color: AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateProgressBarWidth(double spentAmount, double budgetLimit) {
    final percentage = spentAmount / budgetLimit;
    return percentage > 1 ? 200 : 200 * percentage;
  }

  Widget _buildNotBudgetedCategoriesList() {
    return BlocBuilder<BudgetsCubit, BudgetsState>(
      builder: (context, state) {
        if (state is BudgetsLoaded) {
          if (state.nonBudgetedCategories.isEmpty) {
            return const Center(child: Text('All categories are budgeted.'));
          }
          return Column(
            children: state.nonBudgetedCategories.map((category) {
              return _buildNotBudgetedCategoryCard(category.name,
                  categoryAssetIconList[category.iconNumber], category.id!);
            }).toList(),
          );
        } else if (state is BudgetsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildNotBudgetedCategoryCard(
      String name, String icon, int categoryId) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[900],
          child: Image.asset(icon),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: AppColors.lightYellow,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _setBudgetForCategory(name, icon, categoryId);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            backgroundColor: AppColors.darkGray,
            side: const BorderSide(color: AppColors.lightYellow, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'SET BUDGET',
            style: TextStyle(
              color: AppColors.lightYellow,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _setBudgetForCategory(
      String categoryName, String iconPath, int categoryId) async {
    final isAdded =
        await showSetBudgetDialog(context, categoryName, iconPath, categoryId);
    if (isAdded) {
      setState(() {});
    }
  }

  String _getMonthName(int month) {
    return DateFormat.MMM().format(DateTime(0, month));
  }
}
