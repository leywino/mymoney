import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/account_model.dart';

Future<bool> showAddAccountDialog(BuildContext context,
    {Account? account}) async {
  TextEditingController nameController = TextEditingController();
  TextEditingController initialAmountController = TextEditingController();
  int? selectedIconIndex;
  if (account != null) {
    nameController.text = account.name;
    initialAmountController.text = NumberFormat('#.##').format(account.balance);
    selectedIconIndex = account.iconNumber;
  }

  final databaseHelper = DatabaseHelper();
  final size = MediaQuery.of(context).size;

  if (!context.mounted) return false;
  final result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.darkGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text(
              'Add new account',
              style: TextStyle(
                  color: AppColors.lightYellow, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: initialAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.lightYellow),
                  decoration: InputDecoration(
                    labelText: 'Initial amount',
                    labelStyle: const TextStyle(color: AppColors.lightBeige),
                    filled: true,
                    fillColor: AppColors.oliveGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '*Initial amount will not be reflected in analysis',
                  style:
                      TextStyle(color: AppColors.secondaryText, fontSize: 10),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.lightYellow),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: AppColors.lightBeige),
                    filled: true,
                    fillColor: AppColors.oliveGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.oliveGray,
                    border: Border.all(
                      color: AppColors.lightYellow,
                      width: 3.0,
                    ),
                  ),
                  child: SizedBox(
                    height: 52,
                    width: size.width * 0.8,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: accountsAssetIconList.length,
                      itemBuilder: (context, index) {
                        final accountPath = accountsAssetIconList[index];
                        final isSelected = index == selectedIconIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIconIndex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.lightBeige
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.gold,
                                        width: 2.0,
                                      )
                                    : null,
                              ),
                              child: Image.asset(
                                accountPath,
                                height: 48,
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
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.customGray,
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppColors.lightYellow),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.gold,
                ),
                onPressed: () {
                  double? initialAmount =
                      double.tryParse(initialAmountController.text);

                  if (nameController.text.isNotEmpty &&
                      initialAmount != null &&
                      selectedIconIndex != null) {
                    databaseHelper.insertAccount(Account(
                        name: nameController.text,
                        balance: initialAmount,
                        iconNumber: selectedIconIndex));
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please enter a valid name and amount.')),
                    );
                  }
                },
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
  );

  return result;
}
