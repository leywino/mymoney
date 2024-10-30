import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/budgeting_model.dart';

Future<bool> showSetBudgetDialog(
    BuildContext context, String categoryName, String iconPath, int categoryId) async {
  TextEditingController limitController = TextEditingController();

  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: AppColors.customOliveGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text(
                  'Set budget',
                  style: TextStyle(
                    color: AppColors.lightYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.lightYellow,
                          radius: 24,
                          child: Image.asset(iconPath),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          categoryName,
                          style: const TextStyle(
                            color: AppColors.lightYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Limit input
                    TextField(
                      controller: limitController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Limit',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: AppColors.lightBeige,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.lightYellow),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.lightYellow, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.lightYellow, width: 3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Display month
                    Text(
                      'Month: ${DateFormat('MMMM, yyyy').format(DateTime.now())}',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.darkGray,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: AppColors.lightYellow),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: AppColors.lightYellow),
                    ),
                  ),
                  // Set Button
                  TextButton(
                    onPressed: () {
                      if (limitController.text.isNotEmpty) {
                        Budgeting budget = Budgeting(budgetAmount: double.parse(limitController.text),categoryId: categoryId);
                        DatabaseHelper().insertBudget(budget);
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a limit amount.')),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'SET',
                      style: TextStyle(color: AppColors.darkGray),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ) ??
      false;
}
