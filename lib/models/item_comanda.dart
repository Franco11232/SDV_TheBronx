// lib/models/item_comanda.dart

class ItemComanda {
  final String idProducto;
  final String nombre;
  final int cantidad;
  final double priceUnit;
  final double subTotal;

  // ✅ Corregido: Se usa un único campo para la salsa.
  final String? salsa;
  final bool llevaMediaOrdenBones; // Se mantiene para identificar el item

  ItemComanda({
    required this.idProducto,
    required this.nombre,
    required this.cantidad,
    required this.priceUnit,
    required this.subTotal,
    this.salsa,
    this.llevaMediaOrdenBones = false,
  });

  factory ItemComanda.fromMap(Map<String, dynamic> data) {
    return ItemComanda(
      idProducto: data['idProducto'] ?? '',
      nombre: data['nombre'] ?? '',
      cantidad: (data['cantidad'] ?? 1) as int,
      priceUnit: (data['priceUnit'] ?? 0.0).toDouble(),
      subTotal: (data['subTotal'] ?? 0.0).toDouble(),
      // ✅
      salsa: data['salsa'],
      llevaMediaOrdenBones: data['llevaMediaOrdenBones'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProducto': idProducto,
      'nombre': nombre,
      'cantidad': cantidad,
      'priceUnit': priceUnit,
      'subTotal': subTotal,
      // ✅
      'salsa': salsa,
      'llevaMediaOrdenBones': llevaMediaOrdenBones,
    };
  }

  ItemComanda copyWith({
    String? idProducto,
    String? nombre,
    int? cantidad,
    double? priceUnit,
    double? subTotal,
    // ✅
    String? salsa,
    bool? llevaMediaOrdenBones,
  }) {
    return ItemComanda(
      idProducto: idProducto ?? this.idProducto,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      priceUnit: priceUnit ?? this.priceUnit,
      subTotal: subTotal ?? this.subTotal,
      // ✅
      salsa: salsa ?? this.salsa,
      llevaMediaOrdenBones: llevaMediaOrdenBones ?? this.llevaMediaOrdenBones,
    );
  }
}
