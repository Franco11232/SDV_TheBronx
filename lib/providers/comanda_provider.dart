import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comanda.dart';
import '../models/item_comanda.dart';
import '../models/product.dart';

class ComandaProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<ItemComanda> _productos = [];
  List<ItemComanda> get productos => _productos;

  double get total => _productos.fold(0.0, (sum, item) => sum + item.subTotal);

  // ✅ Corregido para usar la nueva lógica de salsas y precios
  void agregarProducto(Product producto,
      {bool esMediaOrden = false, String? salsa}) {

    // La condición ahora busca por el campo 'salsa'
    final index = _productos.indexWhere((p) =>
        p.idProducto == producto.id &&
        p.llevaMediaOrdenBones == esMediaOrden &&
        p.salsa == salsa);

    if (index >= 0) {
      // Si el producto ya existe, solo se actualiza la cantidad y el subtotal
      final item = _productos[index];
      final nuevaCantidad = item.cantidad + 1;
      _productos[index] = item.copyWith(
        cantidad: nuevaCantidad,
        subTotal: nuevaCantidad * item.priceUnit,
      );
    } else {
      // Si es un producto nuevo, se calcula su precio unitario (con el extra si es media orden)
      final double precioUnitario = producto.price + (esMediaOrden ? 75.0 : 0);
      _productos.add(ItemComanda(
        idProducto: producto.id,
        nombre: producto.name,
        cantidad: 1,
        priceUnit: precioUnitario, // El precio ya incluye el extra
        subTotal: precioUnitario,   // El subtotal para 1 item es su precio unitario
        llevaMediaOrdenBones: esMediaOrden,
        salsa: salsa, // Se usa el nuevo campo 'salsa'
      ));
    }

    notifyListeners();
  }

  // ✅ Corregido para usar la nueva lógica de subtotal
  void disminuirCantidad(ItemComanda item) {
    final index = _productos.indexOf(item);
    if (index < 0) return;

    final actual = _productos[index];
    if (actual.cantidad > 1) {
      final nuevaCantidad = actual.cantidad - 1;
      _productos[index] = actual.copyWith(
        cantidad: nuevaCantidad,
        subTotal: nuevaCantidad * actual.priceUnit, // Cálculo simplificado
      );
    } else {
      // Si la cantidad es 1, se elimina el producto
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
  
  Future<void> actualizarComanda(Comanda comanda) async {
    if (comanda.id == null) {
      debugPrint('❌ No se puede actualizar una comanda sin ID.');
      return;
    }
    try {
      await _db.collection('comandas').doc(comanda.id).update(comanda.toMap());
      debugPrint("✅ Comanda actualizada correctamente.");
    } catch (e) {
      debugPrint("❌ Error al actualizar la comanda: $e");
      rethrow; 
    }
  }

  Stream<List<Comanda>> streamComandasActivas() {
    return _db
        .collection('comandas')
        .where('estado', whereIn: ['pendiente', 'en_preparacion'])
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((d) => Comanda.fromMap(d.id, d.data()))
          .toList();
    });
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

  Future<void> registrarPago(String comandaId, String metodo) async {
    try {
      await _db.collection('comandas').doc(comandaId).update({
        'estado': 'entregado',
        'payment': {
          'metodo': metodo,
          'estado': 'pagado',
          'fecha': FieldValue.serverTimestamp(),
        }
      });
      debugPrint("✅ Pago registrado para comanda $comandaId");
    } catch (e) {
      debugPrint("❌ Error al registrar el pago: $e");
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
