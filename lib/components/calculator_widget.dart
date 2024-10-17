import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  String? currentOperation;
  double? previousValue;
  bool isNewValue = false;
  Color displayColor = AppColors.lightYellow;

  void onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        display = '0';
        currentOperation = null;
        previousValue = null;
        isNewValue = false;
        displayColor = AppColors.lightYellow; // Reset color
        HapticFeedback.heavyImpact();
      } else if (value == '⌫') {
        display =
            display.length > 1 ? display.substring(0, display.length - 1) : '0';
        HapticFeedback.lightImpact();
      } else if ('+-×÷'.contains(value)) {
        previousValue = double.tryParse(display);
        currentOperation = value;
        isNewValue = true;
        displayColor = AppColors.beige; // Change color for operations
        HapticFeedback.mediumImpact();
      } else if (value == '=') {
        _calculateResult();
        displayColor = AppColors.lightYellow; // Reset color after calculation
        HapticFeedback.heavyImpact();
      } else {
        if (isNewValue) {
          display = value;
          isNewValue = false;
        } else {
          if (display.length < 10) {
            display = display == '0' ? value : display + value;
          }
        }
        displayColor = AppColors.lightYellow; // Reset color for digits
        HapticFeedback.lightImpact();
      }
    });
  }

  void _calculateResult() {
    if (previousValue != null && currentOperation != null) {
      double currentValue = double.tryParse(display) ?? 0;
      double result;

      switch (currentOperation) {
        case '+':
          result = previousValue! + currentValue;
          break;
        case '-':
          result = previousValue! - currentValue;
          break;
        case '×':
          result = previousValue! * currentValue;
          break;
        case '÷':
          result = previousValue! / currentValue;
          break;
        default:
          return;
      }

      if (result == result.toInt()) {
        display = result.toInt().toString();
      } else {
        display = result.toStringAsFixed(2);
      }

      currentOperation = null;
      previousValue = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Box.hBox4,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.beige, width: 2),
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (currentOperation != null)
                Row(
                  children: [
                    Text(
                      currentOperation!,
                      style: const TextStyle(
                        color: AppColors.lightYellow,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              Expanded(
                child: Text(
                  display,
                  maxLines: 1,
                  style: TextStyle(
                    color: displayColor, // Dynamic color
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Box.wBox8,
              InkWell(
                splashColor: AppColors.customGray,
                onTap: () {
                  onButtonPressed('⌫');
                },
                onLongPress: () {
                  onButtonPressed('C');
                },
                child: SizedBox(
                  height: size.height * 0.05,
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.lightYellow,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
        Box.hBox4,
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 5 / 4,
          children: [
            buildButton('+'),
            buildButton('7'),
            buildButton('8'),
            buildButton('9'),
            buildButton('-'),
            buildButton('4'),
            buildButton('5'),
            buildButton('6'),
            buildButton('×'),
            buildButton('1'),
            buildButton('2'),
            buildButton('3'),
            buildButton('÷'),
            buildButton('0'),
            buildButton('.'),
            buildButton('='),
          ],
        ),
      ],
    );
  }

  Widget buildButton(String label) {
    bool isOperator = '+-×÷='.contains(label);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOperator ? AppColors.beige : AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: !isOperator ? AppColors.beige : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      onPressed: () => onButtonPressed(label),
      child: Text(
        label,
        style: TextStyle(
          color: !isOperator ? AppColors.lightYellow : AppColors.darkGray,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}