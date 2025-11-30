import 'package:flutter/material.dart';
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
    final TextEditingController nombreCtrl = TextEditingController(text: productoExistente?.name ?? '');
    final TextEditingController categoriaCtrl = TextEditingController(text: productoExistente?.category ?? '');
    final TextEditingController precioCtrl = TextEditingController(
        text: productoExistente?.price != null ? productoExistente!.price.toString() : '');
    // Corregido: añadido controlador para stock
    final TextEditingController stockCtrl = TextEditingController(
        text: productoExistente?.stock != null ? productoExistente!.stock.toString() : '');
    // Corregido: añadido controlador para salsaMediaBoneless
    final TextEditingController salsaMediaBonelessCtrl =
    TextEditingController(text: productoExistente?.salsaMediaBoneless ?? '');
    final TextEditingController salsaCtrl = TextEditingController();

    bool disponible = productoExistente?.disponible ?? true;
    // Corregido: renombrado a tieneMediaBoneless
    bool tieneMediaBoneless = productoExistente?.tieneMediaBoneless ?? false;
    // Corregido: renombrado a salsasDisponibles
    List<String> salsasDisponibles = List<String>.from(productoExistente?.salsasDisponibles ?? []);

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
                    // Corregido: añadido textfield para stock
                    TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock (Kg/U.)'),
                    ),
                    const SizedBox(height: 10),

                    // Corregido: Checkbox para media orden de boneless
                    CheckboxListTile(
                      title: const Text('Tiene media orden de boneless'),
                      value: tieneMediaBoneless,
                      onChanged: (v) => setState(() => tieneMediaBoneless = v ?? false),
                    ),

                    // Corregido: campo para la salsa de la media orden
                    if (tieneMediaBoneless)
                      TextField(
                        controller: salsaMediaBonelessCtrl,
                        decoration: const InputDecoration(labelText: 'Salsa para media orden'),
                      ),

                    const SizedBox(height: 10),

                    // Corregido: Lista de salsas
                    const Text('Salsas disponibles', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 6,
                      children: salsasDisponibles
                          .map((s) => Chip(
                        label: Text(s),
                        onDeleted: () => setState(() => salsasDisponibles.remove(s)),
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
                                salsasDisponibles.add(salsaCtrl.text.trim());
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
              onPressed:() async {
                // Corregido: llamada al constructor Product con los campos correctos
                final nuevoProducto = Product(
                  id: productoExistente?.id ?? '',
                  name: nombreCtrl.text,
                  category: categoriaCtrl.text,
                  price: double.tryParse(precioCtrl.text) ?? 0.0,
                  stock: double.tryParse(stockCtrl.text) ?? 0.0,
                  disponible: disponible,
                  tieneMediaBoneless: tieneMediaBoneless,
                  salsaMediaBoneless: tieneMediaBoneless ? salsaMediaBonelessCtrl.text : null,
                  salsasDisponibles: salsasDisponibles,
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
                title: Text(p.name),
                subtitle: Text('\$${p.price.toStringAsFixed(2)} - ${p.category}'),
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
