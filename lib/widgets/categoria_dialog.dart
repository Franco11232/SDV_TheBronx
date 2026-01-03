import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categoria.dart';
import '../providers/almacen_provider.dart';

class CategoriaDialog extends StatefulWidget {
  const CategoriaDialog({super.key});
  @override
  State<CategoriaDialog> createState() => _CategoriaDialogState();
}

class _CategoriaDialogState extends State<CategoriaDialog> {
  final _nombreCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final almacen = Provider.of<AlmacenProvider>(context, listen: false);
    return AlertDialog(
      title: const Text('Nueva categoría'),
      content: TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            final nombre = _nombreCtrl.text.trim();
            if (nombre.isEmpty) return;
            final c = Categoria(id: '', name: nombre);
            await almacen.agregarCategoria(c);
            Navigator.pop(context);
          },
          child: const Text('Agregar'),
        )
      ],
    );
  }
}
