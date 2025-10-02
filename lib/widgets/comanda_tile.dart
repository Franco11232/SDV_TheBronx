import 'package:flutter/material.dart';
import '../models/comanda.dart';

class ComandaTile extends StatelessWidget {
  final Comanda comanda;
  final void Function(String nuevoEstado)? onActualizarEstado;

  const ComandaTile({super.key, required this.comanda, this.onActualizarEstado});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(comanda.clientName.isEmpty ? 'Sin nombre' : comanda.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${comanda.details.length}'),
            Text('Total: \$${comanda.total.toStringAsFixed(2)}'),
            Text('Estado: ${comanda.estado}'),
          ],
        ),
        trailing: onActualizarEstado != null
            ? PopupMenuButton<String>(
                onSelected: onActualizarEstado,
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'en_preparacion', child: Text('En preparación')),
                  PopupMenuItem(value: 'listo', child: Text('Listo')),
                ],
              )
            : null, 
      ),
    );
  }
}
