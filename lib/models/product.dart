// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final bool disponible;

  /// Si el producto (Burger/Sandwich) puede tener media orden de boneless
  final bool tieneMediaBoneless;

  /// Salsa específica para media boneless (solo aplica si tieneMediaBoneless = true)
  final String? salsaMediaBoneless;

  /// Lista de salsas disponibles (solo aplica si es producto tipo Boneless)
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

  /// ✅ Convertir Product → Map para subir a Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'disponible': disponible,
      'tieneMediaBoneless': tieneMediaBoneless,
      'salsaMediaBoneless': salsaMediaBoneless,
      'salsasDisponibles': salsasDisponibles,
    };
  }

  /// ✅ Convertir Map (de Firebase) → Product
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? data['nombre'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] ?? 0.0).toDouble(),
      stock: (data['stock'] is int)
          ? data['stock']
          : int.tryParse('${data['stock'] ?? 0}') ?? 0,
      category: data['category'] ?? data['categoria'] ?? 'Otro',
      disponible: data['disponible'] ?? true,
      tieneMediaBoneless: data['tieneMediaBoneless'] ?? false,
      salsaMediaBoneless: data['salsaMediaBoneless'],
      salsasDisponibles: List<String>.from(data['salsasDisponibles'] ?? []),
    );
  }

  /// ✅ Crear una copia modificada del producto
  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
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
