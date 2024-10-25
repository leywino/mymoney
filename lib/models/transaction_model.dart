class Transaction {
  final int? id;
  final int accountId;
  final int? toAccountId;
  final int categoryId;
  final double amount;
  final String date;
  final String? notes;
  final String type;

  Transaction({
    this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.type,
    this.notes,
    this.toAccountId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'categoryId': categoryId,
      'amount': amount,
      'date': date,
      'notes': notes,
      'type': type,
      'toAccountId': toAccountId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      accountId: map['accountId'],
      categoryId: map['categoryId'],
      amount: map['amount'],
      date: map['date'],
      notes: map['notes'],
      type: map['type'],
      toAccountId: map['toAccountId'],
    );
  }

  Transaction copyWith({
    int? id,
    int? accountId,
    int? toAccountId,
    int? categoryId,
    double? amount,
    String? date,
    String? notes,
    String? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      toAccountId: toAccountId ?? this.toAccountId,
    );
  }
}
