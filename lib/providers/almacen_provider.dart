import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/categoria.dart';
import '../models/salsa.dart';
import '../services/product_service.dart';

/// ✅ Provider principal de almacén.
/// Escucha cambios en Firestore en tiempo real para productos, categorías y salsas.
class AlmacenProvider with ChangeNotifier {
  final ProductService _service = ProductService();

  // ================= STREAMS =================

  /// Productos en tiempo real
  Stream<List<Product>> get productosStream => _service.getProducts();

  /// Categorías en tiempo real
  Stream<List<Categoria>> get categoriasStream => _service.getCategorias();

  /// Salsas en tiempo real
  Stream<List<Salsa>> get salsasStream => _service.getSalsas();

  // ================= PRODUCTOS =================

  Future<void> agregarProducto(Product product) async {
    try {
      await _service.addProduct(product);
      print('✅ Producto agregado correctamente');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al agregar producto: $e');
    }
  }

  Future<void> actualizarProducto(Product product) async {
    try {
      await _service.updateProduct(product);
      print('🔄 Producto actualizado correctamente');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al actualizar producto: $e');
    }
  }

  Future<void> eliminarProducto(String id) async {
    try {
      await _service.deleteProduct(id);
      print('🗑️ Producto eliminado correctamente');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al eliminar producto: $e');
    }
  }

  // ================= CATEGORÍAS =================

  Future<void> agregarCategoria(Categoria categoria) async {
    try {
      await _service.addCategoria(categoria);
      print('✅ Categoría agregada correctamente');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al agregar categoría: $e');
    }
  }

  Future<void> actualizarCategoria(Categoria categoria) async {
    try {
      await _service.updateCategoria(categoria);
      print('🔄 Categoría actualizada');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al actualizar categoría: $e');
    }
  }

  Future<void> eliminarCategoria(String id) async {
    try {
      await _service.deleteCategoria(id);
      print('🗑️ Categoría eliminada');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al eliminar categoría: $e');
    }
  }

  // ================= SALSAS =================

  Future<void> agregarSalsa(Salsa salsa) async {
    try {
      await _service.addSalsa(salsa);
      print('✅ Salsa agregada correctamente');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al agregar salsa: $e');
    }
  }

  Future<void> actualizarSalsa(Salsa salsa) async {
    try {
      await _service.updateSalsa(salsa);
      print('🔄 Salsa actualizada');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al actualizar salsa: $e');
    }
  }

  Future<void> eliminarSalsa(String id) async {
    try {
      await _service.deleteSalsa(id);
      print('🗑️ Salsa eliminada correctamente');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al eliminar salsa: $e');
    }
  }
}
