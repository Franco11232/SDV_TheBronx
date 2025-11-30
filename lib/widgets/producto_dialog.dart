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
  // Corregido: controladores para los campos del modelo Product
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _salsaMediaBonelessController;

  late bool _disponible;
  late bool _tieneMediaBoneless;
  String? _categorySeleccionado;
  List<String> _salsasDisponiblesSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    // Corregido: usar 'name' en lugar de 'nombre'
    _nameController = TextEditingController(text: p?.name ?? '');
    // Corregido: usar 'price' en lugar de 'precio'
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    // Corregido: añadir 'stock'
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    // Corregido: usar 'salsaMediaBoneless' en lugar de 'precioMediaOrden'
    _salsaMediaBonelessController =
        TextEditingController(text: p?.salsaMediaBoneless ?? '');

    _disponible = p?.disponible ?? true;
    // Corregido: usar 'tieneMediaBoneless' en lugar de 'tieneMediaOrden'
    _tieneMediaBoneless = p?.tieneMediaBoneless ?? false;
    // Corregido: usar 'category' en lugar de 'categoria'
    _categorySeleccionado = p?.category;
    // Corregido: usar 'salsasDisponibles' en lugar de 'salsas'
    _salsasDisponiblesSeleccionadas =
        List<String>.from(p?.salsasDisponibles ?? []);
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
              // Corregido: usar _nameController
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              // Corregido: usar _priceController
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            const SizedBox(height: 10),
            // Corregido: añadir campo para stock
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
                if (categorias.isEmpty) {
                  return const Text('No hay categorías disponibles');
                }
                return DropdownButtonFormField<String>(
                  // Corregido: usar _categorySeleccionado
                  value: _categorySeleccionado,
                  hint: const Text('Seleccione una categoría'),
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: categorias
                      .map((c) =>
                          DropdownMenuItem(value: c.nombre, child: Text(c.nombre)))
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
            // Corregido: Texto y valor para media orden de boneless
            CheckboxListTile(
              title: const Text('Tiene media orden de boneless'),
              value: _tieneMediaBoneless,
              onChanged: (v) => setState(() => _tieneMediaBoneless = v ?? false),
            ),
            // Corregido: campo para la salsa de la media orden
            if (_tieneMediaBoneless)
              TextField(
                controller: _salsaMediaBonelessController,
                decoration:
                    const InputDecoration(labelText: 'Salsa para media orden'),
              ),
            const Divider(),
            StreamBuilder<List<Salsa>>(
              stream: widget.salsasStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final salsas = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Salsas disponibles:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: salsas.map((s) {
                        // Corregido: usar _salsasDisponiblesSeleccionadas
                        final sel =
                            _salsasDisponiblesSeleccionadas.contains(s.nombre);
                        return FilterChip(
                          label: Text(s.nombre),
                          selected: sel,
                          selectedColor: Colors.green,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                // Corregido: usar _salsasDisponiblesSeleccionadas
                                _salsasDisponiblesSeleccionadas.add(s.nombre);
                              } else {
                                // Corregido: usar _salsasDisponiblesSeleccionadas
                                _salsasDisponiblesSeleccionadas.remove(s.nombre);
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
            // Corregido: construcción del objeto Product con los campos correctos
            final producto = Product(
              id: widget.product?.id ?? '',
              name: _nameController.text.trim(),
              price: double.tryParse(_priceController.text) ?? 0.0,
              stock: double.tryParse(_stockController.text) ?? 0.0,
              category: _categorySeleccionado ?? '',
              disponible: _disponible,
              tieneMediaBoneless: _tieneMediaBoneless,
              salsaMediaBoneless: _tieneMediaBoneless
                  ? _salsaMediaBonelessController.text
                  : null,
              salsasDisponibles: _salsasDisponiblesSeleccionadas,
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
