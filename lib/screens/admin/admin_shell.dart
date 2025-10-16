// admin_shell.dart
import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import 'admin_home.dart';
import 'admin_dashboard_screen.dart';
import 'admin_almacen_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  String currentScreen = 'dashboard'; // empieza en Dashboard

  void _onSelectDrawer(String screen) {
    if (screen == 'logout') {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }
    setState(() {
      currentScreen = screen;
    });
    Navigator.pop(context); // cerrar Drawer
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    String title;

    switch (currentScreen) {
      case 'dashboard':
        body = const AdminDashboardScreen();
        title = 'Dashboard';
        break;
      case 'productos':
        body = AdminHome();
        title = 'Productos';
        break;
      case 'almacen':
        body = const AdminAlmacenScreen();
        title = 'Almacén';
        break;
      default:
        body = const AdminDashboardScreen();
        title = 'Dashboard';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: AppDrawer(role: 'admin', onSelect: _onSelectDrawer),
      body: body,
    );
  }
}
