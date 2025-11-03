import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/salsa.dart';
import '../../providers/almacen_provider.dart';

class AdminSalsasScreen extends StatelessWidget {
  const AdminSalsasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final almacen = Provider.of<AlmacenProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<List<Salsa>>(
        stream: almacen.salsasStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final salsas = snapshot.data!;
          if (salsas.isEmpty) return const Center(child: Text('No hay salsas registradas.'));

          return ListView.builder(
            itemCount: salsas.length,
            itemBuilder: (context, i) {
              final s = salsas[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text(s.nombre),
                  subtitle: Text(s.disponible ? 'Disponible' : 'No disponible'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarDialogo(context, salsa: s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async => await almacen.eliminarSalsa(s.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogo(context),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context, {Salsa? salsa}) {
    final almacen = Provider.of<AlmacenProvider>(context, listen: false);
    final nombreCtrl = TextEditingController(text: salsa?.nombre ?? '');
    bool disponible = salsa?.disponible ?? true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(salsa == null ? 'Nueva Salsa' : 'Editar Salsa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de la salsa'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Disponible'),
              value: disponible,
              onChanged: (v) => disponible = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              if (nombre.isEmpty) return;
              final nueva = Salsa(id: salsa?.id ?? '', nombre: nombre, disponible: disponible);
              if (salsa == null) {
                await almacen.agregarSalsa(nueva);
              } else {
                await almacen.actualizarSalsa(nueva);
              }
              Navigator.pop(context);
            },
            child: Text(salsa == null ? 'Agregar' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}
