import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/categoria.dart';
import '../../providers/almacen_provider.dart';

class AdminCategoriasScreen extends StatelessWidget {
  const AdminCategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final almacenProvider = Provider.of<AlmacenProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<List<Categoria>>(
        stream: almacenProvider.categoriasStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categorias = snapshot.data!;
          if (categorias.isEmpty) {
            return const Center(child: Text('No hay categorías registradas.'));
          }

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, i) {
              final c = categorias[i];
              return ListTile(
                title: Text(c.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _abrirDialogoCategoria(context, categoria: c),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await almacenProvider.eliminarCategoria(c.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => _abrirDialogoCategoria(context),
      ),
    );
  }

  void _abrirDialogoCategoria(BuildContext context, {Categoria? categoria}) {
    final almacenProvider = Provider.of<AlmacenProvider>(context, listen: false);
    final nombreCtrl = TextEditingController(text: categoria?.name ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(categoria == null ? 'Nueva Categoría' : 'Editar Categoría'),
        content: TextField(
          controller: nombreCtrl,
          decoration: const InputDecoration(labelText: 'Nombre de la categoría'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              if (nombre.isEmpty) return;
              final nueva = Categoria(id: categoria?.id ?? '', name: nombre);
              if (categoria == null) {
                await almacenProvider.agregarCategoria(nueva);
              } else {
                await almacenProvider.actualizarCategoria(nueva);
              }
              Navigator.pop(context);
            },
            child: Text(categoria == null ? 'Agregar' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}
