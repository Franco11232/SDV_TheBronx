import 'package:flutter/material.dart';
import 'package:svd_thebronx/models/product.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  const ProductDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductDialog> createState() => _ProductoDialogState();
}

class _ProductoDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreCtrl;
  late TextEditingController categoriaCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController precioCtrl;

  @override
  void initState() {
    super.initState();
    nombreCtrl = TextEditingController(text: widget.product?.name ?? '');
    categoriaCtrl =
        TextEditingController(text: widget.product?.category ?? '');
    stockCtrl = TextEditingController(
        text: widget.product?.stock.toString() ?? '0');
    precioCtrl = TextEditingController(
        text: widget.product?.price.toString() ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null
          ? 'Nuevo producto'
          : 'Editar producto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: categoriaCtrl,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: stockCtrl,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: precioCtrl,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final product = Product(
                id: widget.product?.id ?? '',
                name: nombreCtrl.text.trim(),
                disponible: true,
                category: categoriaCtrl.text.trim(),
                stock: int.tryParse(stockCtrl.text) ?? 0,
                price: double.tryParse(precioCtrl.text) ?? 0,
              );
              widget.onSave(product);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
