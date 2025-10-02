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

  Future<void> _crearProducto() async {
    final nombre = _nombre.text.trim();
    final precio = double.tryParse(_precio.text.trim()) ?? 0;
    final categoria = _categoria.text.trim();
    if (nombre.isEmpty || categoria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa nombre y categoría')));
      return;
    }
    await FirebaseFirestore.instance.collection('productos').add({
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'disponible': _disponible,
    });
    _nombre.clear(); _precio.clear(); _categoria.clear();
  }

  Future<void> _borrarProducto(String id) => FirebaseFirestore.instance.collection('productos').doc(id).delete();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Productos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              TextField(controller: _nombre, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: _precio, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
              TextField(controller: _categoria, decoration: const InputDecoration(labelText: 'Categoría')), 
              Row(children: [
                const Text('Disponible'),
                Switch(value: _disponible, onChanged: (v) => setState(() => _disponible = v)),
                const Spacer(),
                ElevatedButton(onPressed: _crearProducto, child: const Text('Guardar')),
              ]),
            ]),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('productos').orderBy('categoria').snapshots(),
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
                      subtitle: Text('${d['categoria'] ?? ''} - \$${(d['precio'] ?? 0).toString()}'),
                      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _borrarProducto(d.id)),
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
