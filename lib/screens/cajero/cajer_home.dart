import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/salsa.dart';
import '../../models/item_comanda.dart';
import '../../providers/comanda_provider.dart';
import 'nueva_comanda_screen.dart';

class CajeroHome extends StatefulWidget {
  const CajeroHome({super.key});

  @override
  State<CajeroHome> createState() => _CajeroHomeState();
}

class _CajeroHomeState extends State<CajeroHome> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> get productosStream => _db
      .collection('productos')
      .snapshots()
      .map((snap) => snap.docs
      .map((d) => Product.fromMap(d.id, d.data() as Map<String, dynamic>))
      .toList());

  Stream<List<Salsa>> get salsasStream => _db
      .collection('salsas')
      .snapshots()
      .map((snap) => snap.docs
      .map((d) => Salsa.fromMap(d.id, d.data() as Map<String, dynamic>))
      .toList());

  Future<void> _agregarProducto(Product producto, List<Salsa> salsasDisponibles) async {
    int cantidad = 1;
    bool llevaMediaOrdenBones = false;
    String? salsaSeleccionada;
    const double precioMediaOrden = 75.0;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Agregar ${producto.nombre}'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Cantidad
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (cantidad > 1) setState(() => cantidad--);
                      },
                    ),
                    Text('$cantidad', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => cantidad++),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 🔹 Selección de salsa (si el producto tiene salsas)
                if (producto.salsas.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selecciona salsa:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 8,
                        children: salsasDisponibles
                            .where((s) => producto.salsas.contains(s.nombre))
                            .map((s) {
                          final selected = salsaSeleccionada == s.nombre;
                          return ChoiceChip(
                            label: Text(s.nombre),
                            selected: selected,
                            selectedColor: Colors.green.shade300,
                            onSelected: (v) {
                              setState(() {
                                salsaSeleccionada = v ? s.nombre : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                // 🔹 Media orden de Bones (solo si aplica)
                if (producto.categoria.toLowerCase().contains('burger') ||
                    producto.categoria.toLowerCase().contains('sandwich'))
                  CheckboxListTile(
                    title: const Text('Agregar media orden de Bones (+\$75.00)'),
                    value: llevaMediaOrdenBones,
                    onChanged: (v) => setState(() => llevaMediaOrdenBones = v ?? false),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                final provider = Provider.of<ComandaProvider>(context, listen: false);

                for (int i = 0; i < cantidad; i++) {
                  provider.agregarProducto(
                    producto,
                    esMediaOrden: llevaMediaOrdenBones,
                    salsa: salsaSeleccionada,
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _finalizarComanda() async {
    final provider = Provider.of<ComandaProvider>(context, listen: false);
    if (provider.productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un producto')),
      );
      return;
    }

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NuevaComandaScreen(
          productosSeleccionados: provider.productos,
        ),
      ),
    );

    if (resultado == true) provider.limpiarComanda();
  }

  @override
  Widget build(BuildContext context) {
    final comandaProvider = Provider.of<ComandaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cajero - Selección de Productos'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: _finalizarComanda,
          )
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: productosStream,
        builder: (context, snapshotProd) {
          if (!snapshotProd.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final productos = snapshotProd.data!;
          return StreamBuilder<List<Salsa>>(
            stream: salsasStream,
            builder: (context, snapshotSalsas) {
              if (!snapshotSalsas.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final salsas = snapshotSalsas.data!;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final p = productos[index];
                  return GestureDetector(
                    onTap: () => _agregarProducto(p, salsas),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p.nombre,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '\$${p.precio.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 16),
                            ),
                            if (p.categoria.isNotEmpty)
                              Text(
                                p.categoria,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: comandaProvider.productos.isNotEmpty
          ? FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: _finalizarComanda,
        icon: const Icon(Icons.check),
        label: const Text('Finalizar'),
      )
          : null,
    );
  }
}
