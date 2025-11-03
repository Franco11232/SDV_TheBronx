import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comanda.dart';
import '../models/item_comanda.dart';
import '../models/product.dart';

class ComandaProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<ItemComanda> _productos = [];
  List<ItemComanda> get productos => _productos;

  /// 🔹 Total calculado automáticamente
  double get total => _productos.fold(0, (sum, item) => sum + item.subTotal);

  /// ============================================================
  /// 🛒 GESTIÓN LOCAL
  /// ============================================================

  void agregarProducto(Product producto,
      {bool esMediaOrden = false, String? salsa}) {
    final index = _productos.indexWhere((p) =>
    p.idProducto == producto.id &&
        p.llevaMediaOrdenBones == esMediaOrden &&
        p.salsaSeleccionada == salsa);

    if (index >= 0) {
      final item = _productos[index];
      _productos[index] = item.copyWith(
        cantidad: item.cantidad + 1,
        subTotal: (item.cantidad + 1) * item.priceUnit +
            (item.llevaMediaOrdenBones ? (item.precioMediaOrden ?? 0) : 0),
      );
    } else {
      _productos.add(ItemComanda(
        idProducto: producto.id,
        nombre: producto.nombre,
        cantidad: 1,
        priceUnit: producto.precio,
        subTotal: producto.precio + (esMediaOrden ? 75.0 : 0),
        llevaMediaOrdenBones: esMediaOrden,
        precioMediaOrden: esMediaOrden ? 75.0 : null,
        salsaSeleccionada: salsa,
      ));
    }

    notifyListeners();
  }

  void disminuirCantidad(ItemComanda item) {
    final index = _productos.indexOf(item);
    if (index < 0) return;

    final actual = _productos[index];
    if (actual.cantidad > 1) {
      final nuevaCantidad = actual.cantidad - 1;
      _productos[index] = actual.copyWith(
        cantidad: nuevaCantidad,
        subTotal: nuevaCantidad * actual.priceUnit +
            (actual.llevaMediaOrdenBones ? (actual.precioMediaOrden ?? 0) : 0),
      );
    } else {
      _productos.removeAt(index);
    }

    notifyListeners();
  }

  void eliminarProducto(ItemComanda item) {
    _productos.remove(item);
    notifyListeners();
  }

  void limpiarComanda() {
    _productos.clear();
    notifyListeners();
  }

  /// ============================================================
  /// 🔥 FIRESTORE
  /// ============================================================

  Future<void> crearComanda({
    required String clientName,
    required String clientPhone,
    required String type,
    String? address,
    String? addressCol,
  }) async {
    if (_productos.isEmpty) {
      debugPrint('⚠️ No hay productos en la comanda');
      return;
    }

    final comanda = Comanda(
      clientName: clientName,
      clientPhone: clientPhone,
      type: type,
      address: address ?? '',
      addressCol: addressCol ?? '',
      estado: 'pendiente',
      payment: {'estado': 'pendiente', 'metodo': 'efectivo'},
      date: DateTime.now(),
      total: total,
      details: _productos,
    );

    try {
      await _db.collection('comandas').add(comanda.toMap());
      limpiarComanda();
      debugPrint("✅ Comanda creada correctamente en Firestore.");
    } catch (e) {
      debugPrint("❌ Error al crear comanda: $e");
    }
  }

  Stream<List<Comanda>> streamComandasActivas() {
    try {
      return _db
          .collection('comandas')
          .where('estado', isEqualTo: 'pendiente')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => Comanda.fromMap(doc.id, doc.data()))
          .toList());
    } catch (e) {
      debugPrint('❌ Error al escuchar comandas: $e');
      return const Stream.empty();
    }
  }

  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    try {
      await _db.collection('comandas').doc(id).update({
        'estado': nuevoEstado,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });
      debugPrint("🟢 Estado actualizado para comanda $id");
    } catch (e) {
      debugPrint('❌ Error al actualizar estado: $e');
    }
  }

  Future<void> eliminarComanda(String id) async {
    try {
      await _db.collection('comandas').doc(id).delete();
      debugPrint("🗑️ Comanda eliminada correctamente.");
    } catch (e) {
      debugPrint("❌ Error al eliminar comanda: $e");
    }
  }
}
