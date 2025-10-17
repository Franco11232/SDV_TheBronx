// lib/screens/cajero/nueva_comanda_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/comanda.dart';
import '../../models/item_comanda.dart';

class NuevaComandaScreen extends StatefulWidget {
  final List<ItemComanda> productosSeleccionados;

  const NuevaComandaScreen({super.key, required this.productosSeleccionados});

  @override
  State<NuevaComandaScreen> createState() => _NuevaComandaScreenState();
}

class _NuevaComandaScreenState extends State<NuevaComandaScreen> {
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  String _tipo = 'Para llevar';
  bool _guardando = false;

  double get total =>
      widget.productosSeleccionados.fold(0, (sum, p) => sum + p.subTotal);

  Future<void> _guardarComanda() async {
    if (_nombreCtrl.text.isEmpty || _telefonoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese nombre y teléfono del cliente')),
      );
      return;
    }

    if (_tipo == 'Domicilio' && _direccionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese la dirección para domicilio')),
      );
      return;
    }

    setState(() => _guardando = true);

    final nueva = Comanda(
      id: null,
      clientName: _nombreCtrl.text.trim(),
      clientPhone: _telefonoCtrl.text.trim(),
      type: _tipo,
      address: _tipo == 'Domicilio' ? _direccionCtrl.text.trim() : '',
      estado: 'pendiente',
      payment: {'estado': 'pendiente', 'metodo': 'efectivo'},
      date: DateTime.now(),
      total: total,
      details: widget.productosSeleccionados,
    );

    try {
      await FirebaseFirestore.instance
          .collection('comandas')
          .add(nueva.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comanda creada correctamente')),
      );
      Navigator.pop(context, true); // volver con éxito
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear comanda: $e')),
      );
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Comanda')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del cliente'),
            ),
            TextField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            DropdownButtonFormField<String>(
              value: _tipo,
              items: const [
                DropdownMenuItem(value: 'Para llevar', child: Text('Para llevar')),
                DropdownMenuItem(value: 'Domicilio', child: Text('Domicilio')),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? 'Para llevar'),
              decoration: const InputDecoration(labelText: 'Tipo de comanda'),
            ),
            if (_tipo == 'Domicilio')
              TextField(
                controller: _direccionCtrl,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.productosSeleccionados.length,
                itemBuilder: (_, i) {
                  final p = widget.productosSeleccionados[i];
                  return ListTile(
                    title: Text(p.nombre),
                    subtitle: Text(
                        '${p.cantidad} x \$${p.priceUnit.toStringAsFixed(2)} = \$${p.subTotal.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(),
            Text('Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar Comanda'),
              onPressed: _guardando ? null : _guardarComanda,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
