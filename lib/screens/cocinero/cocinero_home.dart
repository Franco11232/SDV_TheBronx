import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comanda.dart';
import '../../providers/comanda_provider.dart';

class CocineroHome extends StatelessWidget {
  const CocineroHome({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ComandaProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Cocinero - Comandas'), backgroundColor: Colors.brown.shade400),
      body: StreamBuilder<List<Comanda>>(
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

              final detallesValidos = com.details.where((d) => d != null).toList();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(
                    com.clientName.isEmpty ? 'Sin nombre' : com.clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Estado: ${com.estado} • Total: \$${com.total.toStringAsFixed(2)}'),
                  children: [
                    ...detallesValidos.map((item) {
                      return ListTile(
                        title: Text(item.nombre),
                        // ✅ Corregido: Se muestra la información con la nueva estructura de datos.
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cantidad: ${item.cantidad}'),
                            // Muestra la salsa si existe
                            if (item.salsa != null)
                              Text('Salsa: ${item.salsa}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            // Indica si lleva el extra de media orden
                            if (item.llevaMediaOrdenBones)
                              const Text('(Con media orden de Boneless)', style: TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                        trailing: Text('\$${item.subTotal.toStringAsFixed(2)}'),
                      );
                    }),
                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        if (com.estado == 'pendiente')
                          TextButton(
                            onPressed: () => prov.actualizarEstado(com.id!, 'en_preparacion'),
                            child: const Text('Mover a Preparación'),
                          ),
                        if (com.estado == 'en_preparacion')
                          TextButton(
                            onPressed: () => prov.actualizarEstado(com.id!, 'listo'),
                            child: const Text('Marcar como Listo'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
