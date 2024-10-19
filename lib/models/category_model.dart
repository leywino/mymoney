class Category {
  final int? id;
  final String name;
  final String assetPath;
  final String type;

  Category({this.id, required this.name, required this.assetPath, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'assetPath': assetPath,
      'type': type,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      assetPath: map['assetPath'],
      type: map['type'],
    );
  }
}
