class Salsa {
  final String id;
  final String nombre;
  final bool disponible;

  Salsa({required this.id, required this.nombre, this.disponible = true});

  factory Salsa.fromMap(String id, Map<String, dynamic> data) {
    return Salsa(
      id: id,
      nombre: data['nombre'] ?? '',
      disponible: data['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {'nombre': nombre, 'disponible': disponible};
}