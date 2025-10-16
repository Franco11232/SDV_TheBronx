import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svd_thebronx/models/comanda.dart';
import '../../providers/comanda_provider.dart';

class CocineroHome extends StatelessWidget {
  const CocineroHome({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ComandaProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Cocinero - Comandas')),
      body: StreamBuilder<List<Comanda>>(
        stream: prov.streamComandas(),
        builder: (context, snapshot) {
          // Esperando datos
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final comandas = snapshot.data ?? [];
          if (comandas.isEmpty) {
            return const Center(child: Text('No hay comandas pendientes'));
          }

          // Mostrar comandas
          return ListView.builder(
            itemCount: comandas.length,
            itemBuilder: (context, i) {
              final com = comandas[i];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    com.clientName.isEmpty
                        ? 'Sin nombre'
                        : com.clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Items: ${com.details.length} • Total: \$${com.total.toStringAsFixed(2)}\n'
                    'Estado: ${com.estado}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) =>
                        prov.actualizarEstado(com.id!, v),
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
                  onTap: () {
                    // Aquí podrías abrir una pantalla de detalles si quieres
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Detalles de ${com.clientName}'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: com.details
                              .map((item) => ListTile(
                                    title: Text(item.nombre),
                                    subtitle: Text(
                                        'x${item.cantidad}  \$${item.priceUnit.toStringAsFixed(2)}'),
                                    trailing: Text(
                                        '\$${item.subTotal.toStringAsFixed(2)}'),
                                  ))
                              .toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}


