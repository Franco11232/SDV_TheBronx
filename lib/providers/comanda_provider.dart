import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:svd_thebronx/models/comanda.dart';

class ComandaProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Comanda> pendientes = [];

  /// 🔁 Escucha en tiempo real todas las comandas con estado pendiente o en preparación
  Stream<List<Comanda>> streamComandas() {
    return _db
        .collection('comandas')
        .where('estado', whereIn: ['pendiente', 'en_preparacion'])
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Comanda.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// 🧩 Método para actualizar el estado
  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    await _db.collection('comandas').doc(id).update({'estado': nuevoEstado});
  }

  /// (opcional) carga inicial — si no usas el stream
  Future<void> loadPendientes() async {
    final snapshot = await _db
        .collection('comandas')
        .where('estado', isEqualTo: 'pendiente')
        .get();

    pendientes =
        snapshot.docs.map((d) => Comanda.fromMap(d.id, d.data())).toList();
    notifyListeners();
  }
}