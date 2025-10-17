// lib/screens/cajero/ventas_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/comanda.dart';
import '../../models/comanda.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  late Future<Map<String, dynamic>> resumenFuture;

  @override
  void initState() {
    super.initState();
    resumenFuture = obtenerResumen();
  }

  Future<Map<String, dynamic>> obtenerResumen() async {
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    final finDia = inicioDia.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('comandas')
        .where('fecha', isGreaterThanOrEqualTo: inicioDia)
        .where('fecha', isLessThan: finDia)
        .get();

    double totalDia = 0;
    int cantidad = snapshot.docs.length;
    final Map<String, double> porProducto = {};

    for (var doc in snapshot.docs) {
      final comanda = Comanda.fromMap(doc.id, doc.data());
      totalDia += comanda.total;
      for (var item in comanda.details) {
        porProducto[item.nombre] =
            (porProducto[item.nombre] ?? 0) + item.subTotal;
      }
    }

    return {
      'total': totalDia,
      'cantidad': cantidad,
      'porProducto': porProducto,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resumen de ventas"),
        backgroundColor: Colors.brown.shade400,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: resumenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final total = data['total'] as double;
          final cantidad = data['cantidad'] as int;
          final porProducto = data['porProducto'] as Map<String, double>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Comandas del día: $cantidad",
                    style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text("Total vendido: \$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                const Divider(height: 30),
                const Text("Ventas por producto:",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: porProducto.entries.map((e) {
                      return ListTile(
                        title: Text(e.key),
                        trailing: Text(
                          "\$${e.value.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.brown),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
