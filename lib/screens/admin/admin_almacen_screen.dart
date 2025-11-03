import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/product.dart';
import '/providers/almacen_provider.dart';
import '/widgets/producto_dialog.dart';

class AdminAlmacenScreen extends StatelessWidget {
  const AdminAlmacenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final almacenProvider = Provider.of<AlmacenProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Almacén'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Product>>(
        stream: almacenProvider.productosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          }

          final productos = snapshot.data!;
          final categorias = productos.map((p) => p.categoria).toSet().toList();

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, i) {
              final categoria = categorias[i];
              final productosCategoria =
              productos.where((p) => p.categoria == categoria).toList();

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(
                    categoria.isNotEmpty ? categoria.toUpperCase() : "SIN CATEGORÍA",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: productosCategoria.isEmpty
                      ? [
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('No hay productos en esta categoría.'),
                    ),
                  ]
                      : productosCategoria.map((p) {
                    return ListTile(
                      title: Text(p.nombre),
                      subtitle: Text(
                        'Stock: | \$${p.precio.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => ProductDialog(
                                product: p,
                                categoriasStream: almacenProvider.categoriasStream,
                                salsasStream: almacenProvider.salsasStream,
                                onSave: (nuevo) async {
                                  await almacenProvider.actualizarProducto(nuevo);
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await almacenProvider.eliminarProducto(p.id);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => ProductDialog(
            categoriasStream: almacenProvider.categoriasStream,
            salsasStream: almacenProvider.salsasStream,
            onSave: (nuevo) async {
              await almacenProvider.agregarProducto(nuevo);
            },
          ),
        ),
      ),
    );
  }
}
