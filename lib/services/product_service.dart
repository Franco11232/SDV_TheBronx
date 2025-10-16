import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svd_thebronx/models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> streamProduct(){
    return _db.collection("productos").snapshots().map((snapshot){
      return snapshot.docs.map((doc){
        return Product.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addProduct (Product product) async{
    try {
      await _db.collection("product").add(product.toMap());
      print("producto añaido correctamente");
    }catch (e){
      print("Error: no se pudo añadir el producto: $e");
    }    
  }

  Future<void> updateProduct (Product product) async {
    if (product.id.isEmpty){
      print("Error: el producto no tiene ID");
      return;
    }
    try{
      await _db
        .collection("productos")
        .doc(product.id)
        .update(product.toMap());
      print("producto actualizado correctamente");
    }catch (e){
      print("Error al actualizar producto: $e");
    }
  }

  Future<void> deleteProduct(String id) async{
   if (id.isEmpty){
    print("Error el producto no tiene ID");
    return;
  }
  try {
    await _db.collection("productos").doc(id).delete();
    print("Producto eliminado correctamente");
  } catch (e){
    print("Error al eliminar el producto: $e");
   }
  }
}



