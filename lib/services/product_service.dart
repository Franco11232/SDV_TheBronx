import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/categoria.dart';
import '../models/salsa.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;

  // ================= PRODUCTOS =================

  Stream<List<Product>> getProducts() {
    return _db.collection('productos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data(); // Datos del documento
        return Product.fromMap(doc.id, data); // ✅ Corrección
      }).toList();
    });
  }

  Future<void> addProduct(Product product) async {
    try {
      await _db.collection('productos').add(product.toMap());
      print("✅ Producto agregado correctamente");
    } catch (e) {
      print("❌ Error al agregar producto: $e");
    }
  }

  Future<void> updateProduct(Product product) async {
    if (product.id.isEmpty) {
      print("⚠️ Error: producto sin ID");
      return;
    }
    try {
      await _db.collection('productos').doc(product.id).update(product.toMap());
      print("✅ Producto actualizado correctamente");
    } catch (e) {
      print("❌ Error al actualizar producto: $e");
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection('productos').doc(id).delete();
      print("🗑️ Producto eliminado correctamente");
    } catch (e) {
      print("❌ Error al eliminar producto: $e");
    }
  }

  // ================= CATEGORÍAS =================

  Stream<List<Categoria>> getCategorias() {
    return _db.collection('categorias').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Categoria.fromMap(doc.id, data); // ✅ Uniforme con Product
      }).toList();
    });
  }

  Future<void> addCategoria(Categoria categoria) async {
    try {
      await _db.collection('categorias').add(categoria.toMap());
      print("✅ Categoría agregada correctamente");
    } catch (e) {
      print("❌ Error al agregar categoría: $e");
    }
  }

  Future<void> updateCategoria(Categoria categoria) async {
    if (categoria.id.isEmpty) {
      print("⚠️ Error: categoría sin ID");
      return;
    }
    try {
      await _db.collection('categorias').doc(categoria.id).update(categoria.toMap());
      print("✅ Categoría actualizada correctamente");
    } catch (e) {
      print("❌ Error al actualizar categoría: $e");
    }
  }

  Future<void> deleteCategoria(String id) async {
    try {
      await _db.collection('categorias').doc(id).delete();
      print("🗑️ Categoría eliminada correctamente");
    } catch (e) {
      print("❌ Error al eliminar categoría: $e");
    }
  }

  // ================= SALSAS =================

  Stream<List<Salsa>> getSalsas() {
    return _db.collection('salsas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Salsa.fromMap(doc.id, data); // ✅ Corrección igual que arriba
      }).toList();
    });
  }

  Future<void> addSalsa(Salsa salsa) async {
    try {
      await _db.collection('salsas').add(salsa.toMap());
      print("✅ Salsa agregada correctamente");
    } catch (e) {
      print("❌ Error al agregar salsa: $e");
    }
  }

  Future<void> updateSalsa(Salsa salsa) async {
    if (salsa.id.isEmpty) {
      print("⚠️ Error: salsa sin ID");
      return;
    }
    try {
      await _db.collection('salsas').doc(salsa.id).update(salsa.toMap());
      print("✅ Salsa actualizada correctamente");
    } catch (e) {
      print("❌ Error al actualizar salsa: $e");
    }
  }

  Future<void> deleteSalsa(String id) async {
    try {
      await _db.collection('salsas').doc(id).delete();
      print("🗑️ Salsa eliminada correctamente");
    } catch (e) {
      print("❌ Error al eliminar salsa: $e");
    }
  }
}
