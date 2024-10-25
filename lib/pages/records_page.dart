import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mymoney/bloc/records_cubit/records_cubit.dart';
import 'package:mymoney/components/balance_text_widget.dart';
import 'package:mymoney/components/show_record_details_dialgoue.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/core/strings.dart';
import 'package:mymoney/models/account_model.dart';
import 'package:mymoney/models/category_model.dart';
import 'package:mymoney/models/transaction_model.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGray,
      body: BlocBuilder<RecordsCubit, RecordsState>(
        builder: (context, state) {
          if (state is RecordsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecordsAnalyticsLoaded) {
            final groupedTransactions = state.groupedTransactions;

            if (groupedTransactions.isEmpty) {
              return const Center(
                child: Text(
                  "No records found",
                  style: TextStyle(
                    color: AppColors.lightYellow,
                  ),
                ),
              );
            }

            return ListView.builder(
              controller: scrollController,
              shrinkWrap: true,
              itemCount: groupedTransactions.length,
              itemBuilder: (context, index) {
                final transactionDay =
                    groupedTransactions.keys.elementAt(index);
                final transactions = groupedTransactions[transactionDay]!;

                // Format the date nicely (e.g., 'Oct 19, Saturday')
                final formattedDate = DateFormat('MMM dd, EEEE')
                    .format(DateTime.parse(transactions.first.date));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 16.0),
                          child: Text(
                            textAlign: TextAlign.start,
                            formattedDate,
                            style: const TextStyle(
                              color: AppColors.lightYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Divider(
                          color: AppColors.lightYellow,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: ListView.builder(
                        itemCount: transactions.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          if (transaction.type.toLowerCase() == "expense" ||
                              transaction.type.toLowerCase() == "income") {
                            return _buildTransactionItem(transaction,
                                transactions.length, index, context);
                          } else {
                            return _buildTransferItem(transaction,
                                transactions.length, index, context);
                          }
                        },
                      ),
                    )
                  ],
                );
              },
            );
          } else if (state is RecordsError) {
            return Center(child: Text((state).errorMessage));
          }
          return const Center(child: Text("No transactions found."));
        },
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, int totalLength,
      int index, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final databaseHelper = DatabaseHelper();
    return InkWell(
      onTap: () {
        showRecordDetailsDialog(context, transaction);
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Transaction category icon
                  FutureBuilder<Category?>(
                    future: databaseHelper
                        .getCategoryWithId(transaction.categoryId),
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
                            categoryAssetIconList[category.iconNumber],
                          ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Category?>(
                        future: databaseHelper
                            .getCategoryWithId(transaction.categoryId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          } else if (snapshot.hasError) {
                            return const SizedBox.shrink();
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            final category = snapshot.data!;
                            return Text(
                              category.name,
                              style: const TextStyle(
                                color: AppColors.lightYellow,
                                fontWeight: FontWeight.bold,
                              ),
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
                      FutureBuilder<Account?>(
                        future: databaseHelper.getAccountWithId(
                            transaction.accountId), // Fetch account by ID
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Show a placeholder while loading
                            return const Row(
                              children: [
                                SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(),
                                ),
                                SizedBox(width: 4),
                                Text('Loading...',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            // Show error state
                            return const Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 16),
                                SizedBox(width: 4),
                                Text('Error loading account',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            final account = snapshot.data!;
                            return Row(
                              children: [
                                Image.asset(
                                  accountsAssetIconList[account.iconNumber!],
                                  height: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  account.name,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            );
                          } else {
                            // Fallback in case no account is found
                            return const Row(
                              children: [
                                Icon(Icons.account_balance_wallet,
                                    color: Colors.grey, size: 16),
                                SizedBox(width: 4),
                                Text('Unknown Account',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
              // Transaction amount (styled for negative/positive values)
              BalanceTextWidget(
                balance: transaction.amount,
                isSymbol: true,
              )
            ],
          ),
          if (index != totalLength - 1 && totalLength != 1)
            Divider(
              indent: size.width * 0.15,
              color: AppColors.lightBeige,
              thickness: 0.5,
            )
        ],
      ),
    );
  }

  Widget _buildTransferItem(Transaction transaction, int totalLength, int index,
      BuildContext context) {
    final size = MediaQuery.of(context).size;
    final databaseHelper = DatabaseHelper();
    return InkWell(
      onTap: () {
        showRecordDetailsDialog(context, transaction, true);
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Display the transfer icon for "TRANSFER" type
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(
                      'assets/icons/transfer.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transfer',
                        style: TextStyle(
                          color: AppColors.lightYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Show From Account
                          FutureBuilder<Account?>(
                            future: databaseHelper
                                .getAccountWithId(transaction.accountId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'Error',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
                                final fromAccount = snapshot.data!;
                                return Row(
                                  children: [
                                    Image.asset(
                                      accountsAssetIconList[
                                          fromAccount.iconNumber!],
                                      height: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      fromAccount.name,
                                      style: const TextStyle(
                                        color: AppColors.lightYellow,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const Text(
                                  'Unknown Account',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward,
                              size: 16, color: AppColors.lightYellow),
                          const SizedBox(width: 4),

                          // Show To Account
                          FutureBuilder<Account?>(
                            future: databaseHelper
                                .getAccountWithId(transaction.toAccountId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'Error',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
                                final toAccount = snapshot.data!;
                                return Row(
                                  children: [
                                    Image.asset(
                                      accountsAssetIconList[
                                          toAccount.iconNumber!],
                                      height: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      toAccount.name,
                                      style: const TextStyle(
                                        color: AppColors.lightYellow,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const Text(
                                  'Unknown Account',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Transaction amount (styled for negative/positive values)
              Text(
                "$currentCurrency${transaction.amount}",
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              )
            ],
          ),
          if (index != totalLength - 1 && totalLength != 1)
            Divider(
              indent: size.width * 0.15,
              color: AppColors.lightBeige,
              thickness: 0.5,
            ),
        ],
      ),
    );
  }
}
