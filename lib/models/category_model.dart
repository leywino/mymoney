class Category {
  final int? id;
  final String name;
  final int iconNumber;
  final String type;

  Category({this.id, required this.name, required this.iconNumber, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconNumber': iconNumber,
      'type': type,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      iconNumber: map['iconNumber'],
      type: map['type'],
    );
  }
}
