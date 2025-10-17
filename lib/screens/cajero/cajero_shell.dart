// cajero_shell.dart
import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import 'cajer_home.dart';
import 'nueva_comanda_screen.dart';
import 'historial_screen.dart';
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
        body = const CajeroHome(); //const
        title = 'Productos';
        break;
      case 'comanda':
        body = const NuevaComandaScreen(productosSeleccionados: [],);
        title = 'Nueva Comanda';
        break;
      case 'historial':
        body = HistorialScreen();//const
        title = 'Historial de Comandas';
        break;
        case 'ventas':
        body = VentasScreen();//const
        title = 'Ventas';
        break;
      default:
        body = CajeroHome();
        title = 'Productos';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: AppDrawer(role: 'cajero', onSelect: _onSelectDrawer),
      body: body,
    );
  }
}
