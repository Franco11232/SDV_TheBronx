// cajero_shell.dart
import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import 'cajer_home.dart';
import 'ventas_screen.dart';

class CajeroShell extends StatefulWidget {
  const CajeroShell({super.key});
  @override
  State<CajeroShell> createState() => _CajeroShellState();
}

class _CajeroShellState extends State<CajeroShell> {
  String currentScreen = 'home';

  void _onSelectDrawer(String screen) {
    if (screen == 'logout') {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }
    setState(() => currentScreen = screen);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    String title;

    switch (currentScreen) {
      case 'home':
        body = CajeroHome();
        title = 'Nueva Comanda';
        break;
      case 'ventas':
        body = const VentasScreen();
        title = 'Ventas';
        break;
      case 'historial':
        body = const Center(child: Text('Historial de comandas en construcción'));
        title = 'Historial';
        break;
      default:
        body = CajeroHome();
        title = 'Nueva Comanda';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: AppDrawer(role: 'cajero', onSelect: _onSelectDrawer),
      body: body,
    );
  }
}
