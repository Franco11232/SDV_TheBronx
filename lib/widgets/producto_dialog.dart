import 'package:flutter/material.dart';
import '/models/product.dart';
import '/models/categoria.dart';
import '/models/salsa.dart';

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
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _precioMediaController;
  late TextEditingController _descripcionController;
  late TextEditingController _imagenController;

  late bool _disponible;
  late bool _tieneMediaOrden;
  String? _categoriaSeleccionada;
  List<String> _salsasSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _precioController = TextEditingController(text: p?.precio.toString() ?? '');
    _precioMediaController =
        TextEditingController(text: p?.precioMediaOrden?.toString() ?? '');
    _descripcionController = TextEditingController(text: p?.descripcion ?? '');
    _imagenController = TextEditingController(text: p?.imagenUrl ?? '');
    _disponible = p?.disponible ?? true;
    _tieneMediaOrden = p?.tieneMediaOrden ?? false;
    _categoriaSeleccionada = p?.categoria;
    _salsasSeleccionadas = List<String>.from(p?.salsas ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Agregar Producto' : 'Editar Producto'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
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
                  value: _categoriaSeleccionada ?? categorias.first.nombre,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: categorias
                      .map((c) =>
                      DropdownMenuItem(value: c.nombre, child: Text(c.nombre)))
                      .toList(),
                  onChanged: (val) => setState(() => _categoriaSeleccionada = val),
                );
              },
            ),
            const SizedBox(height: 15),
            SwitchListTile(
              title: const Text('Disponible'),
              value: _disponible,
              activeColor: Colors.green,
              onChanged: (v) => setState(() => _disponible = v),
            ),
            const Divider(),
            CheckboxListTile(
              title: const Text('Tiene media orden'),
              value: _tieneMediaOrden,
              onChanged: (v) => setState(() => _tieneMediaOrden = v ?? false),
            ),
            if (_tieneMediaOrden)
              TextField(
                controller: _precioMediaController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Precio media orden'),
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
                        final sel = _salsasSeleccionadas.contains(s.nombre);
                        return FilterChip(
                          label: Text(s.nombre),
                          selected: sel,
                          selectedColor: Colors.green,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _salsasSeleccionadas.add(s.nombre);
                              } else {
                                _salsasSeleccionadas.remove(s.nombre);
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
            final producto = Product(
              id: widget.product?.id ?? '',
              nombre: _nombreController.text.trim(),
              precio: double.tryParse(_precioController.text) ?? 0.0,
              categoria: _categoriaSeleccionada ?? '',
              descripcion: _descripcionController.text.trim(),
              imagenUrl: _imagenController.text.trim(),
              disponible: _disponible,
              tieneMediaOrden: _tieneMediaOrden,
              precioMediaOrden:
              _tieneMediaOrden ? double.tryParse(_precioMediaController.text) : null,
              salsas: _salsasSeleccionadas,
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
