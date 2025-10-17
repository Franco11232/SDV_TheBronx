// lib/providers/comanda_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/comanda.dart';
import '../models/item_comanda.dart';

class ComandaProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 --- Carrito local ---
  final List<ItemComanda> _productos = [];

  List<ItemComanda> get productos => _productos;

  double get total =>
      _productos.fold(0, (sum, item) => sum + item.subTotal);

  void agregarProducto(ItemComanda item) {
    final index = _productos.indexWhere((p) => p.productId == item.productId);
    if (index >= 0) {
      final existente = _productos[index];
      _productos[index] = ItemComanda(
        productId: existente.productId,
        nombre: existente.nombre,
        cantidad: existente.cantidad + 1,
        priceUnit: existente.priceUnit,
      );
    } else {
      _productos.add(item);
    }
    notifyListeners();
  }

  void eliminarProducto(String productId) {
    _productos.removeWhere((p) => p.productId == productId);
    notifyListeners();
  }

  void clearComanda() {
    _productos.clear();
    notifyListeners();
  }

  // 🔹 --- Firestore: comandas existentes ---
  Stream<List<Comanda>> streamComandas() {
    return _db
        .collection('comandas')
        .where('estado', whereIn: ['pendiente', 'en_preparacion'])
        .orderBy('fecha', descending: false)
        .snapshots()
        .handleError((e) {
      debugPrint('Error en streamComandas: $e');
    }).map((snapshot) {
      try {
        return snapshot.docs
            .map((d) => Comanda.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error parseando comandas: $e');
        return <Comanda>[];
      }
    });
  }

  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    await _db.collection('comandas').doc(id).update({'estado': nuevoEstado});
  }

  Future<void> loadPendientes() async {
    final snapshot = await _db
        .collection('comandas')
        .where('estado', isEqualTo: 'pendiente')
        .get();
    // podrías mapear aquí si lo necesitas
    notifyListeners();
  }
}
