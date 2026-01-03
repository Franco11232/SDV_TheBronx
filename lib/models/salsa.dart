// lib/models/salsa.dart
class Salsa {
  final String id;
  // Corregido: La propiedad ahora es 'name' en lugar de 'nombre'.
  final String name;
  final bool disponible;

  Salsa({ required this.id, required this.name, this.disponible = true });

  factory Salsa.fromMap(String id, Map<String, dynamic> data) {
    return Salsa(
      id: id,
      // Corregido: Solo se lee la clave 'name' para mantener la consistencia.
      name: data['name'] ?? '',
      disponible: data['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    // Corregido: Se guarda usando la clave 'name'.
    'name': name,
    'disponible': disponible,
  };
}
