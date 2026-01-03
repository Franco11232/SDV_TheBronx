import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/comanda.dart';
import '../../models/item_comanda.dart';
import '../../models/product.dart';
import '../../models/salsa.dart';

class NuevaComandaScreen extends StatefulWidget {
  final Comanda? comanda;
  final List<ItemComanda>? productosSeleccionados;

  const NuevaComandaScreen({super.key, this.comanda, this.productosSeleccionados});

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

  late List<ItemComanda> _items;
  bool get _isEditing => widget.comanda != null;

  late Future<void> _dataFuture;
  List<Product> _allProducts = [];
  List<Salsa> _allSalsas = [];

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadInitialData();

    if (_isEditing) {
      final c = widget.comanda!;
      _nombreCtrl.text = c.clientName;
      _telefonoCtrl.text = c.clientPhone;
      _calleCtrl.text = c.address;
      _colCtrl.text = c.addressCol;
      _tipo = c.type;
      _items = List<ItemComanda>.from(c.details);
    } else {
      _items = List<ItemComanda>.from(widget.productosSeleccionados ?? []);
    }
  }

  Future<void> _loadInitialData() async {
    final productsSnapshot = await FirebaseFirestore.instance.collection('productos').get();
    _allProducts = productsSnapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList();

    final salsasSnapshot = await FirebaseFirestore.instance.collection('salsas').get();
    _allSalsas = salsasSnapshot.docs.map((doc) => Salsa.fromMap(doc.id, doc.data())).toList();
  }

  double get total => _items.fold(0.0, (sum, p) => sum + p.subTotal);

  Future<void> _guardarComanda() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos en la comanda')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      if (_isEditing) {
        final comandaActualizada = widget.comanda!.copyWith(
          clientName: _nombreCtrl.text.trim(),
          clientPhone: _telefonoCtrl.text.trim(),
          type: _tipo,
          address: _tipo == 'Domicilio' ? _calleCtrl.text.trim() : '',
          addressCol: _tipo == 'Domicilio' ? _colCtrl.text.trim() : '',
          total: total,
          details: _items,
        );
        await FirebaseFirestore.instance
            .collection('comandas')
            .doc(comandaActualizada.id)
            .update(comandaActualizada.toMap());
      } else {
        final nueva = Comanda(
          clientName: _nombreCtrl.text.trim(),
          clientPhone: _telefonoCtrl.text.trim(),
          type: _tipo,
          address: _tipo == 'Domicilio' ? _calleCtrl.text.trim() : '',
          addressCol: _tipo == 'Domicilio' ? _colCtrl.text.trim() : '',
          estado: 'pendiente',
          payment: {'estado': 'pendiente', 'metodo': 'efectivo'},
          date: DateTime.now(),
          total: total,
          details: _items,
        );
        await FirebaseFirestore.instance.collection('comandas').add(nueva.toMap());
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Comanda ${_isEditing ? 'actualizada' : 'creada'} correctamente')),
      );
      Navigator.pop(context, true);

    } catch (e) {
       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar comanda: $e')),
      );
    } finally {
      if(mounted) setState(() => _guardando = false);
    }
  }
  
  Future<void> _showAddProductDialog() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Añadir Producto'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _allProducts.length,
              itemBuilder: (context, index) {
                final product = _allProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _configureAndAddNewItem(product);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        );
      },
    );
  }

  void _configureAndAddNewItem(Product product) {
    if (!product.acceptsSauce || product.salsasDisponibles.isEmpty) {
      setState(() {
        _items.add(ItemComanda(
          idProducto: product.id,
          nombre: product.name,
          cantidad: 1,
          priceUnit: product.price,
          subTotal: product.price,
          salsa: 'Natural',
        ));
      });
      return;
    }

    String? salsaSeleccionada = 'Natural';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Selecciona una salsa para ${product.name}'),
        content: DropdownButton<String>(
          value: salsaSeleccionada,
          isExpanded: true,
          items: [
            const DropdownMenuItem(value: 'Natural', child: Text('Natural')),
            ...product.salsasDisponibles
                .map((salsaName) => DropdownMenuItem(value: salsaName, child: Text(salsaName))),
          ],
          onChanged: (val) => salsaSeleccionada = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _items.add(ItemComanda(
                  idProducto: product.id,
                  nombre: product.name,
                  cantidad: 1,
                  priceUnit: product.price,
                  subTotal: product.price,
                  salsa: salsaSeleccionada,
                ));
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Comanda' : 'Nueva Comanda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
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
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
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
          );
        }
      ),
    );
  }

  Widget _buildProductoCard(ItemComanda item, int index) {
    final product = _allProducts.firstWhere((p) => p.id == item.idProducto, orElse: () => Product(id: '', name: 'No encontrado', price: 0, stock: 0, category: '', disponible: false));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => _items.removeAt(index)),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Cantidad:'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (item.cantidad > 1) {
                      setState(() {
                        final newItem = item.copyWith(
                          cantidad: item.cantidad - 1,
                          subTotal: (item.cantidad - 1) * item.priceUnit,
                        );
                        _items[index] = newItem;
                      });
                    }
                  },
                ),
                Text('${item.cantidad}', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      final newItem = item.copyWith(
                        cantidad: item.cantidad + 1,
                        subTotal: (item.cantidad + 1) * item.priceUnit,
                      );
                      _items[index] = newItem;
                    });
                  },
                ),
              ],
            ),
            Text('Precio unitario: \$${item.priceUnit.toStringAsFixed(2)}'),
            
            // ✅ Corregido: Lógica para la media orden y selección de salsa
            if (product.tieneMediaBoneless)
              CheckboxListTile(
                title: const Text('Agregar media orden de Boneless (+\$75)'),
                value: item.llevaMediaOrdenBones,
                onChanged: (v) async {
                  final bool isAdding = v ?? false;

                  if (!isAdding) {
                    // Si se desmarca, se revierte el precio y la salsa si es necesario
                    setState(() {
                      final newItem = item.copyWith(
                        llevaMediaOrdenBones: false,
                        priceUnit: product.price,
                        subTotal: product.price * item.cantidad,
                        salsa: product.acceptsSauce ? item.salsa : 'Natural',
                      );
                      _items[index] = newItem;
                    });
                    return;
                  }

                  // Si se marca, mostrar diálogo para elegir salsa
                  final String? selectedSauce = await showDialog<String>(
                    context: context,
                    builder: (dialogContext) {
                      String sauceInDialog = 'Natural';
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: const Text('Elige una salsa para los Boneless'),
                            content: DropdownButton<String>(
                              value: sauceInDialog,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(value: 'Natural', child: Text('Natural')),
                                ...product.salsasDisponibles.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                              ],
                              onChanged: (val) {
                                setDialogState(() {
                                  sauceInDialog = val!;
                                });
                              },
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(dialogContext, sauceInDialog),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );

                  if (selectedSauce == null) return; // Si el usuario cancela, no hacer nada

                  // Actualizar el item con la nueva información
                  setState(() {
                    final newPriceUnit = product.price + 75.0;
                    final newItem = item.copyWith(
                      llevaMediaOrdenBones: true,
                      priceUnit: newPriceUnit,
                      subTotal: newPriceUnit * item.cantidad,
                      salsa: selectedSauce,
                    );
                    _items[index] = newItem;
                  });
                },
              ),

            // El selector de salsa general aparece si la media orden está activa o si el producto base acepta salsa
            if (item.llevaMediaOrdenBones || product.acceptsSauce)
              DropdownButtonFormField<String>(
                value: item.salsa,
                hint: const Text('Seleccionar salsa'),
                items: [
                  const DropdownMenuItem(value: 'Natural', child: Text('Natural')),
                  ...product.salsasDisponibles.map((s) => DropdownMenuItem(value: s, child: Text(s)))
                ],
                onChanged: (v) {
                  setState(() {
                    final newItem = item.copyWith(salsa: v);
                    _items[index] = newItem;
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
