// lib/models/item_comanda.dart

class ItemComanda {
  final String idProducto;
  final String nombre;
  final int cantidad;
  final double priceUnit;
  final double subTotal;

  final bool llevaMediaOrdenBones;
  final double? precioMediaOrden;
  final List<String>? salsasSeleccionadas;
  final String? salsaSeleccionada;

  ItemComanda({
    required this.idProducto,
    required this.nombre,
    required this.cantidad,
    required this.priceUnit,
    required this.subTotal,
    this.llevaMediaOrdenBones = false,
    this.precioMediaOrden,
    this.salsasSeleccionadas,
    this.salsaSeleccionada,
  });

  // Corregido: Asegurarse de que solo se usen claves en inglés.
  factory ItemComanda.fromMap(Map<String, dynamic> data) {
    return ItemComanda(
      idProducto: data['idProducto'] ?? '',
      nombre: data['nombre'] ?? '', // Aunque 'nombre' está en español, parece ser el estándar en este modelo.
      cantidad: (data['cantidad'] ?? 1) as int,
      priceUnit: (data['priceUnit'] ?? 0.0).toDouble(),
      subTotal: (data['subTotal'] ?? 0.0).toDouble(),
      llevaMediaOrdenBones: data['llevaMediaOrdenBones'] ?? false,
      precioMediaOrden: (data['precioMediaOrden'])?.toDouble(),
      salsasSeleccionadas: data['salsasSeleccionadas'] != null
          ? List<String>.from(data['salsasSeleccionadas'])
          : null,
      salsaSeleccionada: data['salsaSeleccionada'],
    );
  }

  // ✅ toMap ya usa los nombres en inglés (y 'nombre'), no necesita cambios.
  Map<String, dynamic> toMap() {
    return {
      'idProducto': idProducto,
      'nombre': nombre,
      'cantidad': cantidad,
      'priceUnit': priceUnit,
      'subTotal': subTotal,
      'llevaMediaOrdenBones': llevaMediaOrdenBones,
      'precioMediaOrden': precioMediaOrden,
      'salsasSeleccionadas': salsasSeleccionadas,
      'salsaSeleccionada': salsaSeleccionada,
    };
  }

  ItemComanda copyWith({
    String? idProducto,
    String? nombre,
    int? cantidad,
    double? priceUnit,
    double? subTotal,
    bool? llevaMediaOrdenBones,
    double? precioMediaOrden,
    List<String>? salsasSeleccionadas,
    String? salsaSeleccionada,
  }) {
    return ItemComanda(
      idProducto: idProducto ?? this.idProducto,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      priceUnit: priceUnit ?? this.priceUnit,
      subTotal: subTotal ?? this.subTotal,
      llevaMediaOrdenBones: llevaMediaOrdenBones ?? this.llevaMediaOrdenBones,
      precioMediaOrden: precioMediaOrden ?? this.precioMediaOrden,
      salsasSeleccionadas: salsasSeleccionadas ?? this.salsasSeleccionadas,
      salsaSeleccionada: salsaSeleccionada ?? this.salsaSeleccionada,
    );
  }
}
