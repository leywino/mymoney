import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting
import 'package:mymoney/core/strings.dart';

class BalanceTextWidget extends StatelessWidget {
  const BalanceTextWidget({
    super.key,
    required this.balance,
    this.fontSize,
    this.isSymbol = false,
    this.isMinusOnly = false,
    this.style,
  });

  final double balance;
  final double? fontSize;
  final bool isSymbol;
  final bool isMinusOnly;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final String formattedBalance = _formatBalance(balance);
    final Color balanceTextColor = _getBalanceColor(balance);

    return Text(
      formattedBalance,
      style: style ??
          TextStyle(
            fontSize: fontSize ?? 16,
            color: balanceTextColor,
          ),
    );
  }

  String _formatBalance(double balance) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: currentCurrency,
    );

    String formatted = formatter.format(balance.abs());
    if (isSymbol) {
      final String sign = balance < 0 ? "-" : "+";
      formatted = "$sign$formatted";
    }
    if (isMinusOnly) {
      final String sign = balance < 0 ? "-" : "";
      formatted = "$sign$formatted";
    }

    return formatted;
  }

  Color _getBalanceColor(double balance) {
    return balance < 0 ? const Color.fromARGB(255, 255, 89, 0) : Colors.green;
  }
}
