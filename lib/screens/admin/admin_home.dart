import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final ProductService _productService = ProductService();

  void _mostrarDialogoProducto({Product? productoExistente}) {
    final TextEditingController nombreCtrl = TextEditingController(text: productoExistente?.nombre ?? '');
    final TextEditingController categoriaCtrl = TextEditingController(text: productoExistente?.categoria ?? '');
    final TextEditingController precioCtrl = TextEditingController(
        text: productoExistente?.precio != null ? productoExistente!.precio.toString() : '');
    final TextEditingController descripcionCtrl = TextEditingController(text: productoExistente?.descripcion ?? '');
    final TextEditingController imagenCtrl = TextEditingController(text: productoExistente?.imagenUrl ?? '');
    final TextEditingController precioMediaCtrl = TextEditingController(
        text: productoExistente?.precioMediaOrden != null
            ? productoExistente!.precioMediaOrden.toString()
            : '');
    final TextEditingController salsaCtrl = TextEditingController();

    bool disponible = productoExistente?.disponible ?? true;
    bool tieneMediaOrden = productoExistente?.tieneMediaOrden ?? false;
    List<String> salsas = List<String>.from(productoExistente?.salsas ?? []);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(productoExistente == null ? 'Agregar producto' : 'Editar producto'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: categoriaCtrl,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                    ),
                    TextField(
                      controller: precioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio'),
                    ),
                    TextField(
                      controller: descripcionCtrl,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                    ),
                    TextField(
                      controller: imagenCtrl,
                      decoration: const InputDecoration(labelText: 'URL de imagen'),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Checkbox para media orden
                    CheckboxListTile(
                      title: const Text('Tiene media orden'),
                      value: tieneMediaOrden,
                      onChanged: (v) => setState(() => tieneMediaOrden = v ?? false),
                    ),

                    if (tieneMediaOrden)
                      TextField(
                        controller: precioMediaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Precio media orden'),
                      ),

                    const SizedBox(height: 10),

                    // ✅ Lista de salsas
                    const Text('Salsas disponibles', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 6,
                      children: salsas
                          .map((s) => Chip(
                        label: Text(s),
                        onDeleted: () => setState(() => salsas.remove(s)),
                      ))
                          .toList(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: salsaCtrl,
                            decoration: const InputDecoration(labelText: 'Agregar salsa'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            if (salsaCtrl.text.trim().isNotEmpty) {
                              setState(() {
                                salsas.add(salsaCtrl.text.trim());
                                salsaCtrl.clear();
                              });
                            }
                          },
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    SwitchListTile(
                      title: const Text('Disponible'),
                      value: disponible,
                      onChanged: (v) => setState(() => disponible = v),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final nuevoProducto = Product(
                  id: productoExistente?.id ?? '',
                  nombre: nombreCtrl.text,
                  categoria: categoriaCtrl.text,
                  precio: double.tryParse(precioCtrl.text) ?? 0.0,
                  descripcion: descripcionCtrl.text,
                  imagenUrl: imagenCtrl.text,
                  disponible: disponible,
                  tieneMediaOrden: tieneMediaOrden,
                  precioMediaOrden: double.tryParse(precioMediaCtrl.text),
                  salsas: salsas,
                );

                if (productoExistente == null) {
                  await _productService.addProduct(nuevoProducto);
                } else {
                  await _productService.updateProduct(nuevoProducto);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrador de Productos'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final productos = snapshot.data!;
          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final p = productos[index];
              return ListTile(
                title: Text(p.nombre),
                subtitle: Text('\$${p.precio.toStringAsFixed(2)} - ${p.categoria}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _mostrarDialogoProducto(productoExistente: p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async => await _productService.deleteProduct(p.id),
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
        onPressed: () => _mostrarDialogoProducto(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
