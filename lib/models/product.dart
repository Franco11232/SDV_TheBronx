class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool disponible;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.disponible,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': name,
      'precio': price,
      'categoria': category,
      'disponible': disponible,
      'stock': stock,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['nombre'] ?? '', // evita null
      price: (data['precio'] as num?)?.toDouble() ?? 0.0,
      category: data['categoria'] ?? 'Sin categoría',
      disponible: data['disponible'] is bool ? data['disponible'] : true,
      stock: (data['stock'] is int)
          ? data['stock']
          : (data['stock'] is num ? (data['stock'] as num).toInt() : 0),
    );
  }
}
