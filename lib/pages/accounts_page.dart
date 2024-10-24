import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mymoney/bloc/accounts_cubit/accounts_cubit.dart';
import 'package:mymoney/components/add_account_alert_dialogue.dart';
import 'package:mymoney/components/balance_text_widget.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/models/account_model.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountsCubit>().fetchAccounts();
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
              BlocBuilder<AccountsCubit, AccountsState>(
                builder: (context, state) {
                  if (state is AccountsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AccountsError) {
                    return Center(child: Text('Error: ${state.errorMessage}'));
                  } else if (state is AccountsLoaded) {
                    if (state.accounts.isEmpty) {
                      return const Center(child: Text('No accounts found.'));
                    }

                    final accounts = state.accounts;
                    return ListView.builder(
                      shrinkWrap: true,
                      controller: widget.scrollController,
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return _buildAccountCard(context, account);
                      },
                    );
                  }
                  return const SizedBox
                      .shrink(); // Placeholder for other states
                },
              ),
              const SizedBox(height: 16),
              _buildAddNewAccountButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, Account account) {
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
          onPressed: () {
            context
                .read<AccountsCubit>()
                .deleteAccount(account.id!); // Delete account
          },
        ),
      ),
    );
  }

  Widget _buildAddNewAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final isAdded = await showAddAccountDialog(context);
        if (isAdded) {
          if (!context.mounted) return;
          context.read<AccountsCubit>().fetchAccounts();
        }
      },
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
