import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'nombre': name,
      'precio': price,
      'categoria': category,
      'disponible': disponible,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> m){
    return Product(
      id: id,
      name: m['nombre'] ?? '',
      price: (m['precio'] ?? 0).toDouble(),
      category: m['categoria'] ?? '',
      disponible: m['disponible'] ?? true,
    );
  }
  factory Product.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product (
      id: doc.id,
      name: doc['nombre'] ?? '',
      price: (doc['precio'] ?? 0).toDouble(),
      category: doc['categoria'] ?? '',
      disponible: doc['disponible'] ?? true,
    );
  }   
}




