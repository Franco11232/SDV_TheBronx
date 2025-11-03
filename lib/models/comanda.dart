import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_comanda.dart';

class Comanda {
  String? id;
  String clientName;
  String clientPhone;
  String type; // Para llevar / Domicilio / Comer aquí
  String address;
  String addressCol;
  Map<String, dynamic> payment; // { estado: 'pendiente', metodo: 'efectivo' }
  String estado; // pendiente / en_preparacion / entregado / cancelado
  DateTime date;
  double total;
  List<ItemComanda> details;

  Comanda({
    this.id,
    required this.clientName,
    required this.clientPhone,
    required this.type,
    required this.address,
    required this.addressCol,
    required this.payment,
    required this.estado,
    required this.date,
    required this.total,
    required this.details,
  });

  /// 🔹 Firestore → Comanda
  factory Comanda.fromMap(String id, Map<String, dynamic> data) {
    return Comanda(
      id: id,
      clientName: data['clientName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      type: data['type'] ?? 'Para llevar',
      address: data['address'] ?? '',
      addressCol: data['addressCol'] ?? '',
      payment: Map<String, dynamic>.from(
          data['payment'] ?? {'estado': 'pendiente', 'metodo': 'efectivo'}),
      estado: data['estado'] ?? 'pendiente',
      date: (data['date'] != null)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      total: (data['total'] != null)
          ? (data['total'] is int
          ? (data['total'] as int).toDouble()
          : data['total'])
          : 0.0,
      details: data['details'] != null
          ? (data['details'] as List)
          .map((e) => ItemComanda.fromMap(Map<String, dynamic>.from(e)))
          .toList()
          : [],
    );
  }

  /// 🔹 Comanda → Firestore
  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'clientPhone': clientPhone,
      'type': type,
      'address': address,
      'addressCol': addressCol,
      'payment': payment,
      'estado': estado,
      'date': date,
      'total': total,
      'details': details.map((e) => e.toMap()).toList(),
    };
  }
}
