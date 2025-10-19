import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/almacen_provider.dart';
import '../../services/product_service.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHome> {
  final List<String> categorias = [
    'Burger',
    'Sandwich',
    'Boneless',
    'Bebida',
    'Complemento',
    'Otro'
  ];

  final List<String> salsasDisponibles = const [
    'BBQ',
    'Buffalo',
    'Mango Habanero',
    'Lemon Pepper',
    'Parmesano',
    'Chipotle'
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final almacenProvider = Provider.of<AlmacenProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Product>>(
        stream: almacenProvider.productosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar productos: ${snapshot.error}'));
          }

          final productos = snapshot.data!
              .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          final categoriasDisponibles = <String>{
            ...snapshot.data!.map((p) => p.category)
          }.toList();

          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, i) {
              final p = productos[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.category} • \$${p.price.toStringAsFixed(2)}'
                        '${p.tieneMediaBoneless ? ' • +Media Boneless' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: p.disponible,
                        onChanged: (v) async {
                          await almacenProvider.actualizarProducto(
                              p.copyWith(disponible: v));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _abrirDialogoProducto(context, producto: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await almacenProvider.eliminarProducto(p.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => _abrirDialogoProducto(context),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: "Buscar producto...",
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    );
  }

  void _abrirDialogoProducto(BuildContext context, {Product? producto}) {
    final almacenProvider = Provider.of<AlmacenProvider>(context, listen: false);

    final nombreCtrl = TextEditingController(text: producto?.name ?? '');
    final precioCtrl = TextEditingController(text: producto?.price.toString() ?? '');
    String categoriaSeleccionada = producto?.category ?? categorias.first;
    bool disponible = producto?.disponible ?? true;
    bool tieneMediaBoneless = producto?.tieneMediaBoneless ?? false;
    String? salsaMediaBoneless = producto?.salsaMediaBoneless;
    List<String> salsasSeleccionadas = List<String>.from(producto?.salsasDisponibles ?? []);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(producto == null ? 'Nuevo Producto' : 'Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: precioCtrl,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                const Text('Categoría:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Wrap(
                  spacing: 8,
                  children: categorias.map((cat) {
                    final selected = categoriaSeleccionada == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: Colors.green,
                      onSelected: (_) {
                        setState(() {
                          categoriaSeleccionada = cat;
                          tieneMediaBoneless = false;
                          salsaMediaBoneless = null;
                          salsasSeleccionadas.clear();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                if (categoriaSeleccionada == 'Burger' || categoriaSeleccionada == 'Sandwich')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Permitir media orden de boneless (+\$75)'),
                        value: tieneMediaBoneless,
                        onChanged: (v) => setState(() {
                          tieneMediaBoneless = v;
                          if (!v) salsaMediaBoneless = null;
                        }),
                      ),
                      if (tieneMediaBoneless)
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Salsa para media boneless'),
                          value: salsaMediaBoneless,
                          items: salsasDisponibles
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() => salsaMediaBoneless = v),
                        ),
                    ],
                  ),
                if (categoriaSeleccionada == 'Boneless')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Salsas disponibles:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Wrap(
                        spacing: 6,
                        children: salsasDisponibles.map((salsa) {
                          final selected = salsasSeleccionadas.contains(salsa);
                          return FilterChip(
                            label: Text(salsa),
                            selected: selected,
                            onSelected: (v) {
                              setState(() {
                                if (v) {
                                  salsasSeleccionadas.add(salsa);
                                } else {
                                  salsasSeleccionadas.remove(salsa);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Disponible'),
                  value: disponible,
                  onChanged: (v) => setState(() => disponible = v),
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
              onPressed: () async {
                final name = nombreCtrl.text.trim();
                final price = double.tryParse(precioCtrl.text.trim()) ?? 0.0;

                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese nombre y precio válidos')),
                  );
                  return;
                }

                final nuevo = Product(
                  id: producto?.id ?? '',
                  name: name,
                  price: price,
                  stock: producto?.stock ?? 0,
                  category: categoriaSeleccionada,
                  disponible: disponible,
                  tieneMediaBoneless: tieneMediaBoneless,
                  salsaMediaBoneless: salsaMediaBoneless,
                  salsasDisponibles: salsasSeleccionadas,
                );

                if (producto == null) {
                  await almacenProvider.agregarProducto(nuevo);
                } else {
                  await almacenProvider.actualizarProducto(nuevo);
                }
                Navigator.pop(context);
              },
              child: Text(producto == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
