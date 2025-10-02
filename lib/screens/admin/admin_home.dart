import 'package:flutter/material.dart';
import 'package:svd_thebronx/screens/admin/admin_productos_screen.dart';

class AdminHome extends StatelessWidget{
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menú Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),

            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProductosScreen()));
              },
              child: ListTile(
                leading: Icon(Icons.inventory),
                title: Text('Productos'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Reportes'),
              onTap: () {
                Navigator.pushNamed(context, '/admin_reportes');
              },
            ),


            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text('Panel admin: productos, reportes')),
    );
    
  }

}