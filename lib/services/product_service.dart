import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svd_thebronx/models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Escucha en tiempo real todos los productos
  Stream<List<Product>> streamProduct() {
    return _db.collection("productos").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// 🔹 Agregar nuevo producto
  Future<void> addProduct(Product product) async {
    try {
      await _db.collection("productos").add(product.toMap());
      print("✅ Producto añadido correctamente");
    } catch (e) {
      print("❌ Error: no se pudo añadir el producto: $e");
    }
  }

  /// 🔹 Actualizar producto existente
  Future<void> updateProduct(Product product) async {
    if (product.id.isEmpty) {
      print("⚠️ Error: el producto no tiene ID");
      return;
    }
    try {
      await _db
          .collection("productos")
          .doc(product.id)
          .update(product.toMap());
      print("✅ Producto actualizado correctamente");
    } catch (e) {
      print("❌ Error al actualizar producto: $e");
    }
  }

  /// 🔹 Eliminar producto por ID
  Future<void> deleteProduct(String id) async {
    if (id.isEmpty) {
      print("⚠️ Error: el producto no tiene ID");
      return;
    }
    try {
      await _db.collection("productos").doc(id).delete();
      print("🗑️ Producto eliminado correctamente");
    } catch (e) {
      print("❌ Error al eliminar el producto: $e");
    }
  }
}
