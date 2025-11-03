import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/salsa.dart';
import '../providers/almacen_provider.dart';

class SalsaDialog extends StatefulWidget {
  final Salsa? salsa;
  const SalsaDialog({super.key, this.salsa});
  @override
  State<SalsaDialog> createState() => _SalsaDialogState();
}

class _SalsaDialogState extends State<SalsaDialog> {
  final _nombreCtrl = TextEditingController();
  bool _disponible = true;

  @override
  void initState() {
    super.initState();
    if (widget.salsa != null) {
      _nombreCtrl.text = widget.salsa!.nombre;
      _disponible = widget.salsa!.disponible;
    }
  }

  @override
  Widget build(BuildContext context) {
    final almacen = Provider.of<AlmacenProvider>(context, listen: false);
    return AlertDialog(
      title: Text(widget.salsa == null ? 'Nueva salsa' : 'Editar salsa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
          SwitchListTile(title: const Text('Disponible'), value: _disponible, onChanged: (v) => setState(() => _disponible = v)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            final nombre = _nombreCtrl.text.trim();
            if (nombre.isEmpty) return;
            final s = Salsa(id: widget.salsa?.id ?? '', nombre: nombre, disponible: _disponible);
            if (widget.salsa == null) await almacen.agregarSalsa(s);
            else await almacen.actualizarSalsa(s);
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        )
      ],
    );
  }
}
