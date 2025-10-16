import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // Ajusta collection/nombres segun tu BDD: asumo 'comandas' y cada comanda tiene details[] con productId, nombre, cantidad, date.
  Stream<Map<String, double>> ventasPorCategoriaHoy() {
    final start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final end = start.add(const Duration(days:1));
    return FirebaseFirestore.instance
        .collection('comandas')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .snapshots()
        .map((snap) {
      final Map<String, double> byCat = {};
      for (var doc in snap.docs) {
        final details = (doc['details'] as List<dynamic>? ) ?? [];
        for (var it in details) {
          final cat = it['category'] ?? 'Sin categoría';
          final qty = (it['cantidad'] ?? 0) * 1.0;
          final price = (it['priceUnit'] ?? 0) * 1.0;
          byCat[cat] = (byCat[cat] ?? 0) + (qty * price);
        }
      }
      return byCat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String,double>>(
      stream: ventasPorCategoriaHoy(),
      builder: (context, snap){
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        final data = snap.data ?? {};
        if (data.isEmpty) return const Center(child: Text('No hay ventas hoy'));
        final categories = data.keys.toList();
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, i){
            final cat = categories[i];
            final total = data[cat] ?? 0.0;
            return ListTile(
              title: Text('$cat'),
              subtitle: Text('Venta del día: \$${total.toStringAsFixed(2)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navegar a detalle de productos vendidos hoy para esa categoría
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductosVendidosDetalleScreen(categoria: cat)));
              },
            );
          },
        );
      },
    );
  }
}

// Pantalla que muestra productos vendidos hoy para una categoría (puedes adaptarla según cómo guardes los detalles)
class ProductosVendidosDetalleScreen extends StatelessWidget {
  final String categoria;
  const ProductosVendidosDetalleScreen({super.key, required this.categoria});

  Stream<Map<String,double>> _productosVendidosHoy(String categoria) {
    final start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final end = start.add(const Duration(days:1));
    return FirebaseFirestore.instance
        .collection('comandas')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .snapshots()
        .map((snap){
      final Map<String,double> acc = {};
      for (var doc in snap.docs){
        final details = (doc['details'] as List<dynamic>? ) ?? [];
        for (var it in details){
          if ((it['category'] ?? '') == categoria) {
            final name = it['nombre'] ?? 'Sin nombre';
            final qty = (it['cantidad'] ?? 0) * 1.0;
            final price = (it['priceUnit'] ?? 0) * 1.0;
            acc[name] = (acc[name] ?? 0) + (qty * price);
          }
        }
      }
      return acc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vendidos - $categoria')),
      body: StreamBuilder<Map<String,double>>(
        stream: _productosVendidosHoy(categoria),
        builder: (context, snap){
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final data = snap.data ?? {};
          if (data.isEmpty) return const Center(child: Text('No se vendió nada en esta categoría hoy'));
          final items = data.entries.toList();
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final e = items[i];
              return ListTile(title: Text(e.key), trailing: Text('\$${e.value.toStringAsFixed(2)}'));
            },
          );
        },
      ),
    );
  }
}
