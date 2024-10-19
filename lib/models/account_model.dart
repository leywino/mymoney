class Account {
  final int? id;
  final String name;
  final double balance;
  final int? iconNumber;

  Account({this.id, required this.name, required this.balance,  this.iconNumber = 1});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'iconNumber': iconNumber,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      iconNumber: map['iconNumber'],
    );
  }
}
