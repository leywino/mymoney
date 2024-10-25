import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // for formatting the date
import 'package:mymoney/bloc/accounts_cubit/accounts_cubit.dart';
import 'package:mymoney/bloc/records_cubit/records_cubit.dart';
import 'package:mymoney/components/delete_record_alert_dialogue.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/models/account_model.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/transaction_model.dart';
import 'package:mymoney/pages/add_page.dart';
import 'package:page_transition/page_transition.dart';

Future<void> showRecordDetailsDialog(
    BuildContext context, Transaction transaction,
    [bool isTransfer = false]) async {
  final databaseHelper = DatabaseHelper();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.zero,
        content: FutureBuilder(
          future: Future.wait([
            databaseHelper.getAccountWithId(transaction.accountId),
            isTransfer
                ? databaseHelper.getAccountWithId(transaction.toAccountId!)
                : databaseHelper.getCategoryWithId(transaction.categoryId),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading details'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No details found'));
            }
            final Account? account = snapshot.data![0];
            final categoryOrAccount = snapshot.data![1];
            final formattedDate = DateFormat('MMM dd, yyyy h:mm a')
                .format(DateTime.parse(transaction.date));
            String transactionAmount =
                "₹${NumberFormat('#.##').format(transaction.amount.abs())}";

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.gold, // top part color
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Box.h40,
                          Text(
                            transaction.type.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.lightYellow,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            transactionAmount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: AppColors.lightYellow,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close_outlined,
                              color: AppColors.lightYellow),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.lightYellow),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                duration: const Duration(milliseconds: 350),
                                type: PageTransitionType.rightToLeft,
                                child: AddPage(transaction: transaction),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_outlined,
                              color: AppColors.lightYellow),
                          onPressed: () async {
                            final canDelete =
                                await showDeleteRecordDialog(context);
                            if (canDelete) {
                              databaseHelper.deleteTransaction(transaction.id!);
                              if (!context.mounted) return;
                              context.read<AccountsCubit>().fetchAccounts();
                              context.read<RecordsCubit>().fetchRecords();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account row
                      Row(
                        children: [
                          Text(
                            isTransfer ? 'From' : 'Account',
                            style: const TextStyle(
                              color: AppColors.lightYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.oliveGray,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                account != null
                                    ? Image.asset(
                                        accountsAssetIconList[
                                            account.iconNumber!],
                                        height: 24,
                                      )
                                    : const Icon(
                                        Icons.category,
                                        size: 24,
                                      ),
                                const SizedBox(width: 4),
                                Text(
                                  account != null ? account.name : "Unknown",
                                  style: const TextStyle(
                                    color: AppColors.lightYellow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            isTransfer ? 'To' : 'Category',
                            style: const TextStyle(
                              color: AppColors.lightYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.oliveGray,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                categoryOrAccount != null
                                    ? Image.asset(
                                        isTransfer
                                            ? accountsAssetIconList[
                                                categoryOrAccount.iconNumber!]
                                            : categoryAssetIconList[
                                                categoryOrAccount!.iconNumber],
                                        height: 24,
                                      )
                                    : const Icon(
                                        Icons.category,
                                        size: 24,
                                      ),
                                const SizedBox(width: 4),
                                Text(
                                  categoryOrAccount != null
                                      ? categoryOrAccount.name
                                      : "Unknown",
                                  style: const TextStyle(
                                    color: AppColors.lightYellow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (transaction.notes != null &&
                          transaction.notes!.isNotEmpty)
                        Text(
                          transaction.notes!,
                          style:
                              const TextStyle(color: AppColors.secondaryText),
                        )
                      else
                        const Text(
                          'No notes',
                          style: TextStyle(color: AppColors.secondaryText),
                        ),
                      Box.h40,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
