import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/transaction_model.dart';

part 'records_state.dart';

enum DateRangeType { daily, weekly, monthly, quarterly, halfYearly, yearly }

class RecordsCubit extends Cubit<RecordsState> {
  final DatabaseHelper _databaseHelper;
  DateRangeType _currentRangeType = DateRangeType.daily;
  DateTime _startDate = DateTime.now();

  RecordsCubit(this._databaseHelper) : super(RecordsLoading());

  DateRangeType get currentRangeType => _currentRangeType;
  DateTime get startDate => _startDate;

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

      List<Transaction> transactions =
          await _databaseHelper.getAllTransactions();

      final filteredTransactions = _filterTransactionsByDateRange(transactions);

      final Map<String, List<Transaction>> groupedTransactions = {};
      final Map<int, double> categoryTotals = {};

      double totalAmountSpent = 0;

      for (Transaction transaction in filteredTransactions) {
        String transactionDay =
            DateFormat('dd MMM yyyy').format(DateTime.parse(transaction.date));

        if (groupedTransactions.containsKey(transactionDay)) {
          groupedTransactions[transactionDay]!.insert(0, transaction);
        } else {
          groupedTransactions[transactionDay] = [transaction];
        }

        final categoryId = transaction.categoryId;
        final amount = transaction.amount;

        if (amount < 0) {
          totalAmountSpent += amount.abs();
          categoryTotals[categoryId] =
              (categoryTotals[categoryId] ?? 0) + amount.abs();
        }
      }

      final sortedGroupedTransactions =
          Map<String, List<Transaction>>.fromEntries(
        groupedTransactions.entries.toList()
          ..sort((a, b) => DateFormat('dd MMM yyyy')
              .parse(b.key)
              .compareTo(DateFormat('dd MMM yyyy').parse(a.key))),
      );

      final sortedCategoryTotals = Map<int, double>.fromEntries(
        categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );

      emit(RecordsAnalyticsLoaded(
          sortedGroupedTransactions, sortedCategoryTotals, totalAmountSpent));
    } catch (e) {
      emit(RecordsError("Failed to load records: $e"));
    }
  }

  List<Transaction> _filterTransactionsByDateRange(
      List<Transaction> transactions) {
    final DateTime endDate = _getEndDateForRange(_startDate, _currentRangeType);

    return transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction.date);

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

  DateTime _getEndDateForRange(DateTime startDate, DateRangeType rangeType) {
    switch (rangeType) {
      case DateRangeType.daily:
        return startDate;
      case DateRangeType.weekly:
        return startDate.add(const Duration(days: 6));
      case DateRangeType.monthly:
        return DateTime(startDate.year, startDate.month + 1, 0);
      case DateRangeType.quarterly:
        return DateTime(startDate.year, startDate.month + 3, 0);
      case DateRangeType.halfYearly:
        return DateTime(startDate.year, startDate.month + 6, 0);
      case DateRangeType.yearly:
        return DateTime(startDate.year, 12, 31);
      default:
        return startDate;
    }
  }

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

  static DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday));
  }
}
