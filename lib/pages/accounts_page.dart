import 'package:flutter/material.dart';
import 'package:mymoney/components/balance_text_widget.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/account_model.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGray,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Account>>(
              future: DatabaseHelper().getAllAccounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No accounts found.'));
                }

                // Display the list of accounts
                final accounts = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return _buildAccountCard(context, account);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _buildAddNewAccountButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, Account account) {
    bool isNegative = account.balance < 0;

    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(width: 1, color: AppColors.lightYellow)),
      margin: const EdgeInsets.only(bottom: 16.0),
      color: AppColors.customOliveGray,
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[900],
          child: Image.asset(accountsAssetIconList[account.iconNumber!]),
        ),
        title: Text(
          account.name,
          style: const TextStyle(
            color: AppColors.lightYellow,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: BalanceTextWidget(
          balance: account.balance,
          isMinusOnly: true,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.lightYellow),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildAddNewAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.lightYellow, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.lightYellow),
            SizedBox(width: 8),
            Text(
              'ADD NEW ACCOUNT',
              style: TextStyle(
                color: AppColors.lightYellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
