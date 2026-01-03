import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/categoria.dart';
import '../../models/product.dart';
import '../../models/salsa.dart';
import '../../services/product_service.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final ProductService _productService = ProductService();

  Stream<List<Categoria>> get categoriasStream => _productService.getCategorias();
  Stream<List<Salsa>> get salsasStream => _productService.getSalsas();

  // ✅ Diálogo genérico para gestionar (crear/eliminar) Categorías y Salsas
  void _showManageItemsDialog({
    required String title,
    required Stream<List<dynamic>> stream,
    required Function(String) onAdd,
    required Function(String) onDelete,
  }) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: const InputDecoration(labelText: 'Nuevo nombre...'),
                      autofocus: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        onAdd(textController.text.trim());
                        textController.clear();
                      }
                    },
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<List<dynamic>>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final items = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onDelete(item.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _mostrarDialogoProducto({Product? productoExistente}) {
    final nombreCtrl = TextEditingController(text: productoExistente?.name ?? '');
    final precioCtrl = TextEditingController(text: productoExistente?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: productoExistente?.stock.toString() ?? '');

    String? categoriaSeleccionada = productoExistente?.category;
    bool disponible = productoExistente?.disponible ?? true;
    bool tieneMediaBoneless = productoExistente?.tieneMediaBoneless ?? false;
    bool acceptsSauce = productoExistente?.acceptsSauce ?? false;
    List<String> salsasParaProducto = List<String>.from(productoExistente?.salsasDisponibles ?? []);

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
                    TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                    const SizedBox(height: 10),
                    StreamBuilder<List<Categoria>>(
                      stream: categoriasStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final categorias = snapshot.data!;
                        final uniqueCategoryNames = categorias.map((c) => c.name).toSet().toList();
                        if (categoriaSeleccionada != null && !uniqueCategoryNames.contains(categoriaSeleccionada)) {
                          categoriaSeleccionada = null;
                        }
                        return DropdownButtonFormField<String>(
                          value: categoriaSeleccionada,
                          hint: const Text('Seleccionar categoría'),
                          items: uniqueCategoryNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                          onChanged: (val) => setState(() => categoriaSeleccionada = val),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: precioCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio')),
                    TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock (Kg/U.)')),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text('Tiene media orden de boneless'),
                      value: tieneMediaBoneless,
                      onChanged: (v) => setState(() => tieneMediaBoneless = v ?? false),
                    ),
                    const Divider(),
                    CheckboxListTile(
                      title: const Text('Este producto puede llevar salsa'),
                      value: acceptsSauce,
                      onChanged: (v) => setState(() => acceptsSauce = v ?? false),
                    ),
                    if (acceptsSauce)
                      StreamBuilder<List<Salsa>>(
                        stream: salsasStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          final allSalsas = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Salsas aplicables a este producto:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Wrap(
                                spacing: 8,
                                children: allSalsas.map((salsa) {
                                  final isSelected = salsasParaProducto.contains(salsa.name);
                                  return FilterChip(
                                    label: Text(salsa.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          salsasParaProducto.add(salsa.name);
                                        } else {
                                          salsasParaProducto.remove(salsa.name);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
                    const Divider(),
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
                  name: nombreCtrl.text,
                  category: categoriaSeleccionada ?? '',
                  price: double.tryParse(precioCtrl.text) ?? 0.0,
                  stock: double.tryParse(stockCtrl.text) ?? 0.0,
                  disponible: disponible,
                  tieneMediaBoneless: tieneMediaBoneless,
                  acceptsSauce: acceptsSauce,
                  salsasDisponibles: acceptsSauce ? salsasParaProducto : [],
                );

                if (productoExistente == null) {
                  await _productService.addProduct(nuevoProducto);
                } else {
                  await _productService.updateProduct(nuevoProducto);
                }

                if (mounted) Navigator.pop(context);
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
      body: Column(
        children: [
          // ✅ Botones para gestionar categorías y salsas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.category, size: 18),
                  label: const Text('Categorías'),
                  onPressed: () {
                    _showManageItemsDialog(
                      title: 'Gestionar Categorías',
                      stream: categoriasStream.cast<List<dynamic>>(),
                      onAdd: (name) => _productService.addCategoria(Categoria(id: '', name: name)),
                      onDelete: (id) => _productService.deleteCategoria(id),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.local_fire_department, size: 18),
                  label: const Text('Salsas'),
                  onPressed: () {
                    _showManageItemsDialog(
                      title: 'Gestionar Salsas',
                      stream: salsasStream.cast<List<dynamic>>(),
                      onAdd: (name) => _productService.addSalsa(Salsa(id: '', name: name)),
                      onDelete: (id) => _productService.deleteSalsa(id),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // ✅ Lista de productos
          Expanded(
            child: StreamBuilder<List<Product>>(
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _mostrarDialogoProducto(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
