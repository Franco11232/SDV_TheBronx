import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import 'nueva_comanda_screen.dart';

class CajeroHome extends StatelessWidget {
  final ProductService _ps = ProductService();

  CajeroHome({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: _ps.streamProduct(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Ocurrió un error: ${snapshot.error}'),
          );
        }

        final productos = snapshot.data ?? [];
        if (productos.isEmpty) {
          return const Center(child: Text('No hay productos disponibles'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NuevaComandaScreen(productoInicial: producto),
                ),
              ),
              child: ProductCard(product: producto),
            );
          },
        );
      },
    );
  }
}
