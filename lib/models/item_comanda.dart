class ItemComanda {
  String idProducto;
  String nombre;
  int cantidad;
  double priceUnit;
  double subTotal;

  // Extensiones extra
  bool llevaMediaOrdenBones; // Si el cliente pidió media orden
  double? precioMediaOrden; // Precio adicional
  String? salsaSeleccionada; // Salsa principal elegida
  List<String>? salsasSeleccionadas; // Salsas disponibles

  ItemComanda({
    required this.idProducto,
    required this.nombre,
    required this.cantidad,
    required this.priceUnit,
    required this.subTotal,
    this.llevaMediaOrdenBones = false,
    this.precioMediaOrden,
    this.salsaSeleccionada,
    this.salsasSeleccionadas,
  });

  /// 🔹 Firestore → Objeto
  factory ItemComanda.fromMap(Map<String, dynamic> data) {
    return ItemComanda(
      idProducto: data['idProducto'] ?? '',
      nombre: data['nombre'] ?? '',
      cantidad: data['cantidad'] ?? 0,
      priceUnit: (data['priceUnit'] is int)
          ? (data['priceUnit'] as int).toDouble()
          : (data['priceUnit'] ?? 0.0),
      subTotal: (data['subTotal'] is int)
          ? (data['subTotal'] as int).toDouble()
          : (data['subTotal'] ?? 0.0),
      llevaMediaOrdenBones: data['llevaMediaOrdenBones'] ?? false,
      precioMediaOrden: (data['precioMediaOrden'] is int)
          ? (data['precioMediaOrden'] as int).toDouble()
          : data['precioMediaOrden'],
      salsaSeleccionada: data['salsaSeleccionada'],
      salsasSeleccionadas: data['salsasSeleccionadas'] != null
          ? List<String>.from(data['salsasSeleccionadas'])
          : [],
    );
  }

  /// 🔹 Objeto → Firestore
  Map<String, dynamic> toMap() {
    return {
      'idProducto': idProducto,
      'nombre': nombre,
      'cantidad': cantidad,
      'priceUnit': priceUnit,
      'subTotal': subTotal,
      'llevaMediaOrdenBones': llevaMediaOrdenBones,
      'precioMediaOrden': precioMediaOrden,
      'salsaSeleccionada': salsaSeleccionada,
      'salsasSeleccionadas': salsasSeleccionadas ?? [],
    };
  }

  /// 🔹 Crea una copia modificada (útil para actualizar cantidad o salsa)
  ItemComanda copyWith({
    String? idProducto,
    String? nombre,
    int? cantidad,
    double? priceUnit,
    double? subTotal,
    bool? llevaMediaOrdenBones,
    double? precioMediaOrden,
    String? salsaSeleccionada,
    List<String>? salsasSeleccionadas,
  }) {
    return ItemComanda(
      idProducto: idProducto ?? this.idProducto,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      priceUnit: priceUnit ?? this.priceUnit,
      subTotal: subTotal ?? this.subTotal,
      llevaMediaOrdenBones: llevaMediaOrdenBones ?? this.llevaMediaOrdenBones,
      precioMediaOrden: precioMediaOrden ?? this.precioMediaOrden,
      salsaSeleccionada: salsaSeleccionada ?? this.salsaSeleccionada,
      salsasSeleccionadas: salsasSeleccionadas ?? this.salsasSeleccionadas,
    );
  }
}
