import 'package:cloud_firestore/cloud_firestore.dart';

class ItemComanda {
  final String productId;
  final String nombre;
  final int cantidad;
  final double priceUnit; 
  final double subTotal;

  ItemComanda({
    required this.productId,
    required this.nombre,
    required this.cantidad,
    required this.priceUnit,
  }) : subTotal = cantidad * priceUnit;

  Map<String, dynamic> toMap() => {
    'productoId': productId,
    'nombre': nombre,
    'cantidad': cantidad,
    'precio_unit': priceUnit,
    'sub_total': subTotal,
  };

  factory ItemComanda.fromMap(Map<String, dynamic> m) => ItemComanda(
    productId: m['productoId'],
    nombre: m['nombre'] ,
    cantidad: (m['cantidad'] ?? 0) as int,
    priceUnit: (m['precio_unit'] ?? 0).toDouble(),
  );

}

class Comanda{
  final String? id;
  final String clientName;
  final String clientPhone;
  final String type; // "Domicilio" o "Para llevar"
  final String address; // Solo si es "Domicilio"
  final String estado; // "Pendiente", "En Proceso", "Completada"
  final Map<String, dynamic> payment; // {"method": "Efectivo", "amount": 100.0}
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
  Map<String, dynamic> toMap() => {
    'cliente': {'nombre': clientName, 'telefono': clientPhone},
    'tipo': type,
    'direccion': address,
    'estado': estado,
    'pago': payment,
    'fecha': date != null ? date!.toUtc() : FieldValue.serverTimestamp(),
    'total': total,
    'detalles': details.map((i) => i.toMap()).toList(),
  };

  factory Comanda.fromMap(String id, Map<String, dynamic> m) {
    final cliente = m['cliente'] ?? {};
    final detalles = (m['detalles'] as List? ?? [])
        .map((d) => ItemComanda.fromMap(Map<String, dynamic>.from(d)))
        .toList();
    final fecha = m['fecha'] is Timestamp ? (m['fecha'] as Timestamp).toDate() : null;
    return Comanda(
      id: id,
      clientName: cliente['nombre'] ?? '',
      clientPhone: cliente['telefono'] ?? '',
      type: m['tipo'] ?? 'comer_aqui',
      estado: m['estado'] ?? 'pendiente',
      payment: Map<String, dynamic>.from(m['pago'] ?? {'estado': 'pendiente', 'metodo': 'efectivo'}),
      date: fecha,
      total: (m['total'] ?? 0).toDouble(),
      details: detalles, address: '',
    );
  }
}
