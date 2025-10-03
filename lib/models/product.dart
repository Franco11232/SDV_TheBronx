
class Product {
  String id; 
  String name;
  double price;
  String category;
  bool disponible;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.disponible,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': name,
      'precio': price,
      'categoria': category,
      'disponible': disponible,
    };
  }

  factory Product.fromMap(Map<String, dynamic>data, String id){
    return Product(
      id: id,
      name: data['nombre'],
      price: (data['precio'] as num).toDouble(),
      category: data['categoria'],
      disponible: data['disponible'] ?? '',
    );
  }   
}




