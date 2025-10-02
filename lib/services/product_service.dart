import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svd_thebronx/models/product.dart';

class ProductService {
  // final CollectionReference _col = FirebaseFirestore.instance.collection('productos');
  // Stream<List<Product>> streamProductos() => _col.snapshots().map((s) => 
  //   s.docs.map((d) => Product(
  //     id: d.id,
  //     name: d['name'] ?? '',
  //     price: (d['price'] ?? 0).toDouble(),
  //     category: d['category'] ?? '',
  //     disponible: d['disponible'] ?? true,
  //   )).toList()
  // );
  // Future<void> addProduct(Product p) => _col.add(p.toMap());
  // Future<void> updateProduct(Product p) => _col.doc(p.id).update(p.toMap());
  // Future<void> deleteProduct(String id) => _col.doc(id).delete();

  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamProductos(){
    return _db.collection("productos").snapshots();
  }

  Future<void> addProducto (Product p) async{
    await _db.collection("productos").add(p.toMap());
  }
}
