// lib/screens/cajero/cajero_home.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/comanda_provider.dart';
import 'nueva_comanda_screen.dart';
import '../../models/item_comanda.dart';

class CajeroHome extends StatefulWidget {
  const CajeroHome({super.key});

  @override
  State<CajeroHome> createState() => _CajeroHomeState();
}

class _CajeroHomeState extends State<CajeroHome> {
  String selectedCategory = 'Todos';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final comandaProvider = Provider.of<ComandaProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: _buildSearchBar(),
        backgroundColor: Colors.brown.shade400,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Carrito próximamente')));
                },
              ),
              if (comandaProvider.productos.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    child: Text(
                      '${comandaProvider.productos.length}',
                      style:
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('productos')
            .where('disponible', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar productos: ${snapshot.error}'));
          }

          final productos = snapshot.data!.docs
              .map((d) => Product.fromMap(d.id, d.data() as Map<String, dynamic>))
              .where((p) =>
          (selectedCategory == 'Todos' || p.category == selectedCategory) &&
              p.name.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          final categorias = <String>[
            'Todos',
            ...{for (var p in snapshot.data!.docs) (p.data() as Map<String, dynamic>)['categoria']}
          ];

          return Column(
            children: [
              _buildCategoryChips(categorias.toList()),
              Expanded(
                child: productos.isEmpty
                    ? const Center(child: Text('No hay productos disponibles'))
                    : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return _buildProductCard(producto, comandaProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: comandaProvider.productos.isEmpty
          ? null
          : FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.receipt_long),
        label: Text(
            'Ver Comanda (${comandaProvider.total.toStringAsFixed(2)})'),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NuevaComandaScreen(
                  productosSeleccionados: List.from(comandaProvider.productos),
            ),
            ),
          );
          if (created == true) {
            comandaProvider.clearComanda(); // limpiar carrito
          }
        },
      ),
    );
  }

  // 🔍 Buscador
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

  // 🏷️ Chips de categorías
  Widget _buildCategoryChips(List<String> categorias) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final isSelected = categoria == selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(categoria),
              selected: isSelected,
              selectedColor: Colors.brown.shade300,
              backgroundColor: Colors.grey.shade300,
              labelStyle:
              TextStyle(color: isSelected ? Colors.white : Colors.black),
              onSelected: (_) => setState(() => selectedCategory = categoria),
            ),
          );
        },
      ),
    );
  }

  // 🧾 Tarjeta de producto
  Widget _buildProductCard(Product producto, comandaProvider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Image.network(
                producto.imageUrl ?? "",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.fastfood, size: 60),
              ),
            ),
            Text(
              producto.name,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '\$${producto.price.toStringAsFixed(2)}',
              style: TextStyle(
                  color: Colors.brown.shade700, fontWeight: FontWeight.w600),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                comandaProvider.agregarProducto(
                  ItemComanda(
                    productId: producto.id,
                    nombre: producto.name,
                    cantidad: 1,
                    priceUnit: producto.price,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${producto.name} agregado')),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Agregar"),
            ),
          ],
        ),
      ),
    );
  }
}
