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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final productos = snapshot.data!;
          final categorias = <String>{...productos.map((p) => p.category)}.toList();

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, i) {
              final categoria = categorias[i];
              final productosCategoria = productos.where((p) => p.category == categoria).toList();

              return ExpansionTile(
                title: Text(categoria.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                children: productosCategoria.map((p) {
                  String stockLabel = categoria == 'Sandwich' ? '${p.stock} kg' : '${p.stock} uds';
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('Stock: $stockLabel | \$${p.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => ProductDialog(
                              product: p,
                              onSave: (nuevo) => almacenProvider.actualizarProducto(nuevo),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => almacenProvider.eliminarProducto(p.id),
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => ProductDialog(
            onSave: (nuevo) => almacenProvider.agregarProducto(nuevo),
          ),
        ),
      ),
    );
  }
}
