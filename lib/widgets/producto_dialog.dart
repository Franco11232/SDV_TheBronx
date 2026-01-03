import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/categoria.dart';
import '../models/salsa.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;
  final Stream<List<Categoria>> categoriasStream;
  final Stream<List<Salsa>> salsasStream;

  const ProductDialog({
    super.key,
    this.product,
    required this.onSave,
    required this.categoriasStream,
    required this.salsasStream,
  });

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  // ✅ Estado para la nueva lógica de salsas
  late bool _disponible;
  late bool _tieneMediaBoneless;
  late bool _acceptsSauce;
  String? _categorySeleccionado;
  late List<String> _salsasParaProducto;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');

    _disponible = p?.disponible ?? true;
    _tieneMediaBoneless = p?.tieneMediaBoneless ?? false;
    _categorySeleccionado = p?.category;
    
    // ✅ Inicializar el nuevo estado para las salsas
    _acceptsSauce = p?.acceptsSauce ?? false;
    _salsasParaProducto = List<String>.from(p?.salsasDisponibles ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.product == null ? 'Agregar Producto' : 'Editar Producto'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock (Kg/Uds)'),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Categoria>>(
              stream: widget.categoriasStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final categorias = snapshot.data!;
                return DropdownButtonFormField<String>(
                  value: _categorySeleccionado,
                  hint: const Text('Seleccione una categoría'),
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: categorias
                      .map((c) =>
                          DropdownMenuItem(value: c.name, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _categorySeleccionado = val),
                );
              },
            ),
            const SizedBox(height: 15),
            SwitchListTile(
              title: const Text('Disponible'),
              value: _disponible,
              activeThumbColor: Colors.green,
              onChanged: (v) => setState(() => _disponible = v),
            ),
            const Divider(),
            CheckboxListTile(
              title: const Text('Tiene media orden de boneless (+costo)'),
              value: _tieneMediaBoneless,
              onChanged: (v) => setState(() => _tieneMediaBoneless = v ?? false),
            ),
            const Divider(),

            // ✅ Corregido: Checkbox para habilitar la selección de salsas
            CheckboxListTile(
              title: const Text('Este producto puede llevar salsa'),
              value: _acceptsSauce,
              onChanged: (v) => setState(() => _acceptsSauce = v ?? false),
            ),

            // ✅ Si el producto acepta salsa, se muestra la lista de salsas disponibles
            if (_acceptsSauce)
              StreamBuilder<List<Salsa>>(
                stream: widget.salsasStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final allSalsas = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Salsas aplicables a este producto:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: allSalsas.map((salsa) {
                          final isSelected = _salsasParaProducto.contains(salsa.name);
                          return FilterChip(
                            label: Text(salsa.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _salsasParaProducto.add(salsa.name);
                                } else {
                                  _salsasParaProducto.remove(salsa.name);
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
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            // ✅ Corregido: Se guarda el producto con la nueva estructura de datos
            final producto = Product(
              id: widget.product?.id ?? '',
              name: _nameController.text.trim(),
              price: double.tryParse(_priceController.text) ?? 0.0,
              stock: double.tryParse(_stockController.text) ?? 0.0,
              category: _categorySeleccionado ?? '',
              disponible: _disponible,
              tieneMediaBoneless: _tieneMediaBoneless,
              acceptsSauce: _acceptsSauce,
              salsasDisponibles: _acceptsSauce ? _salsasParaProducto : [],
            );

            widget.onSave(producto);
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
