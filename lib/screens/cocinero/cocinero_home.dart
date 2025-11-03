import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comanda.dart';
import '../../providers/comanda_provider.dart';

class CocineroHome extends StatelessWidget {
  const CocineroHome({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ComandaProvider>(context, listen: false);

    return StreamBuilder<List<Comanda>>(
      stream: prov.streamComandasActivas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final comandas = snapshot.data ?? [];
        if (comandas.isEmpty) {
          return const Center(child: Text('No hay comandas pendientes'));
        }

        return ListView.builder(
          itemCount: comandas.length,
          itemBuilder: (context, i) {
            final com = comandas[i];

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  com.clientName.isEmpty ? 'Sin nombre' : com.clientName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Items: ${com.details.length} • Total: \$${com.total.toStringAsFixed(2)}\n'
                      'Estado: ${com.estado}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => prov.actualizarEstado(com.id!, v),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'en_preparacion',
                      child: Text('En preparación'),
                    ),
                    PopupMenuItem(
                      value: 'listo',
                      child: Text('Listo'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
