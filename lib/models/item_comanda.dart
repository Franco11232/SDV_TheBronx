// lib/models/item_comanda.dart
class ItemComanda {
  final String productId;
  final String nombre;
  final int cantidad;
  final double priceUnit;
  final double subTotal;

  // campos opcionales
  final bool llevaMediaOrdenBones;
  final String? salsaSeleccionada;
  final double? precioMediaOrden; // normalmente 75

  ItemComanda({
    required this.productId,
    required this.nombre,
    required this.cantidad,
    required this.priceUnit,
    this.llevaMediaOrdenBones = false,
    this.salsaSeleccionada,
    this.precioMediaOrden,
  }) : subTotal = (cantidad * priceUnit) +
      ((llevaMediaOrdenBones && precioMediaOrden != null)
          ? precioMediaOrden
          : 0);

  Map<String, dynamic> toMap() => {
    'productoId': productId,
    'nombre': nombre,
    'cantidad': cantidad,
    'precio_unit': priceUnit,
    'sub_total': subTotal,
    'llevaMediaOrdenBones': llevaMediaOrdenBones,
    'salsaSeleccionada': salsaSeleccionada,
    'precioMediaOrden': precioMediaOrden,
  };

  factory ItemComanda.fromMap(Map<String, dynamic> m) {
    final productId = m['productoId'] ?? m['productId'] ?? '';
    final nombre = m['nombre'] ?? m['name'] ?? '';
    final cantidadRaw = m['cantidad'] ?? m['qty'] ?? 0;
    final precioRaw = m['precio_unit'] ?? m['priceUnit'] ?? 0;

    int cantidad = 0;
    if (cantidadRaw is int) cantidad = cantidadRaw;
    else if (cantidadRaw is num) cantidad = (cantidadRaw as num).toInt();
    else if (cantidadRaw is String) cantidad = int.tryParse(cantidadRaw) ?? 0;

    double priceUnit = 0.0;
    if (precioRaw is num) priceUnit = (precioRaw as num).toDouble();
    else if (precioRaw is String) priceUnit = double.tryParse(precioRaw) ?? 0.0;

    return ItemComanda(
      productId: productId,
      nombre: nombre,
      cantidad: cantidad,
      priceUnit: priceUnit,
      llevaMediaOrdenBones: m['llevaMediaOrdenBones'] ?? false,
      salsaSeleccionada: m['salsaSeleccionada'],
      precioMediaOrden:
      (m['precioMediaOrden'] is num) ? (m['precioMediaOrden'] as num).toDouble() : null,
    );
  }
}
