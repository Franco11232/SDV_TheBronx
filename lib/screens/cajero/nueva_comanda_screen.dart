import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/comanda.dart';
import '../../services/comanda_service.dart';

class NuevaComandaScreen extends StatefulWidget {
  final Product? productoInicial;
  const NuevaComandaScreen({super.key, this.productoInicial});
  @override _NuevaComandaScreenState createState()=> _NuevaComandaScreenState();
}

class _NuevaComandaScreenState extends State<NuevaComandaScreen>{
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  String tipo = 'comer_aqui';
  String pagoEstado = 'pendiente';
  String metodo = 'efectivo';
  List<ItemComanda> items = [];
  final ComandaService _cs = ComandaService();

  @override
  void initState(){
    super.initState();
    if(widget.productoInicial!=null){
      items.add(ItemComanda(productId: widget.productoInicial!.id, nombre: widget.productoInicial!.name, cantidad: 1, priceUnit: widget.productoInicial!.price));
    }
  }

  double get total => items.fold(0, (s, it) => s + it.subTotal);

  void addProduct(Product p){
    final idx = items.indexWhere((i)=>i.productId==p.id);
    if(idx>=0){
      final existing = items[idx];
      items[idx] = ItemComanda(productId: existing.productId, nombre: existing.nombre, cantidad: existing.cantidad+1, priceUnit: existing.priceUnit);
    } else {
      items.add(ItemComanda(productId: p.id, nombre: p.name, cantidad: 1, priceUnit: p.price));
    }
    setState((){});
  }

  Future<void> enviar(){
    final c = Comanda(
      clientName: _nombre.text.trim(),
      clientPhone: _telefono.text.trim(),
      type: tipo,
      estado: 'pendiente',
      payment: {'estado': pagoEstado, 'metodo': metodo},
      total: total,
      details: items, id: '', address: '', date: null,
    );
    return _cs.crearComanda(c).then((_){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comanda enviada')));
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Comanda')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          TextField(controller: _nombre, decoration: InputDecoration(labelText: 'Nombre')),
          TextField(controller: _telefono, decoration: InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
          DropdownButton<String>(value: tipo, items: [DropdownMenuItem(value: 'comer_aqui', child: Text('Comer aquí')), DropdownMenuItem(value:'para_llevar', child: Text('Para llevar')), DropdownMenuItem(value:'domicilio', child: Text('Domicilio'))], onChanged: (v){ if(v!=null) setState(()=>tipo=v); }),
          DropdownButton<String>(value: pagoEstado, items: [DropdownMenuItem(value:'pagado', child:Text('Pagado')), DropdownMenuItem(value:'pendiente', child:Text('Pendiente'))], onChanged:(v){ if(v!=null) setState(()=>pagoEstado=v); }),
          DropdownButton<String>(value: metodo, items: [DropdownMenuItem(value:'efectivo', child:Text('Efectivo')), DropdownMenuItem(value:'transferencia', child:Text('Transferencia'))], onChanged:(v){ if(v!=null) setState(()=>metodo=v); }),
          SizedBox(height:8),
          Expanded(child: ListView.builder(itemCount: items.length, itemBuilder:(c,i){ final it=items[i]; return ListTile(title: Text(it.nombre), subtitle: Text('x\${it.cantidad} - \$\${it.subtotal}')); })),
          Text('Total: \$\$${total.toStringAsFixed(2)}'),
          Row(children:[Expanded(child:ElevatedButton(onPressed: items.isEmpty?null:enviar, child: Text('Enviar comanda')))])
        ])
      )
    );
  }
}