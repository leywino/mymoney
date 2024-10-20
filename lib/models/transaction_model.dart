class Transaction {
  final int? id;
  final int accountId;
  final int categoryId;
  final double amount;
  final String date;
  final String? notes;

  Transaction({
    this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'categoryId': categoryId,
      'amount': amount,
      'date': date,
      'notes': notes,
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
    );
  }
}
