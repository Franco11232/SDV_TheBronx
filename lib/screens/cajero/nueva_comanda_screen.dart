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
  final _calleCtrl = TextEditingController();
  final _colCtrl = TextEditingController();

  String _tipo = 'Para llevar';
  bool _guardando = false;

  // 🔢 Cálculo total dinámico
  double get total =>
      widget.productosSeleccionados.fold(0, (sum, p) => sum + p.subTotal);

  Future<void> _guardarComanda() async {
    if (_nombreCtrl.text.isEmpty || _telefonoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese nombre y teléfono del cliente')),
      );
      return;
    }

    if (_tipo == 'Domicilio' &&
        (_calleCtrl.text.isEmpty || _colCtrl.text.isEmpty)) {
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
      address: _tipo == 'Domicilio' ? _calleCtrl.text.trim() : '',
      addressCol: _tipo == 'Domicilio' ? _colCtrl.text.trim() : '',
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
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear comanda: $e')),
      );
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _calleCtrl.dispose();
    _colCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Comanda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧍 Datos del cliente
            TextField(
              controller: _nombreCtrl,
              decoration:
              const InputDecoration(labelText: 'Nombre del cliente'),
            ),
            TextField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _tipo,
              items: const [
                DropdownMenuItem(
                    value: 'Para llevar', child: Text('Para llevar')),
                DropdownMenuItem(
                    value: 'Domicilio', child: Text('Domicilio')),
                DropdownMenuItem(
                    value: 'Comer aqui', child: Text('Comer aquí')),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? 'Para llevar'),
              decoration: const InputDecoration(labelText: 'Tipo de comanda'),
            ),
            if (_tipo == 'Domicilio') ...[
              TextField(
                controller: _calleCtrl,
                decoration: const InputDecoration(labelText: 'Calle'),
              ),
              TextField(
                controller: _colCtrl,
                decoration: const InputDecoration(labelText: 'Colonia'),
              ),
            ],
            const SizedBox(height: 10),
            const Divider(),

            // 🧾 Lista de productos
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.productosSeleccionados.length,
              itemBuilder: (context, index) {
                final item = widget.productosSeleccionados[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.fastfood, color: Colors.brown),
                    title: Text(
                      item.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad: ${item.cantidad}'),
                        Text(
                            'Precio unitario: \$${item.priceUnit.toStringAsFixed(2)}'),
                        if (item.llevaMediaOrdenBones)
                          Text(
                            '➕ Media orden de Bones (+\$${item.precioMediaOrden?.toStringAsFixed(2) ?? "75.00"})',
                            style: const TextStyle(color: Colors.brown),
                          ),
                        if (item.salsaSeleccionada != null &&
                            item.salsaSeleccionada!.isNotEmpty)
                          Text('Salsa: ${item.salsaSeleccionada}'),
                      ],
                    ),
                    trailing: Text(
                      '\$${item.subTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16),
                    ),
                  ),
                );
              },
            ),
            const Divider(),

            // 💰 Total
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
            ),

            // 💾 Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_guardando
                    ? 'Guardando...'
                    : 'Guardar Comanda'),
                onPressed: _guardando ? null : _guardarComanda,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
