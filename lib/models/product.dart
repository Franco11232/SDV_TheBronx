class Product {
  String id;
  String nombre;
  String categoria;
  double precio;
  String descripcion;
  String imagenUrl;
  bool disponible;

  // 🔹 Campos para media orden
  bool tieneMediaOrden;
  double? precioMediaOrden;

  // 🔹 Campos para salsas
  List<String> salsas;
  String? salsaSeleccionada;

  // 🔹 Campos usados en comandas
  bool mediaOrdenSeleccionada;
  String? salsaComanda;

  Product({
    this.id = '',
    required this.nombre,
    required this.categoria,
    required this.precio,
    this.descripcion = '',
    this.imagenUrl = '',
    this.disponible = true,
    this.tieneMediaOrden = false,
    this.precioMediaOrden,
    this.salsas = const [],
    this.salsaSeleccionada,
    this.mediaOrdenSeleccionada = false,
    this.salsaComanda,
  });

  /// 🔹 Convierte un documento Firestore en un objeto Product
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nombre: data['nombre'] ?? '',
      categoria: data['categoria'] ?? '',
      precio: (data['precio'] != null)
          ? (data['precio'] is int
          ? (data['precio'] as int).toDouble()
          : (data['precio'] as num).toDouble())
          : 0.0,
      descripcion: data['descripcion'] ?? '',
      imagenUrl: data['imagenUrl'] ?? '',
      disponible: data['disponible'] ?? true,
      tieneMediaOrden: data['tieneMediaOrden'] ?? false,
      precioMediaOrden: (data['precioMediaOrden'] != null)
          ? (data['precioMediaOrden'] is int
          ? (data['precioMediaOrden'] as int).toDouble()
          : (data['precioMediaOrden'] as num).toDouble())
          : null,
      salsas: (data['salsas'] != null)
          ? List<String>.from(data['salsas'])
          : [],
      salsaSeleccionada: data['salsaSeleccionada'],
      mediaOrdenSeleccionada: data['mediaOrdenSeleccionada'] ?? false,
      salsaComanda: data['salsaComanda'],
    );
  }

  /// 🔹 Convierte el objeto Product a un mapa para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'disponible': disponible,
      'tieneMediaOrden': tieneMediaOrden,
      'precioMediaOrden': precioMediaOrden,
      'salsas': salsas,
      'salsaSeleccionada': salsaSeleccionada,
      'mediaOrdenSeleccionada': mediaOrdenSeleccionada,
      'salsaComanda': salsaComanda,
    };
  }

  Product copyWith({
    String? id,
    String? nombre,
    String? categoria,
    double? precio,
    String? descripcion,
    String? imagenUrl,
    bool? disponible,
    bool? tieneMediaOrden,
    double? precioMediaOrden,
    List<String>? salsas,
    String? salsaSeleccionada,
    bool? mediaOrdenSeleccionada,
    String? salsaComanda,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      disponible: disponible ?? this.disponible,
      tieneMediaOrden: tieneMediaOrden ?? this.tieneMediaOrden,
      precioMediaOrden: precioMediaOrden ?? this.precioMediaOrden,
      salsas: salsas ?? this.salsas,
      salsaSeleccionada: salsaSeleccionada ?? this.salsaSeleccionada,
      mediaOrdenSeleccionada:
      mediaOrdenSeleccionada ?? this.mediaOrdenSeleccionada,
      salsaComanda: salsaComanda ?? this.salsaComanda,
    );
  }

  double getPrecioTotal() {
    double total = precio;
    if (mediaOrdenSeleccionada && precioMediaOrden != null) {
      total += precioMediaOrden!;
    }
    return total;
  }
}
