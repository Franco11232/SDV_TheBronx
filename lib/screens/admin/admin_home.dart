import 'package:flutter/material.dart';
import 'package:svd_thebronx/models/product.dart';
import 'package:svd_thebronx/services/product_service.dart';

class AdminHome extends StatelessWidget {
  final ProductService _ps = ProductService();
  AdminHome({super.key});

  final List<String> categorias = [
    'Sandwich',
    'Burger',
    'Boneless',
    'Fries',
    'Dips'
  ];

  void _abrirDialogoProducto(BuildContext context, {Product? producto}) {
    final nombreCtrl = TextEditingController(text: producto?.name ?? '');
    final precioCtrl =
    TextEditingController(text: producto?.price.toStringAsFixed(2) ?? '');
    String categoriaSeleccionada = producto?.category ?? categorias.first;
    final disponible = ValueNotifier<bool>(producto?.disponible ?? true);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(producto == null ? 'Nuevo Producto' : 'Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: precioCtrl,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                const Text('Categoría:',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categorias.map((cat) {
                    final selected = categoriaSeleccionada == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: Colors.green,
                      onSelected: (_) {
                        setState(() => categoriaSeleccionada = cat);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
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

                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingrese nombre y precio válidos')),
                  );
                  return;
                }

                final p = Product(
                  id: producto?.id ?? '',
                  name: name,
                  price: price,
                  stock: producto?.stock ?? 0,
                  category: categoriaSeleccionada,
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
                    const SnackBar(
                        content: Text('Error al guardar producto')),
                  );
                }
              },
              child: Text(producto == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
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
                  const SnackBar(
                      content: Text('Error al eliminar producto')),
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

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _abrirDialogoProducto(context),
            child: const Icon(Icons.add),
          ),
          body: productos.isEmpty
              ? const Center(child: Text('No hay productos'))
              : ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final p = productos[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.fastfood),
                  title: Text(p.name),
                  subtitle: Text(
                      '\$${p.price.toStringAsFixed(2)} - ${p.category}'),
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
          ),
        );
      },
    );
  }
}
