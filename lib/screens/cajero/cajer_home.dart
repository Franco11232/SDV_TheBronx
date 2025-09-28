import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import 'nueva_comanda_screen.dart';

class CajeroHome extends StatefulWidget {
  const CajeroHome({super.key});

  @override
  _CajeroHomeState createState() => _CajeroHomeState();
}

class _CajeroHomeState extends State<CajeroHome> {
  final ProductService _ps = ProductService();
  List<Product> productos = [];

  @override
  void initState(){
    super.initState();
    _ps.streamProductos().listen((list) => setState(()=> productos = list));
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Cajero - Menú')),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3/2),
        itemCount: productos.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NuevaComandaScreen(productoInicial: productos[i]))),
          child: ProductCard(product: productos[i]),
        ),
      ),
    );
  }
}