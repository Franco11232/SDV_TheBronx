import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/categoria.dart';
import '../../models/product.dart';
import '../../models/salsa.dart';
import '../../providers/comanda_provider.dart';
import 'nueva_comanda_screen.dart';

class CajeroHome extends StatefulWidget {
  const CajeroHome({super.key});

  @override
  State<CajeroHome> createState() => _CajeroHomeState();
}

class _CajeroHomeState extends State<CajeroHome> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  String _filtroCategoria = 'Todos';

  Stream<List<Product>> get productosStream => _db
      .collection('productos')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList());

  Stream<List<Categoria>> get categoriasStream => _db
      .collection('categorias')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Categoria.fromMap(d.id, d.data())).toList());

  Stream<List<Salsa>> get salsasStream => _db
      .collection('salsas')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Salsa.fromMap(d.id, d.data())).toList());

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _agregarProducto(
      Product producto, List<Salsa> salsasDisponibles) async {
    int cantidad = 1;
    bool llevaMediaOrdenBones = false;
    String? salsaSeleccionada;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Agregar ${producto.name}'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                if (producto.salsasDisponibles.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selecciona salsa:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 8,
                        children: salsasDisponibles
                            .where((s) =>
                                producto.salsasDisponibles.contains(s.name))
                            .map((s) {
                          final selected = salsaSeleccionada == s.name;
                          return ChoiceChip(
                            label: Text(s.name),
                            selected: selected,
                            selectedColor: Colors.green.shade300,
                            onSelected: (v) {
                              setState(() {
                                salsaSeleccionada = v ? s.name : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                if (producto.category.toLowerCase().contains('burger') ||
                    producto.category.toLowerCase().contains('sandwich'))
                  CheckboxListTile(
                    title:
                        const Text('Agregar media orden de Bones (+\$75.00)'),
                    value: llevaMediaOrdenBones,
                    onChanged: (v) =>
                        setState(() => llevaMediaOrdenBones = v ?? false),
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
                final provider =
                    Provider.of<ComandaProvider>(context, listen: false);

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
      body: Column(
        children: [
          // ✅ Barra de búsqueda y filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar producto...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<Categoria>>(
                  stream: categoriasStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final categorias = [Categoria(id: 'todos', name: 'Todos'), ...snapshot.data!];
                    return Wrap(
                      spacing: 8,
                      children: categorias.map((c) {
                        return ChoiceChip(
                          label: Text(c.name), // Corregido: usa c.name
                          selected: _filtroCategoria == c.name,
                          onSelected: (_) => setState(() => _filtroCategoria = c.name),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          // ✅ Lista de productos filtrada
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: productosStream,
              builder: (context, snapshotProd) {
                if (!snapshotProd.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Lógica de filtrado
                final productos = snapshotProd.data!.where((p) {
                  final coincideBusqueda = p.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());
                  final coincideCategoria =
                      _filtroCategoria == 'Todos' || p.category == _filtroCategoria;
                  return coincideBusqueda && coincideCategoria;
                }).toList();

                if (productos.isEmpty) {
                  return const Center(child: Text('No se encontraron productos'));
                }

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
                                    p.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '\$${p.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.green, fontSize: 16),
                                  ),
                                  if (p.category.isNotEmpty)
                                    Text(
                                      p.category,
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
          ),
        ],
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
