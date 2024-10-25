import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mymoney/bloc/budgets_cubit/budgets_cubit.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';

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
              final budget = budgetData['budget'];
              final spentAmount = budgetData['spentAmount'];
              final remainingAmount = budgetData['remainingAmount'];

              return _buildBudgetCard(
                  budget.categoryId, spentAmount, remainingAmount);
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

  Widget _buildBudgetCard(
      int categoryId, double spentAmount, double remainingAmount) {
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
                CircleAvatar(
                  backgroundColor: AppColors.lightYellow,
                  radius: 24,
                  child: Image.asset('assets/icons/expense/clothing.png'),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clothing',
                      style: TextStyle(
                        color: AppColors.lightYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '(Oct, 2024)',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon:
                      const Icon(Icons.more_vert, color: AppColors.lightYellow),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Limit: ₹500.00',
                  style: TextStyle(color: AppColors.lightYellow, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  'Remaining: ₹$remainingAmount',
                  style: const TextStyle(
                      color: AppColors.lightYellow, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Spent: ₹$spentAmount',
              style:
                  const TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
            const SizedBox(height: 12),
            // Progress bar
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
                  width: _calculateProgressBarWidth(spentAmount, 500),
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
              return _buildNotBudgetedCategoryCard(
                  category.name, categoryAssetIconList[category.iconNumber]);
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

  Widget _buildNotBudgetedCategoryCard(String name, String icon) {
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
            // Handle Set Budget action
            _setBudgetForCategory(name);
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

  void _setBudgetForCategory(String categoryName) {
    // Implement logic for setting a budget for the category
  }

  String _getMonthName(int month) {
    return DateFormat.MMM().format(DateTime(0, month));
  }
}
