import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class AlmacenProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  /// 🔹 Stream de productos en tiempo real
  Stream<List<Product>> get productosStream => _service.getProducts();

  Future<void> agregarProducto(Product product) async {
    await _service.addProduct(product);
    notifyListeners();
  }

  Future<void> actualizarProducto(Product product) async {
    await _service.updateProduct(product);
    notifyListeners();
  }

  Future<void> eliminarProducto(String id) async {
    await _service.deleteProduct(id);
    notifyListeners();
  }
}
