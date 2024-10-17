import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymoney/core/color.dart';

class DateTimePickerWidget extends StatefulWidget {
  const DateTimePickerWidget({super.key});

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lightYellow,
              onPrimary: Color(0xFF262626),
              surface: Color(0xFF333333),
              onSurface: AppColors.lightYellow,
              secondary: AppColors.lightYellow,
            ),
            dialogBackgroundColor: const Color(0xFF444444),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFD600),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lightYellow,
              onPrimary: Color(0xFF262626),
              surface: Color(0xFF333333),
              onSurface: AppColors.lightYellow,
              secondary: AppColors.lightYellow,
            ),
            dialogBackgroundColor: const Color(0xFF444444),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFD600),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String getFormattedDate() {
    return DateFormat('EEE, MMM d').format(selectedDate);
  }

  String getFormattedTime() {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Date Picker
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(width: 1, color: AppColors.beige))),
                child: Center(
                  child: Text(
                    getFormattedDate(),
                    style: const TextStyle(
                      color: AppColors.lightYellow,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Box.w10,
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        left: BorderSide(width: 1, color: AppColors.beige))),
                child: Center(
                  child: Text(
                    getFormattedTime(),
                    style: const TextStyle(
                      color: AppColors.lightYellow,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
