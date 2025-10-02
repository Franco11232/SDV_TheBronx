import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import 'nueva_comanda_screen.dart';

class CajeroHome extends StatelessWidget {
  final ProductService _ps = ProductService();
  
  CajeroHome({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Cajero - Menú')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ps.streamProductos(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return const Center(child: Text('No hay prducts disponibles'));
          }
          final productos = snapshot.data!.docs
            .map((doc) => Product.fromDocument(doc))
            .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3/2,
              ),
            itemCount: productos.length,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NuevaComandaScreen(productoInicial: productos[i]),
                ),
              ),
              child: ProductCard(product: productos[i]), 
            ) ,
          );
        },
      ),
    );
  }
}