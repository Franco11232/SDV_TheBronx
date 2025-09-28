import 'package:flutter/material.dart';
import 'package:svd_thebronx/services/comanda_service.dart';
import 'package:svd_thebronx/models/comanda.dart';

class ComandaProvider extends ChangeNotifier {
  final ComandaService _service = ComandaService();
  List<Comanda> pendientes = [];

  void loadPendientes() {
    _service.streamComandas('Pendiente').listen((list) {
      pendientes = list;
      notifyListeners();
    });  
  }
  Future<void> crearComanda(Comanda c) async => await _service.crearComanda(c);
  Future<void> actualizarEstado(String id, String estado) async => await _service.actualizarEstado(id, estado);
}