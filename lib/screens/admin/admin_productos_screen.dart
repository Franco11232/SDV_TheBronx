import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProductosScreen extends StatefulWidget {
  const AdminProductosScreen({super.key});

  @override
  State<AdminProductosScreen> createState() => _AdminProductosScreenState();
}

class _AdminProductosScreenState extends State<AdminProductosScreen> {
  final _nombre = TextEditingController();
  final _precio = TextEditingController();
  final _categoria = TextEditingController();
  bool _disponible = true;
  bool _permiteBoneless = false;
  final List<String> _salsas = [];
  final _nuevaSalsaCtrl = TextEditingController();

  Future<void> _crearProducto() async {
    final nombre = _nombre.text.trim();
    final precio = double.tryParse(_precio.text.trim()) ?? 0;
    final categoria = _categoria.text.trim();

    if (nombre.isEmpty || categoria.isEmpty || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre, categoría y precio válido')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('productos').add({
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'disponible': _disponible,
      'permiteBoneless': _permiteBoneless,
      'salsasDisponibles': _salsas,
    });

    _nombre.clear();
    _precio.clear();
    _categoria.clear();
    _permiteBoneless = false;
    _salsas.clear();
    setState(() {});
  }

  Future<void> _borrarProducto(String id) async {
    await FirebaseFirestore.instance.collection('productos').doc(id).delete();
  }

  void _agregarSalsa() {
    final s = _nuevaSalsaCtrl.text.trim();
    if (s.isNotEmpty && !_salsas.contains(s)) {
      _salsas.add(s);
      _nuevaSalsaCtrl.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Productos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: _nombre, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: _precio, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
                TextField(controller: _categoria, decoration: const InputDecoration(labelText: 'Categoría')),
                Row(
                  children: [
                    const Text('Disponible'),
                    Switch(value: _disponible, onChanged: (v) => setState(() => _disponible = v)),
                    const Spacer(),
                    ElevatedButton(onPressed: _crearProducto, child: const Text('Guardar')),
                  ],
                ),
                Row(
                  children: [
                    const Text('Permite media orden Boneless'),
                    Switch(value: _permiteBoneless, onChanged: (v) => setState(() => _permiteBoneless = v)),
                  ],
                ),
                if (_categoria.text.toLowerCase() == 'boneless') ...[
                  const SizedBox(height: 8),
                  const Text('Salsas disponibles:'),
                  Wrap(
                    spacing: 6,
                    children: _salsas.map((s) => Chip(
                      label: Text(s),
                      onDeleted: () {
                        _salsas.remove(s);
                        setState(() {});
                      },
                    )).toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nuevaSalsaCtrl,
                          decoration: const InputDecoration(labelText: 'Nueva salsa'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _agregarSalsa,
                      )
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('productos')
                  .orderBy('categoria')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i];
                    return ListTile(
                      leading: const Icon(Icons.fastfood),
                      title: Text(d['nombre'] ?? ''),
                      subtitle: Text('${d['categoria']} - \$${d['precio']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _borrarProducto(d.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
