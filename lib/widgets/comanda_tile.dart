import 'package:flutter/material.dart';
import '../models/comanda.dart';

class ComandaTile extends StatelessWidget {
  final Comanda comanda;
  final void Function(String nuevoEstado)? onActualizarEstado;
  final VoidCallback? onTap;
  final Color? tileColor; // ✅ Nuevo parámetro para el color

  const ComandaTile({
    super.key,
    required this.comanda,
    this.onActualizarEstado,
    this.onTap,
    this.tileColor, // ✅
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      // ✅ Se aplica el color de fondo a la tarjeta.
      color: tileColor,
      child: ListTile(
        onTap: onTap, // ✅ Se asigna el callback al ListTile.
        title: Text(comanda.clientName.isEmpty ? 'Sin nombre' : comanda.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${comanda.details.length}'),
            Text('Total: \$${comanda.total.toStringAsFixed(2)}'),
            Text('Estado: ${comanda.estado}'),
          ],
        ),
        isThreeLine: true,
        trailing: onActualizarEstado != null
            ? PopupMenuButton<String>(
                onSelected: onActualizarEstado,
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'en_preparacion', child: Text('En preparación')),
                  const PopupMenuItem(value: 'listo', child: Text('Listo')),
                ],
              )
            : null,
      ),
    );
  }
}
