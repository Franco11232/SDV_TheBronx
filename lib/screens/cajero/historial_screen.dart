// lib/screens/cajero/historial_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/comanda.dart';
import '../../widgets/comanda_tile.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String filtro = 'todas';
  final estados = ['todas', 'pendiente', 'en preparacion', 'listo', 'entregado'];

  Stream<List<Comanda>> getComandas() {
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    final finDia = inicioDia.add(const Duration(days: 1));

    final ref = FirebaseFirestore.instance
        .collection('comandas')
        .where('fecha', isGreaterThanOrEqualTo: inicioDia)
        .where('fecha', isLessThan: finDia)
        .orderBy('fecha', descending: true);

    return ref.snapshots().map((snapshot) {
      final data = snapshot.docs.map((doc) {
        return Comanda.fromMap(doc.id, doc.data());
      }).toList();

      if (filtro == 'todas') return data;
      return data.where((c) => c.estado == filtro).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial del día'),
        backgroundColor: Colors.brown.shade400,
        actions: [
          DropdownButton<String>(
            value: filtro,
            underline: const SizedBox(),
            dropdownColor: Colors.white,
            onChanged: (value) {
              if (value != null) setState(() => filtro = value);
            },
            items: estados.map((estado) {
              return DropdownMenuItem(
                value: estado,
                child: Text(estado[0].toUpperCase() + estado.substring(1)),
              );
            }).toList(),
          ),
        ],
      ),
      body: StreamBuilder<List<Comanda>>(
        stream: getComandas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final comandas = snapshot.data ?? [];
          if (comandas.isEmpty) {
            return const Center(child: Text('No hay comandas para hoy'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: comandas.length,
            itemBuilder: (context, index) {
              final c = comandas[index];
              return ComandaTile(
                comanda: c,
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
