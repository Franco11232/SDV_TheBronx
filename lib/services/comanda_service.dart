import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comanda.dart';

class ComandaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Obtener todas las comandas activas (pendientes o en preparación)
  Stream<List<Comanda>> getComandasActivas() {
    return _db
        .collection('comandas')
        .where('estado', whereIn: ['pendiente', 'en_preparacion'])
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comanda.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// 🔹 Obtener historial de comandas (entregadas o canceladas)
  Stream<List<Comanda>> getHistorial() {
    return _db
        .collection('comandas')
        .where('estado', whereIn: ['entregado', 'cancelado'])
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comanda.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// 🔹 Crear nueva comanda
  Future<void> addComanda(Comanda comanda) async {
    try {
      await _db.collection('comandas').add(comanda.toMap());
      print('✅ Comanda guardada correctamente');
    } catch (e) {
      print('❌ Error al guardar la comanda: $e');
      rethrow;
    }
  }

  /// 🔹 Actualizar estado de la comanda
  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    try {
      await _db.collection('comandas').doc(id).update({
        'estado': nuevoEstado,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });
      print('🔄 Estado actualizado a $nuevoEstado');
    } catch (e) {
      print('❌ Error al actualizar estado: $e');
    }
  }

  /// 🔹 Eliminar comanda
  Future<void> eliminarComanda(String id) async {
    try {
      await _db.collection('comandas').doc(id).delete();
      print('🗑️ Comanda eliminada correctamente');
    } catch (e) {
      print('❌ Error al eliminar comanda: $e');
    }
  }
}
