class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
  });

  /// Factory constructor to create a Category from JSON map
  /// Handles both String and int type conversions safely
  /// Throws ArgumentError if required fields (id, name) are missing
  factory Category.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    
    if (id == null) {
      throw ArgumentError('Category id is required but was null');
    }
    if (name == null) {
      throw ArgumentError('Category name is required but was null');
    }
    
    return Category(
      id: id.toString(),
      name: name.toString(),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
    );
  }

  /// Convert Category to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
    };
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description)';
  }
}
