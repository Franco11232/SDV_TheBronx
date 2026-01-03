import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/comanda.dart';
import '../../providers/comanda_provider.dart';
import '../../widgets/comanda_tile.dart';
import '../../widgets/pago_dialog.dart';
import 'nueva_comanda_screen.dart'; // ✅ Importar la pantalla de edición/creación

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String filtro = 'todas';
  
  final estados = ['todas', 'pendiente', 'en_preparacion', 'listo', 'entregado'];

  Stream<List<Comanda>> getComandas() {
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    final finDia = inicioDia.add(const Duration(days: 1));

    final ref = FirebaseFirestore.instance
        .collection('comandas')
        .where('date', isGreaterThanOrEqualTo: inicioDia)
        .where('date', isLessThan: finDia)
        .orderBy('date', descending: true);

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
    String capitalize(String s) {
      if (s.isEmpty) return '';
      final text = s.replaceAll('_', ' ');
      return text[0].toUpperCase() + text.substring(1);
    }

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
                child: Text(capitalize(estado)),
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
              // ✅ Lógica de onTap mejorada para editar o pagar
              return ComandaTile(
                comanda: c,
                tileColor: c.estado == 'listo' ? Colors.green.shade100 : (c.estado == 'pendiente' ? Colors.orange.shade100 : null),
                onTap: () {
                  if (c.estado == 'pendiente') {
                    // Navegar a la pantalla de edición
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NuevaComandaScreen(comanda: c),
                      ),
                    );
                  } else if (c.estado == 'listo') {
                    // Mostrar diálogo de pago
                    showDialog(
                      context: context,
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<ComandaProvider>(),
                        child: PagoDialog(comanda: c),
                      ),
                    );
                  } else {
                    // Mensaje para otros estados
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                        content: Text('Esta comanda no se puede editar ni pagar (Estado: ${c.estado})'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
