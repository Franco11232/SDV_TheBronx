// lib/models/comanda.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_comanda.dart';

class Comanda {
  final String? id;
  final String clientName;
  final String clientPhone;
  final String type; // 'comer_aqui', 'para_llevar', 'domicilio' (o similares)
  final String address;
  final String estado; // 'pendiente','en_preparacion','listo','entregado'
  final Map<String, dynamic> payment; // ejemplo: {'estado':'pendiente','metodo':'efectivo'}
  final DateTime? date;
  final double total;
  final List<ItemComanda> details;

  Comanda({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.type,
    required this.address,
    required this.estado,
    required this.payment,
    required this.date,
    required this.total,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'cliente': {'nombre': clientName, 'telefono': clientPhone},
      'tipo': type,
      'direccion': address,
      'estado': estado,
      'pago': payment,
      'fecha': date != null ? date!.toUtc() : FieldValue.serverTimestamp(),
      'total': total,
      'detalles': details.map((d) => d.toMap()).toList(),
    };
  }

  factory Comanda.fromMap(String id, Map<String, dynamic> m) {
    // cliente puede estar en 'cliente' o 'client'
    final cliente = (m['cliente'] ?? m['client'] ?? {}) as Map<String, dynamic>;
    final clienteNombre = cliente['nombre'] ?? cliente['name'] ?? '';
    final clienteTelefono = cliente['telefono'] ?? cliente['phone'] ?? '';

    // detalles puede estar bajo 'detalles' o 'details' o 'productos'
    final detallesRaw = m['detalles'] ?? m['details'] ?? m['productos'] ?? [];
    final detallesList = (detallesRaw as List)
        .map((d) => ItemComanda.fromMap(Map<String, dynamic>.from(d)))
        .toList();

    final fechaRaw = m['fecha'] ?? m['fecha_creacion'] ?? m['date'];
    DateTime? fecha;
    if (fechaRaw is Timestamp) fecha = fechaRaw.toDate();
    else if (fechaRaw is String) {
      fecha = DateTime.tryParse(fechaRaw);
    }

    final pagoRaw = m['pago'] ?? m['payment'] ?? {};
    final pago = Map<String, dynamic>.from(pagoRaw as Map? ?? {'estado': 'pendiente', 'metodo': 'efectivo'});

    final totalRaw = m['total'] ?? m['precio_total'] ?? 0;
    double total = 0.0;
    if (totalRaw is num) total = totalRaw.toDouble();
    else if (totalRaw is String) total = double.tryParse(totalRaw) ?? 0.0;

    return Comanda(
      id: id,
      clientName: clienteNombre,
      clientPhone: clienteTelefono,
      type: (m['tipo'] ?? m['type'] ?? 'comer_aqui').toString(),
      address: (m['direccion'] ?? m['address'] ?? '').toString(),
      estado: (m['estado'] ?? m['status'] ?? 'pendiente').toString(),
      payment: pago,
      date: fecha,
      total: total,
      details: detallesList,
    );
  }
}
