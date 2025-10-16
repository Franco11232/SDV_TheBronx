import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:svd_thebronx/models/product.dart';

class AlmacenProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream de productos agrupados por categoría
  Stream<Map<String, List<Product>>> streamProductosPorCategoria() {
    return _db.collection('almacen').snapshots().map((snapshot) {
      final productos = snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();

      final Map<String, List<Product>> agrupados = {};
      for (var p in productos) {
        agrupados.putIfAbsent(p.category, () => []).add(p);
      }
      return agrupados;
    });
  }

  /// Crear producto
  Future<void> agregarProducto(Product product) async {
    await _db.collection('almacen').add(product.toMap());
  }

  /// Actualizar producto
  Future<void> actualizarProducto(String id, Product product) async {
    await _db.collection('almacen').doc(id).update(product.toMap());
  }

  /// Eliminar producto
  Future<void> eliminarProducto(String id) async {
    await _db.collection('almacen').doc(id).delete();
  }
}
