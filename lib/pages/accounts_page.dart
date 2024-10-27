import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mymoney/bloc/accounts_cubit/accounts_cubit.dart';
import 'package:mymoney/components/add_account_alert_dialogue.dart';
import 'package:mymoney/components/balance_text_widget.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/models/account_model.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

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
              Center(child: _buildAddNewAccountButton(context)),
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
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.lightYellow),
          color: AppColors.darkGray,
          onSelected: (value) {
            if (value == 'edit') {
              _editAccount(context, account);
            } else if (value == 'delete') {
              _deleteAccount(context, account);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text(
                'Edit',
                style: TextStyle(color: AppColors.lightYellow),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.lightYellow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editAccount(BuildContext context, Account account) async {
    // Open dialog to edit the account (reuse the add account dialog, but pass account data for editing)
    final isEdited = await showAddAccountDialog(context, account: account);
    if (isEdited) {
      if (!context.mounted) return;
      context.read<AccountsCubit>().fetchAccounts();
    }
  }

  void _deleteAccount(BuildContext context, Account account) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      context.read<AccountsCubit>().deleteAccount(account.id!);
      context.read<AccountsCubit>().fetchAccounts();
    }
  }

  Widget _buildAddNewAccountButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        final isAdded = await showAddAccountDialog(context);
        if (isAdded) {
          if (!context.mounted) return;
          context.read<AccountsCubit>().fetchAccounts();
        }
      },
      child: Container(
        width: size.width * 0.6,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
