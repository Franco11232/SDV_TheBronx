class Product {
  final String id; 
  final String name;
  final double price;
  final String category;
  final bool disponible;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.disponible,
  });

  factory Product.fromMap(String id, Map<String, dynamic> m) => Product(
    id: id,
    name: m['name'] ?? '',
    price: (m['price'] ?? 0).toDouble(),
    category: m['category'] ?? '',
    disponible: m['disponible'] ?? true,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'category': category,
    'disponible': disponible,
  };
}
