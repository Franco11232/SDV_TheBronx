import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Escucha todos los productos en tiempo real
  Stream<List<Product>> getProducts() {
    return _db.collection("productos").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
          return Product.fromMap(doc.id,doc.data()??{});
      }).toList();
    });
  }

  /// 🔹 Agregar producto con ID generado automáticamente
  Future<void> addProduct(Product product) async {
    final docRef = _db.collection("productos").doc();
    final nuevo = product.copyWith(id: docRef.id);
    await docRef.set(nuevo.toMap());
  }

  /// 🔹 Actualizar producto existente
  Future<void> updateProduct(Product product) async {
    if (product.id.isEmpty) return;
    await _db.collection("productos").doc(product.id).update(product.toMap());
  }

  /// 🔹 Eliminar producto por ID
  Future<void> deleteProduct(String id) async {
    if (id.isEmpty) return;
    await _db.collection("productos").doc(id).delete();
  }

  /// 🔹 Obtener producto por ID
  Future<Product?> getProductById(String id) async {
    final doc = await _db.collection("productos").doc(id).get();
    if (!doc.exists) return null;
    return Product.fromMap(doc.id, doc.data() ?? {});
  }
}
