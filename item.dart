class Item {
  final int id;
  final String name;

  Item({
    required this.id,
    required this.name,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
