import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svd_thebronx/models/product.dart';
import 'package:svd_thebronx/providers/almacen_provider.dart';
import 'package:svd_thebronx/widgets/producto_dialog.dart';

class AdminAlmacenScreen extends StatelessWidget {
  const AdminAlmacenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final almacenProvider = Provider.of<AlmacenProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Almacén'),
        centerTitle: true,
      ),
      body: StreamBuilder<Map<String, List<Product>>>(
        stream: almacenProvider.streamProductosPorCategoria(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categorias = snapshot.data!.keys.toList();

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              final product = snapshot.data![categoria]!;

              return ExpansionTile(
                title: Text(categoria.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                children: product.map((product) {
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                        'Stock: ${product.stock} | \$${product.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => ProductDialog(
                                product: product,
                                onSave: (nuevo) => almacenProvider
                                    .actualizarProducto(product.id, nuevo),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              almacenProvider.eliminarProducto(product.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => ProductDialog(
              onSave: (product) => almacenProvider.agregarProducto(product),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
