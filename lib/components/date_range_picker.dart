import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mymoney/bloc/records_cubit/records_cubit.dart';
import 'package:mymoney/core/color.dart';

class DateRangePicker extends StatelessWidget {
  const DateRangePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordsCubit, RecordsState>(
      builder: (context, state) {
        final cubit = context.read<RecordsCubit>();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: AppColors.lightYellow),
                onPressed: () {
                  cubit.moveDateRange(false); // Move to the previous date range
                },
              ),
              // Display the current date range
              Text(
                cubit.getCurrentDateRangeLabel(),
                style: const TextStyle(
                  color: AppColors.lightYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // Next button
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: AppColors.lightYellow),
                onPressed: () {
                  cubit.moveDateRange(true);
                },
              ),
              PopupMenuButton<DateRangeType>(
                icon:
                    const Icon(Icons.filter_list, color: AppColors.lightYellow),
                onSelected: (DateRangeType selectedRange) {
                  cubit.changeDateRangeType(selectedRange);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: DateRangeType.daily,
                    child: Text("Daily"),
                  ),
                  const PopupMenuItem(
                    value: DateRangeType.weekly,
                    child: Text("Weekly"),
                  ),
                  const PopupMenuItem(
                    value: DateRangeType.monthly,
                    child: Text("Monthly"),
                  ),
                  const PopupMenuItem(
                    value: DateRangeType.quarterly,
                    child: Text("Quarterly"),
                  ),
                  const PopupMenuItem(
                    value: DateRangeType.halfYearly,
                    child: Text("Half-Yearly"),
                  ),
                  const PopupMenuItem(
                    value: DateRangeType.yearly,
                    child: Text("Yearly"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
