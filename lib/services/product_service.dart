import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svd_thebronx/models/product.dart';

class ProductService {
  final CollectionReference _col = FirebaseFirestore.instance.collection('productos');
  Stream<List<Product>> streamProductos() => _col.snapshots().map((s) => s.docs.map((d) => Product.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());

  Future<void> addProduct(Product p) => _col.add(p.toMap());
  Future<void> updateProduct(Product p) => _col.doc(p.id).update(p.toMap());
  Future<void> deleteProduct(String id) => _col.doc(id).delete();
  }
