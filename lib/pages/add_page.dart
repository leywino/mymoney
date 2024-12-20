import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mymoney/bloc/accounts_cubit/accounts_cubit.dart';
import 'package:mymoney/bloc/records_cubit/records_cubit.dart';
import 'package:mymoney/components/add_account_alert_dialogue.dart';
import 'package:mymoney/components/balance_text_widget.dart';
import 'package:mymoney/components/calculator_widget.dart';
import 'package:mymoney/components/date_time_picker.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/account_model.dart';
import 'package:mymoney/models/category_model.dart';
import 'package:mymoney/models/transaction_model.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key, this.transaction});

  final Transaction? transaction;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<bool> isSelected = [false, true, false];
  String? selectedDateAndTime;
  double? amount;
  Account? firstAccount;
  Account? secondAccount;
  Category? category;
  final TextEditingController _noteController = TextEditingController();
  final GlobalKey<CalculatorScreenState> _calculatorGlobalKey =
      GlobalKey<CalculatorScreenState>();

  Future<Account?> _showAccountSelection() async {
    final dbHelper = DatabaseHelper();
    List<Account> accounts = await dbHelper.getAllAccounts();

    if (!mounted) return null;

    final result = await showModalBottomSheet(
      backgroundColor: AppColors.grayBrown,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Account',
                      style:
                          TextStyle(color: AppColors.lightYellow, fontSize: 20),
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        Account account = accounts[index];
                        return ListTile(
                          leading: Image.asset(
                            accountsAssetIconList[account.iconNumber!],
                            height: 30,
                          ),
                          title: Text(
                            account.name,
                            style: const TextStyle(
                              color: AppColors.lightYellow,
                            ),
                          ),
                          trailing: BalanceTextWidget(
                            balance: account.balance,
                            fontSize: 16,
                          ),
                          onTap: () {
                            Navigator.pop(context, [account]);
                          },
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () async {
                        final isAdded = await showAddAccountDialog(context);
                        if (!context.mounted) return;

                        if (isAdded) {
                          List<Account> updatedAccounts =
                              await dbHelper.getAllAccounts();

                          setState(() {
                            accounts = updatedAccounts;
                          });
                        }
                      },
                      child: const Text(
                        'Add New Account',
                        style: TextStyle(
                          color: AppColors.lightYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<Category?> _showCategorySelection(String type) async {
    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> categories =
        await dbHelper.getCategoriesByTypeMap(type);

    if (!mounted) return null;

    final result = await showModalBottomSheet(
      backgroundColor: AppColors.grayBrown,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Select Category ($type)',
                  style: const TextStyle(
                      color: AppColors.lightYellow, fontSize: 20),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.9,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> categoryMap = categories[index];
                      return GestureDetector(
                        onTap: () {
                          Category category = Category(
                              name: categoryMap['name'],
                              iconNumber: categoryMap['iconNumber'],
                              type: categoryMap['type'],
                              id: categoryMap['id']);
                          Navigator.pop(context, [category]);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              categoryAssetIconList[categoryMap['iconNumber']],
                              height: 40,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              categoryMap['name'],
                              style: const TextStyle(
                                color: AppColors.lightYellow,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Box.h12,
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<void> _autoFillIfEdit() async {
    if (widget.transaction == null) return;
    final dbHelper = DatabaseHelper();
    if (widget.transaction!.type.toLowerCase() == "transfer") {
      final account =
          await dbHelper.getAccountWithId(widget.transaction!.accountId);
      final secondAccount =
          await dbHelper.getAccountWithId(widget.transaction!.toAccountId!);
      setState(() {
        selectedDateAndTime = widget.transaction!.date;
        firstAccount = account;
        this.secondAccount = secondAccount;
        isSelected = [false, false, true];
        _noteController.text = widget.transaction!.notes ?? "";
      });
    } else {
      bool isExpense = widget.transaction!.type.toLowerCase() == "expense";
      final account =
          await dbHelper.getAccountWithId(widget.transaction!.accountId);
      final category =
          await dbHelper.getCategoryWithId(widget.transaction!.categoryId);
      setState(() {
        selectedDateAndTime = widget.transaction!.date;
        firstAccount = account;
        this.category = category;
        amount = widget.transaction!.amount;
        isExpense
            ? isSelected = [false, true, false]
            : isSelected = [true, false, false];
        _noteController.text = widget.transaction!.notes ?? "";
      });
    }
  }

  @override
  void initState() {
    selectedDateAndTime = DateTime.now().toIso8601String();
    _autoFillIfEdit();
    super.initState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.darkGray,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.darkGray,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            style: const ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(AppColors.gold)),
            label: const Text(
              'CANCEL',
            ),
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton.icon(
            style: const ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(AppColors.gold)),
            label: const Text(
              'SAVE',
            ),
            onPressed: () {
              isSelected[2] ? _saveTransfer() : _saveTransaction();
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToggleButtons(
                    borderWidth: 0,
                    borderColor: Colors.transparent,
                    fillColor: Colors.transparent,
                    selectedColor: AppColors.lightYellow,
                    color: Colors.grey[400],
                    isSelected: isSelected,
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < isSelected.length;
                            buttonIndex++) {
                          isSelected[buttonIndex] = buttonIndex == index;
                        }
                      });
                    },
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            if (isSelected[0]) checkIcon(),
                            Text(
                              'INCOME',
                              style: TextStyle(
                                fontWeight: isSelected[0]
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected[0]
                                    ? AppColors.lightYellow
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            if (isSelected[1]) checkIcon(),
                            Text(
                              'EXPENSE',
                              style: TextStyle(
                                fontWeight: isSelected[1]
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected[1]
                                    ? AppColors.lightYellow
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            if (isSelected[2]) checkIcon(),
                            Text(
                              'TRANSFER',
                              style: TextStyle(
                                fontWeight: isSelected[2]
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected[2]
                                    ? AppColors.lightYellow
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                buildCustomButton(
                  context,
                  title: _buildTitle(0),
                  icon: firstAccount == null
                      ? const Icon(
                          Icons.credit_card,
                          color: AppColors.lightYellow,
                        )
                      : Image.asset(
                          accountsAssetIconList[firstAccount!.iconNumber!]),
                  label: firstAccount == null ? 'Account' : firstAccount!.name,
                  onTap: () async {
                    Account? account = await _showAccountSelection();
                    if (account != null) {
                      setState(() {
                        firstAccount = account;
                      });
                    }
                  },
                ),
                Box.w4,
                if (isSelected[2])
                  buildCustomButton(
                    context,
                    title: _buildTitle(1),
                    icon: secondAccount == null
                        ? const Icon(
                            Icons.credit_card,
                            color: AppColors.lightYellow,
                          )
                        : Image.asset(
                            accountsAssetIconList[secondAccount!.iconNumber!]),
                    label:
                        secondAccount == null ? 'Account' : secondAccount!.name,
                    onTap: () async {
                      Account? account = await _showAccountSelection();
                      if (account != null) {
                        setState(() {
                          secondAccount = account;
                        });
                      }
                    },
                  )
                else
                  buildCustomButton(
                    onTap: () async {
                      Category? category = await _showCategorySelection(
                          isSelected[0] ? 'income' : 'expense');
                      if (category != null) {
                        setState(() {
                          this.category = category;
                        });
                      }
                    },
                    context,
                    title: _buildTitle(1),
                    icon: category == null
                        ? const Icon(
                            Icons.label,
                            color: AppColors.lightYellow,
                          )
                        : Image.asset(
                            categoryAssetIconList[category!.iconNumber]),
                    label: category == null ? 'Category' : category!.name,
                  ),
              ],
            ),
            Box.h4,
            Expanded(child: buildNoteContainer()),
            CalculatorScreen(
              onCalculate: (amount) => setState(() {
                this.amount = amount;
              }),
              initialAmount: widget.transaction?.amount.abs().toString(),
            ),
            DateTimePickerWidget(
              onDateChanged: (selectedDateAndTime) => setState(() {
                this.selectedDateAndTime = selectedDateAndTime;
              }),
              initialDateTime: widget.transaction?.date,
            ),
          ],
        ),
      ),
    );
  }

  String _buildTitle(int i) {
    switch (i) {
      case 0:
        if (isSelected[2]) {
          return 'From';
        }
        return 'Account';
      case 1:
        if (isSelected[2]) {
          return 'To';
        }
        return 'Category';
      default:
        return 'Default';
    }
  }

  Row checkIcon() {
    return const Row(
      children: [
        Icon(Icons.check_circle, color: AppColors.lightYellow, size: 16),
        SizedBox(width: 4),
      ],
    );
  }

  Widget buildNoteContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.beige, width: 2),
        color: AppColors.oliveGray,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: _noteController,
          style: const TextStyle(color: AppColors.lightYellow),
          maxLines: null,
          decoration: const InputDecoration.collapsed(
              hintText: 'Add notes',
              hintStyle: TextStyle(color: AppColors.beige)),
        ),
      ),
    );
  }

  Widget buildCustomButton(BuildContext context,
      {required String title,
      required Widget icon,
      required String label,
      Function()? onTap}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.beige, width: 2),
            ),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 22, width: 22, child: icon),
                    Box.w3,
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.lightYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveTransfer() {
    if (firstAccount == null) {
      Fluttertoast.showToast(
        msg: 'please select an account',
        backgroundColor: AppColors.beige,
        textColor: AppColors.lightYellow,
      );
      return;
    }

    if (secondAccount == null) {
      Fluttertoast.showToast(
        msg: 'please select an account',
        backgroundColor: AppColors.beige,
        textColor: AppColors.lightYellow,
      );
      return;
    }

    if (amount == null || amount == 0) {
      if (_calculatorGlobalKey.currentState != null) {
        _calculatorGlobalKey.currentState!.changeDisplayColor();
      }
      Fluttertoast.showToast(
        msg: 'please enter amount',
        backgroundColor: AppColors.beige,
        textColor: AppColors.lightYellow,
      );
      return;
    }

    final dbHelper = DatabaseHelper();
    Transaction transaction = Transaction(
        accountId: firstAccount!.id!,
        toAccountId: secondAccount!.id!,
        categoryId: 0,
        amount: amount!,
        date: selectedDateAndTime!,
        type: "transfer");
    dbHelper.transferMoney(transaction);
    context.read<RecordsCubit>().fetchRecords();
    context.read<AccountsCubit>().fetchAccounts();
    Navigator.pop(context);
  }

  void _saveTransaction() {
    if (firstAccount == null) {
      Fluttertoast.showToast(
        msg: 'please select an account',
        backgroundColor: AppColors.beige,
        textColor: AppColors.lightYellow,
      );
      return;
    }
    if (category == null) {
      Fluttertoast.showToast(
        msg: 'please select a category',
        backgroundColor: AppColors.beige,
        textColor: AppColors.lightYellow,
      );
      return;
    }
    if (amount == null || amount == 0) {
      if (_calculatorGlobalKey.currentState != null) {
        _calculatorGlobalKey.currentState!.changeDisplayColor();
      }
      Fluttertoast.showToast(
        msg: 'please enter amount',
        backgroundColor: AppColors.beige,
        textColor: AppColors.lightYellow,
      );
      return;
    }
    if (isSelected[1]) {
      amount = 0 - amount!;
    }
    final dbHelper = DatabaseHelper();
    Transaction transaction = Transaction(
        accountId: firstAccount!.id!,
        categoryId: category!.id!,
        amount: amount!,
        date: selectedDateAndTime!,
        type: _buildTrasactionType(),
        notes: _noteController.text);
    bool isEditing = widget.transaction != null;
    if (isEditing) {
      final updatedTransaction =
          transaction.copyWith(id: widget.transaction!.id);
      double updatedAmount = widget.transaction!.amount - amount!;
      dbHelper.updateTransaction(updatedTransaction);
      dbHelper.updateAccountBalance(firstAccount!.id!, updatedAmount);
    } else {
      dbHelper.insertTransaction(transaction);
      dbHelper.updateAccountBalance(firstAccount!.id!, amount!);
    }

    context.read<AccountsCubit>().fetchAccounts();
    context.read<RecordsCubit>().fetchRecords();
    Navigator.pop(context);
  }

  String _buildTrasactionType() {
    if (isSelected[0]) {
      return "INCOME";
    }
    if (isSelected[1]) {
      return "EXPENSE";
    }
    if (isSelected[2]) {
      return "TRANSFER";
    }
    return "EXPENSE";
  }
}
