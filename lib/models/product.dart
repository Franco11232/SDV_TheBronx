// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final double stock;
  final String category;
  final bool disponible;

  final bool tieneMediaBoneless;
  final String? salsaMediaBoneless;
  final List<String> salsasDisponibles;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.disponible,
    this.tieneMediaBoneless = false,
    this.salsaMediaBoneless,
    this.salsasDisponibles = const [],
  });

  // Corregido: Se eliminan las claves en español (nombre, precio, categoria)
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: (data['stock'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      disponible: data['disponible'] ?? true,
      tieneMediaBoneless: data['tieneMediaBoneless'] ?? false,
      salsaMediaBoneless: data['salsaMediaBoneless'],
      salsasDisponibles: List<String>.from(data['salsasDisponibles'] ?? []),
    );
  }

  // ✅ toMap ya usa los nombres en inglés, no necesita cambios.
  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'stock': stock,
    'category': category,
    'disponible': disponible,
    'tieneMediaBoneless': tieneMediaBoneless,
    'salsaMediaBoneless': salsaMediaBoneless,
    'salsasDisponibles': salsasDisponibles,
  };

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? stock,
    String? category,
    bool? disponible,
    bool? tieneMediaBoneless,
    String? salsaMediaBoneless,
    List<String>? salsasDisponibles,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      disponible: disponible ?? this.disponible,
      tieneMediaBoneless: tieneMediaBoneless ?? this.tieneMediaBoneless,
      salsaMediaBoneless: salsaMediaBoneless ?? this.salsaMediaBoneless,
      salsasDisponibles: salsasDisponibles ?? this.salsasDisponibles,
    );
  }
}
