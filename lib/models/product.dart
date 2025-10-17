// lib/models/product.dart
class Product {
  final String id;
  final String name;       // corresponde a 'nombre' en Firestore
  final double price;      // 'precio'
  final String category;   // 'categoria'
  final bool disponible;   // 'disponible'
  final int stock;         // 'stock'
  final String? imageUrl;  // opcional, 'imagenUrl' o 'imageUrl'

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.disponible,
    required this.stock,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': name,
      'precio': price,
      'categoria': category,
      'disponible': disponible,
      'stock': stock,
      if (imageUrl != null) 'imagenUrl': imageUrl,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    // Manejar nombres/formatos varios y evitar errores por nulls/tipos
    final nombre = data['nombre'] ?? data['name'] ?? '';
    final precioRaw = data['precio'] ?? data['price'] ?? 0;
    final categoria = data['categoria'] ?? data['category'] ?? 'Sin categoría';
    final disponibleRaw = data['disponible'] ?? data['available'] ?? true;
    final stockRaw = data['stock'] ?? data['existencias'] ?? 0;
    final imagen = data['imagenUrl'] ?? data['imageUrl'] ?? null;

    double precio = 0.0;
    if (precioRaw is num) precio = precioRaw.toDouble();
    else if (precioRaw is String) precio = double.tryParse(precioRaw) ?? 0.0;

    bool disponible = disponibleRaw is bool ? disponibleRaw : disponibleRaw.toString().toLowerCase() == 'true';

    int stock = 0;
    if (stockRaw is int) stock = stockRaw;
    else if (stockRaw is num) stock = (stockRaw as num).toInt();
    else if (stockRaw is String) stock = int.tryParse(stockRaw) ?? 0;

    return Product(
      id: id,
      name: nombre,
      price: precio,
      category: categoria,
      disponible: disponible,
      stock: stock,
      imageUrl: imagen,
    );
  }
}
