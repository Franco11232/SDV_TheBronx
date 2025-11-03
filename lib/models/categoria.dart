class Categoria {
  final String id;
  final String nombre;

  Categoria({required this.id, required this.nombre});

  factory Categoria.fromMap(String id, Map<String, dynamic> data) {
    return Categoria(
      id: id,
      nombre: data['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'nombre': nombre};
}