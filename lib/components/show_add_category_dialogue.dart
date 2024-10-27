import 'package:flutter/material.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';

Future<bool> showAddCategoryDialog(BuildContext context) async {
  String categoryName = '';
  bool isExpense = true; // Default to expense type
  int selectedIconIndex = 0;
  final size = MediaQuery.of(context).size;

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
                  'Add new category',
                  style: TextStyle(
                    color: AppColors.lightYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Type:',
                            style: TextStyle(
                              color: AppColors.lightYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => isExpense = false),
                                child: Text(
                                  'INCOME',
                                  style: TextStyle(
                                    color: isExpense
                                        ? AppColors.secondaryText
                                        : AppColors.lightYellow,
                                    fontWeight: isExpense
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => setState(() => isExpense = true),
                                child: Text(
                                  'EXPENSE',
                                  style: TextStyle(
                                    color: isExpense
                                        ? AppColors.lightYellow
                                        : AppColors.secondaryText,
                                    fontWeight: isExpense
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Name Input
                      TextField(
                        onChanged: (value) => categoryName = value,
                        style: const TextStyle(color: AppColors.lightYellow),
                        decoration: InputDecoration(
                          hintText: 'Untitled',
                          hintStyle:
                              const TextStyle(color: AppColors.secondaryText),
                          filled: true,
                          fillColor: AppColors.oliveGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Icon List
                      const Text(
                        'Icon',
                        style: TextStyle(
                          color: AppColors.lightYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.oliveGray,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        child: SizedBox(
                          height: 52,
                          width: size.width * 0.8,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryAssetIconList.length,
                            itemBuilder: (context, index) {
                              final accountPath = categoryAssetIconList[index];
                              final isSelected = index == selectedIconIndex;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIconIndex = index;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.lightBeige
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: isSelected
                                          ? Border.all(
                                              color: AppColors.gold,
                                              width: 1.0,
                                            )
                                          : null,
                                    ),
                                    child: Image.asset(
                                      accountPath,
                                      height: 44,
                                      width: 48,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  // Save Button
                  TextButton(
                    onPressed: () {
                      if (categoryName.isNotEmpty) {
                        // Implement logic to save the category
                        Navigator.pop(context, true);
                      } else {
                        // Show a message if the name is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a category name.'),
                          ),
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
                      'SAVE',
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
