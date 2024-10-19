class Budgeting {
  final int? id;
  final String category;
  final double budgetAmount;
  final double spentAmount;

  Budgeting(
      {this.id,
      required this.category,
      required this.budgetAmount,
      this.spentAmount = 0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'budgetAmount': budgetAmount,
      'spentAmount': spentAmount,
    };
  }

  factory Budgeting.fromMap(Map<String, dynamic> map) {
    return Budgeting(
      id: map['id'],
      category: map['category'],
      budgetAmount: map['budgetAmount'],
      spentAmount: map['spentAmount'],
    );
  }
}
