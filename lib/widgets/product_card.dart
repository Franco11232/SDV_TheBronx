import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget{
  final Product product;
  const ProductCard({super.key, required this.product});
  @override Widget build(BuildContext context){
    return Card(child: Column(children:[
      Expanded(child:Icon(Icons.fastfood, size:40)),
      Text(product.name),
      Text('\$\${product.price.toStringAsFixed(2)}')
    ]));
  }
}