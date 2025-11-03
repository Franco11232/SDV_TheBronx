import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/categoria.dart';

class CategoryService {
  final _db = FirebaseFirestore.instance.collection('categorias');

  Stream<List<Categoria>> getCategories() {
    return _db.snapshots().map((snap) =>
        snap.docs.map((d) => Categoria.fromMap(d.id, d.data())).toList());
  }

  Future<void> addCategory(Categoria category) async {
    await _db.add(category.toMap());
  }

  Future<void> updateCategory(String id, Categoria categoria) async {
    await _db.doc(id).update(categoria.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _db.doc(id).delete();
  }
}
