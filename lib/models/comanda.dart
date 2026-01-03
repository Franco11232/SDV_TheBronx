// lib/models/comanda.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_comanda.dart';

class Comanda {
  final String? id;
  final String clientName;
  final String clientPhone;
  final String type;
  final String address;
  final String addressCol;
  final String estado;
  final Map<String, dynamic> payment;
  final DateTime date;
  final double total;
  final List<ItemComanda> details;

  Comanda({
    this.id,
    required this.clientName,
    required this.clientPhone,
    required this.type,
    required this.address,
    required this.addressCol,
    required this.estado,
    required this.payment,
    required this.date,
    required this.total,
    required this.details,
  });

  factory Comanda.fromMap(String id, Map<String, dynamic> data) {
    DateTime fecha;
    final rawFecha = data['date'];
    if (rawFecha is Timestamp) {
      fecha = rawFecha.toDate();
    } else if (rawFecha is String) {
      fecha = DateTime.tryParse(rawFecha) ?? DateTime.now();
    } else if (rawFecha is DateTime) {
      fecha = rawFecha;
    } else {
      fecha = DateTime.now();
    }

    final detalles = (data['details'] as List<dynamic>?)
        ?.map((e) => ItemComanda.fromMap(Map<String, dynamic>.from(e)))
        .toList() ??
        [];

    return Comanda(
      id: id,
      clientName: data['clientName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      type: data['type'] ?? 'Para llevar',
      address: data['address'] ?? '',
      addressCol: data['addressCol'] ?? '',
      estado: data['estado'] ?? 'pendiente',
      payment: Map<String, dynamic>.from(data['payment'] ?? {}),
      date: fecha,
      total: (data['total'] ?? 0).toDouble(),
      details: detalles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'clientPhone': clientPhone,
      'type': type,
      'address': address,
      'addressCol': addressCol,
      'estado': estado,
      'payment': payment,
      'date': date, // Se usa la fecha existente
      'total': total,
      'details': details.map((d) => d.toMap()).toList(),
    };
  }
  
  // ✅ Añadido método copyWith para facilitar las actualizaciones
  Comanda copyWith({
    String? id,
    String? clientName,
    String? clientPhone,
    String? type,
    String? address,
    String? addressCol,
    String? estado,
    Map<String, dynamic>? payment,
    DateTime? date,
    double? total,
    List<ItemComanda>? details,
  }) {
    return Comanda(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      type: type ?? this.type,
      address: address ?? this.address,
      addressCol: addressCol ?? this.addressCol,
      estado: estado ?? this.estado,
      payment: payment ?? this.payment,
      date: date ?? this.date,
      total: total ?? this.total,
      details: details ?? this.details,
    );
  }
}
