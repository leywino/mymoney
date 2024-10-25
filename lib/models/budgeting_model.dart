class Budgeting {
  final int? id;
  final int categoryId;
  final double budgetAmount;

  Budgeting({
    this.id,
    required this.categoryId,
    required this.budgetAmount,
  });

  // Factory constructor to create a Budgeting object from a map
  factory Budgeting.fromMap(Map<String, dynamic> map) {
    return Budgeting(
      id: map['id'],
      categoryId: map['categoryId'],
      budgetAmount: map['budgetAmount'],
    );
  }

  // Method to convert a Budgeting object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'budgetAmount': budgetAmount,
    };
  }
}
