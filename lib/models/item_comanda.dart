// lib/models/item_comanda.dart
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
    'productId': productId,
    'nombre': nombre,
    'name': nombre,
    'cantidad': cantidad,
    'cantidad_unit': cantidad,
    'precio_unit': priceUnit,
    'priceUnit': priceUnit,
    'sub_total': subTotal,
    'subTotal': subTotal,
  };

  factory ItemComanda.fromMap(Map<String, dynamic> m) {
    // Buscar varias posibles claves
    final productId =
        m['productoId'] ?? m['productId'] ?? m['producto_id'] ?? '';
    final nombre = m['nombre'] ?? m['name'] ?? m['producto'] ?? '';
    final cantidadRaw = m['cantidad'] ?? m['qty'] ?? m['cantidad_unit'] ?? 0;
    final precioRaw = m['precio_unit'] ?? m['priceUnit'] ?? m['precio'] ?? 0;

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
    );
  }
}
