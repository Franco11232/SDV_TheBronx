import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/comanda_provider.dart';

class CocineroHome extends StatefulWidget{
  const CocineroHome({super.key});

  @override _CocineroHomeState createState()=> _CocineroHomeState();
}

class _CocineroHomeState extends State<CocineroHome>{
  @override
  void initState(){
    super.initState();
    final prov = Provider.of<ComandaProvider>(context, listen:false);
    prov.loadPendientes();
  }

  @override
  Widget build(BuildContext context){
    final prov = Provider.of<ComandaProvider>(context);
    final pendientes = prov.pendientes;
    return Scaffold(
      appBar: AppBar(title: Text('Cocinero - Comandas')),
      body: ListView.builder(itemCount: pendientes.length, itemBuilder:(c,i){ final com = pendientes[i]; return Card(child: ListTile(
        title: Text(com.clientName.isEmpty? 'Sin nombre':com.clientName),
        subtitle: Text('Items: \${com.details.length} - Total: \$\${com.total}'),
        trailing: PopupMenuButton<String>(onSelected: (v)=>prov.actualizarEstado(com.id!, v), itemBuilder: (_)=>[PopupMenuItem(value:'en_preparacion', child:Text('En preparación')), PopupMenuItem(value:'listo', child:Text('Listo'))]),
      ));}),
    );
  }
}
