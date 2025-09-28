import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProductosScreen extends StatelessWidget {
  final nombreCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final categoriaCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Administrar Productos")),
      body: Column(
        children: [
          TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: "Nombre")),
          TextField(controller: precioCtrl, decoration: InputDecoration(labelText: "Precio"), keyboardType: TextInputType.number),
          TextField(controller: categoriaCtrl, decoration: InputDecoration(labelText: "Categoría")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection("productos").add({
                "nombre": nombreCtrl.text,
                "precio": double.parse(precioCtrl.text),
                "categoria": categoriaCtrl.text,
                "disponible": true,
              });
              nombreCtrl.clear();
              precioCtrl.clear();
              categoriaCtrl.clear();
            },
            child: Text("Guardar Producto"),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("productos").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final productos = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (_, i) {
                    final p = productos[i];
                    return ListTile(
                      title: Text(p["nombre"]),
                      subtitle: Text("${p["categoria"]} - \$${p["precio"]}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
