// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final double stock;
  final String category;
  final bool disponible;

  // ✅ Corregido: Lógica de salsas mejorada
  final bool acceptsSauce; // Indica si el producto puede llevar salsa
  final List<String> salsasDisponibles; // Nombres de las salsas que aplican a este producto
  
  final bool tieneMediaBoneless; // Se mantiene para el costo extra

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.disponible,
    this.acceptsSauce = false, // ✅
    this.salsasDisponibles = const [],
    this.tieneMediaBoneless = false,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: (data['stock'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      disponible: data['disponible'] ?? true,
      // ✅
      acceptsSauce: data['acceptsSauce'] ?? false,
      salsasDisponibles: List<String>.from(data['salsasDisponibles'] ?? []),
      tieneMediaBoneless: data['tieneMediaBoneless'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'stock': stock,
    'category': category,
    'disponible': disponible,
    // ✅
    'acceptsSauce': acceptsSauce,
    'salsasDisponibles': salsasDisponibles,
    'tieneMediaBoneless': tieneMediaBoneless,
  };

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? stock,
    String? category,
    bool? disponible,
    // ✅
    bool? acceptsSauce,
    List<String>? salsasDisponibles,
    bool? tieneMediaBoneless,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      disponible: disponible ?? this.disponible,
      // ✅
      acceptsSauce: acceptsSauce ?? this.acceptsSauce,
      salsasDisponibles: salsasDisponibles ?? this.salsasDisponibles,
      tieneMediaBoneless: tieneMediaBoneless ?? this.tieneMediaBoneless,
    );
  }
}
