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

  // Corregido: El valor inicial de fold debe ser 0.0 para que el resultado sea double.
  double get total =>
      widget.productosSeleccionados.fold(0.0, (sum, p) => sum + p.subTotal);

  Future<void> _guardarComanda() async {
    if (_nombreCtrl.text.trim().isEmpty || _telefonoCtrl.text.trim().isEmpty) {
       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese nombre y teléfono del cliente')),
      );
      return;
    }

    if (_tipo == 'Domicilio' &&
        (_calleCtrl.text.trim().isEmpty || _colCtrl.text.trim().isEmpty)) {
      if (!mounted) return;
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

      if (!mounted) return; // ✅ Check if widget is still in the tree
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Comanda creada correctamente')),
      );

      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return; // ✅ Check if widget is still in the tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al crear comanda: $e')),
      );
    } finally {
      if(mounted) setState(() => _guardando = false); // ✅ Check if mounted
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
                DropdownMenuItem(value: 'Comer aqui', child: Text('Comer aquí')),
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
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.productosSeleccionados.length,
                itemBuilder: (context, index) {
                  final item = widget.productosSeleccionados[index];
                  return _buildProductoCard(item, index);
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar Comanda'),
              onPressed: _guardando ? null : _guardarComanda,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoCard(ItemComanda item, int index) {
    const List<String> salsasDisponibles = [
      'BBQ',
      'Buffalo',
      'Mango Habanero',
      'Lemon Pepper',
      'Parmesano',
      'Chipotle',
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Cantidad: ${item.cantidad}'),
            Text('Precio unitario: \$${item.priceUnit.toStringAsFixed(2)}'),

            // ✅ Media orden Boneless
            Row(
              children: [
                Checkbox(
                  value: item.llevaMediaOrdenBones,
                  onChanged: (v) {
                    // Corregido: Se crea una copia del item con los nuevos valores
                    setState(() {
                      final bool newLlevaMedia = v ?? false;
                      final base = item.priceUnit * item.cantidad;
                      final extra = newLlevaMedia ? 75.0 : 0.0;
                      
                      final newItem = item.copyWith(
                        llevaMediaOrdenBones: newLlevaMedia,
                        subTotal: base + extra,
                        precioMediaOrden: newLlevaMedia ? 75.0 : null, // Actualizar precio media orden
                      );
                      widget.productosSeleccionados[index] = newItem;
                    });
                  },
                ),
                const Text('Agregar media orden de Boneless (+\$75)'),
              ],
            ),

            // ✅ Selector de salsas
            DropdownButtonFormField<String>(
              value: (item.salsasSeleccionadas?.isNotEmpty ?? false)
                  ? item.salsasSeleccionadas!.first
                  : null,
              hint: const Text('Seleccionar salsa'),
              items: salsasDisponibles
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                 // Corregido: Se crea una copia del item con la nueva salsa
                setState(() {
                  final newItem = item.copyWith(
                    salsasSeleccionadas: v != null ? [v] : [],
                  );
                  widget.productosSeleccionados[index] = newItem;
                });
              },
            ),

            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Subtotal: \$${item.subTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
