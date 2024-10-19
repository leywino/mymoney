import 'package:flutter/material.dart';
import 'package:mymoney/core/strings.dart';

class BalanceTextWidget extends StatelessWidget {
  const BalanceTextWidget({super.key, required this.balance, this.fontSize});

  final double balance;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    Color balanceTextColor;
    if (balance < 0) {
      balanceTextColor = Colors.red;
    } else {
      balanceTextColor = Colors.green;
    }
    return Text(
      currentCurrency + balance.toStringAsFixed(2),
      style: TextStyle(
        fontSize: fontSize,
        color: balanceTextColor,
      ),
    );
  }
}
