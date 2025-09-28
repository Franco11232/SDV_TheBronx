import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svd_thebronx/models/comanda.dart';

class ComandaService {
  final CollectionReference _col = FirebaseFirestore.instance.collection('comandas');
 
Future<void> crearComanda(Comanda c) async {
    await _col.add({
      'cliente': {'nombre': c.clientName, 'telefono': c.clientPhone},
      'tipo': c.type,
      'direccion': c.address,
      'estado': c.estado,
      'pago': c.payment,
      'fecha': FieldValue.serverTimestamp(),
      'total': c.total,
      'detalles': c.details.map((item) => item.toMap()).toList(),

    });
  }
  Stream<List<Comanda>> streamComandas(String estado) => _col.where('estado', isEqualTo: estado).snapshots().map((s) => s.docs.map((d) =>
      Comanda.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());

      Future<void>actualizarEstado(String id, String nuevoEstado) => _col.doc(id).update({'estado': nuevoEstado});

      Future<List<Comanda>>obtenerComandasPagadas() async{
        final snap = await _col.where('pago.method', isEqualTo: 'pagado').get();
        return snap.docs.map((d) => Comanda.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
      }
}