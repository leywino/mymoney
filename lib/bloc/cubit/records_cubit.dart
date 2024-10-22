import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/transaction_model.dart';

part 'records_state.dart';

enum DateRangeType { daily, weekly, monthly, quarterly, halfYearly, yearly }

class RecordsCubit extends Cubit<RecordsState> {
  final DatabaseHelper _databaseHelper;
  DateRangeType _currentRangeType = DateRangeType.daily; // Default to daily
  DateTime _startDate = DateTime.now(); // Default to today

  RecordsCubit(this._databaseHelper) : super(RecordsLoading());

  DateRangeType get currentRangeType => _currentRangeType;
  DateTime get startDate => _startDate;

  // Helper function to get the formatted date range label
  String getCurrentDateRangeLabel() {
    final DateTime endDate = _getEndDateForRange(_startDate, _currentRangeType);
    switch (_currentRangeType) {
      case DateRangeType.daily:
        return DateFormat('MMM dd, yyyy').format(_startDate);
      case DateRangeType.weekly:
        return "${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd').format(endDate)}";
      case DateRangeType.monthly:
        return DateFormat('MMMM, yyyy').format(_startDate);
      case DateRangeType.quarterly:
        return "${DateFormat('MMM').format(_startDate)} - ${DateFormat('MMM').format(endDate)} '${DateFormat('yy').format(endDate)}";
      case DateRangeType.halfYearly:
        return "${DateFormat('MMM').format(_startDate)} - ${DateFormat('MMM').format(endDate)} '${DateFormat('yy').format(endDate)}";
      case DateRangeType.yearly:
        return DateFormat('yyyy').format(_startDate);
    }
  }

  // Method to move to the next or previous date range (week, month, etc.)
  void moveDateRange(bool isNext) {
    if (isNext) {
      _startDate = _getStartDateForNextRange(_startDate, _currentRangeType);
    } else {
      _startDate = _getStartDateForPreviousRange(_startDate, _currentRangeType);
    }
    fetchRecords();
  }

  void changeDateRangeType(DateRangeType rangeType) {
    _currentRangeType = rangeType;
    _startDate = _getStartOfRange(DateTime.now(), _currentRangeType);
    fetchRecords();
  }

  DateTime _getStartOfRange(DateTime date, DateRangeType rangeType) {
    switch (rangeType) {
      case DateRangeType.daily:
        return DateTime(date.year, date.month, date.day);
      case DateRangeType.weekly:
        return _getStartOfWeek(date);
      case DateRangeType.monthly:
        return DateTime(date.year, date.month, 1);
      case DateRangeType.quarterly:
        int currentQuarter = ((date.month - 1) ~/ 3) + 1;
        return DateTime(date.year, (currentQuarter - 1) * 3 + 1, 1);
      case DateRangeType.halfYearly:
        return (date.month <= 6)
            ? DateTime(date.year, 1, 1)
            : DateTime(date.year, 7, 1);
      case DateRangeType.yearly:
        return DateTime(date.year, 1, 1);
      default:
        return date;
    }
  }

  Future<void> fetchRecords() async {
    try {
      emit(RecordsLoading());

      // Fetch all transactions from the database
      List<Transaction> transactions =
          await _databaseHelper.getAllTransactions();

      final filteredTransactions = _filterTransactionsByDateRange(transactions);

      final Map<String, List<Transaction>> groupedTransactions = {};

      // Group transactions by date
      for (Transaction transaction in filteredTransactions) {
        log('loading ${transaction.toString()}');
        String transactionDay =
            DateFormat('dd MMM yyyy').format(DateTime.parse(transaction.date));

        if (groupedTransactions.containsKey(transactionDay)) {
          groupedTransactions[transactionDay]!.add(transaction);
        } else {
          groupedTransactions[transactionDay] = [transaction];
        }
      }

      emit(RecordsLoaded(groupedTransactions));
    } catch (e) {
      emit(RecordsError("Failed to load records: $e"));
    }
  }

  // Helper method to filter transactions by the selected date range
  List<Transaction> _filterTransactionsByDateRange(
      List<Transaction> transactions) {
    final DateTime endDate = _getEndDateForRange(_startDate, _currentRangeType);

    return transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction.date);

      // For daily range, only include transactions on the same day
      if (_currentRangeType == DateRangeType.daily) {
        return transactionDate.year == _startDate.year &&
            transactionDate.month == _startDate.month &&
            transactionDate.day == _startDate.day;
      }

      return (transactionDate.isAtSameMomentAs(_startDate) ||
              transactionDate.isAfter(_startDate)) &&
          (transactionDate.isAtSameMomentAs(endDate) ||
              transactionDate.isBefore(endDate));
    }).toList();
  }

  // Helper method to get the end date for a given date range
  DateTime _getEndDateForRange(DateTime startDate, DateRangeType rangeType) {
    switch (rangeType) {
      case DateRangeType.daily:
        return startDate;
      case DateRangeType.weekly:
        return startDate.add(const Duration(days: 6));
      case DateRangeType.monthly:
        return DateTime(
            startDate.year, startDate.month + 1, 0); // Last day of the month
      case DateRangeType.quarterly:
        return DateTime(
            startDate.year, startDate.month + 3, 0); // Last day of the quarter
      case DateRangeType.halfYearly:
        return DateTime(startDate.year, startDate.month + 6,
            0); // Last day of the half-year
      case DateRangeType.yearly:
        return DateTime(startDate.year, 12, 31); // Last day of the year
      default:
        return startDate;
    }
  }

  // Get the start date for the next range
  DateTime _getStartDateForNextRange(
      DateTime startDate, DateRangeType rangeType) {
    switch (rangeType) {
      case DateRangeType.daily:
        return startDate.add(const Duration(days: 1));
      case DateRangeType.weekly:
        return startDate.add(const Duration(days: 7));
      case DateRangeType.monthly:
        return DateTime(startDate.year, startDate.month + 1, 1);
      case DateRangeType.quarterly:
        return DateTime(startDate.year, startDate.month + 3, 1);
      case DateRangeType.halfYearly:
        return DateTime(startDate.year, startDate.month + 6, 1);
      case DateRangeType.yearly:
        return DateTime(startDate.year + 1, 1, 1);
      default:
        return startDate;
    }
  }

  // Get the start date for the previous range
  DateTime _getStartDateForPreviousRange(
      DateTime startDate, DateRangeType rangeType) {
    switch (rangeType) {
      case DateRangeType.daily:
        return startDate.subtract(const Duration(days: 1));
      case DateRangeType.weekly:
        return startDate.subtract(const Duration(days: 7));
      case DateRangeType.monthly:
        return DateTime(startDate.year, startDate.month - 1, 1);
      case DateRangeType.quarterly:
        return DateTime(startDate.year, startDate.month - 3, 1);
      case DateRangeType.halfYearly:
        return DateTime(startDate.year, startDate.month - 6, 1);
      case DateRangeType.yearly:
        return DateTime(startDate.year - 1, 1, 1);
      default:
        return startDate;
    }
  }

  // Helper to get the start of the current week (Sunday)
  static DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday));
  }
}
