// lib/models/categoria.dart
class Categoria {
  final String id;
  // Corregido: La propiedad ahora es 'name' en lugar de 'nombre'.
  final String name;

  Categoria({ required this.id, required this.name });

  factory Categoria.fromMap(String id, Map<String, dynamic> data) {
    return Categoria(
      id: id,
      // Corregido: Solo se lee la clave 'name' para mantener la consistencia.
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    // Corregido: Se guarda usando la clave 'name'.
    'name': name,
  };
}
