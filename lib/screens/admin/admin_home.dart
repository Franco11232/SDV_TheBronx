import 'package:flutter/material.dart';
import 'package:svd_thebronx/models/product.dart';
import 'package:svd_thebronx/services/product_service.dart';

class AdminHome extends StatelessWidget {
  final ProductService _ps = ProductService();

  AdminHome({super.key});

  void _abrirDialogoProducto(BuildContext context, {Product? producto}) {
    final nombreCtrl = TextEditingController(text: producto?.name ?? '');
    final precioCtrl =
    TextEditingController(text: producto?.price.toStringAsFixed(2) ?? '');
    final categoriaCtrl = TextEditingController(text: producto?.category ?? '');
    final disponible = ValueNotifier<bool>(producto?.disponible ?? true);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(producto == null ? 'Nuevo Producto' : 'Editar Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: precioCtrl,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: categoriaCtrl,
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: disponible,
              builder: (_, val, __) => SwitchListTile(
                title: const Text('Disponible'),
                value: val,
                onChanged: (v) => disponible.value = v,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nombreCtrl.text.trim();
              final price = double.tryParse(precioCtrl.text.trim()) ?? 0.0;
              final category = categoriaCtrl.text.trim();

              if (name.isEmpty || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingrese nombre y precio válido'),
                  ),
                );
                return;
              }

              final p = Product(
                id: producto?.id ?? '',
                name: name,
                price: price,
                stock: 0,
                category: category,
                disponible: disponible.value,
              );

              try {
                if (producto == null) {
                  await _ps.addProduct(p);
                } else {
                  await _ps.updateProduct(p);
                }
                Navigator.pop(context);
              } catch (e) {
                print("Error al guardar producto: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al guardar producto')),
                );
              }
            },
            child: Text(producto == null ? 'Agregar' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarProducto(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Seguro que quieres eliminar "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _ps.deleteProduct(p.id);
                Navigator.pop(context);
              } catch (e) {
                print("Error al eliminar producto: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar producto')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: _ps.streamProduct(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar productos: ${snapshot.error}'),
          );
        }

        final productos = snapshot.data ?? [];

        if (productos.isEmpty) {
          return const Center(child: Text('No hay productos'));
        }

        return ListView.builder(
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final p = productos[index];
            return Card(  // <-- Aquí agregamos Card
                child: ListTile(
                  leading: const Icon(Icons.fastfood),
                  title: Text(p.name),
                  subtitle: Text('\$${p.price.toStringAsFixed(2)} - ${p.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _abrirDialogoProducto(context, producto: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _eliminarProducto(context, p),
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
