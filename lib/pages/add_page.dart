import 'package:flutter/material.dart';
import 'package:mymoney/components/calculator_widget.dart';
import 'package:mymoney/components/date_time_picker.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<bool> isSelected = [false, true, false];

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
            onPressed: () {},
          ),
          TextButton.icon(
            style: const ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(AppColors.gold)),
            label: const Text(
              'SAVE',
            ),
            onPressed: () {},
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ToggleButtons(
              borderColor: AppColors.darkGray,
              fillColor: AppColors.lightYellow,
              selectedColor: AppColors.darkGray,
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(5),
              isSelected: isSelected,
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0;
                      buttonIndex < isSelected.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelected[buttonIndex] = true;
                    } else {
                      isSelected[buttonIndex] = false;
                    }
                  }
                });
              },
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      if (isSelected[0]) checkIcon(),
                      const Text('INCOME'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      if (isSelected[1]) checkIcon(),
                      const Text('EXPENSE'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      if (isSelected[2]) checkIcon(),
                      const Text('TRANSFER'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              buildCustomButton(
                context,
                title: _buildTitle(0),
                icon: Icons.credit_card,
                label: 'Account',
              ),
              Box.wBox4,
              buildCustomButton(
                context,
                title: _buildTitle(1),
                icon: Icons.label,
                label: 'Category',
              ),
            ],
          ),
          Box.hBox4,
          Expanded(child: buildNoteContainer()),
          const CalculatorScreen(),
          const DateTimePickerWidget(),
        ],
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
        Icon(Icons.check_circle, color: AppColors.darkGray, size: 16),
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
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: TextField(
          maxLines: null,
          decoration: InputDecoration.collapsed(
              hintText: 'Add notes',
              hintStyle: TextStyle(color: AppColors.beige)),
        ),
      ),
    );
  }

  Widget buildCustomButton(BuildContext context,
      {required String title, required IconData icon, required String label}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.lightYellow,
              fontSize: 16,
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: AppColors.gold,
                  ),
                  Box.wBox3,
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
        ],
      ),
    );
  }
}
