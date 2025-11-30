// lib/providers/almacen_provider.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/categoria.dart';
import '../models/salsa.dart';
import '../services/product_service.dart';

class AlmacenProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  Stream<List<Product>> get productosStream => _service.getProducts();
  Stream<List<Categoria>> get categoriasStream => _service.getCategorias();
  Stream<List<Salsa>> get salsasStream => _service.getSalsas();

  Future<void> agregarProducto(Product p) async {
    await _service.addProduct(p);
    notifyListeners();
  }

  Future<void> actualizarProducto(Product p) async {
    await _service.updateProduct(p);
    notifyListeners();
  }

  Future<void> eliminarProducto(String id) async {
    await _service.deleteProduct(id);
    notifyListeners();
  }

  // categorías
  Future<void> agregarCategoria(Categoria c) async {
    await _service.addCategoria(c);
    notifyListeners();
  }

  Future<void> actualizarCategoria(Categoria c) async {
    await _service.updateCategoria(c);
    notifyListeners();
  }

  Future<void> eliminarCategoria(String id) async {
    await _service.deleteCategoria(id);
    notifyListeners();
  }

  // salsas
  Future<void> agregarSalsa(Salsa s) async {
    await _service.addSalsa(s);
    notifyListeners();
  }

  Future<void> actualizarSalsa(Salsa s) async {
    await _service.updateSalsa(s);
    notifyListeners();
  }

  Future<void> eliminarSalsa(String id) async {
    await _service.deleteSalsa(id);
    notifyListeners();
  }
}
