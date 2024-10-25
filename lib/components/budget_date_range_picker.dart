import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mymoney/bloc/budgets_cubit/budgets_cubit.dart';
import 'package:intl/intl.dart';
import 'package:mymoney/core/color.dart';

class BudgetDateRangePicker extends StatelessWidget {
  const BudgetDateRangePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetsCubit, BudgetsState>(
      builder: (context, state) {
        final cubit = context.read<BudgetsCubit>();

        String formattedMonth =
            DateFormat('MMMM yyyy').format(cubit.selectedMonth);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: AppColors.lightYellow),
                onPressed: () {
                  cubit.moveMonth(false); // Move to the previous month
                },
              ),
              // Display the current month
              Text(
                formattedMonth,
                style: const TextStyle(
                  color: AppColors.lightYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // Next button
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: AppColors.lightYellow),
                onPressed: () {
                  cubit.moveMonth(true); // Move to the next month
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
