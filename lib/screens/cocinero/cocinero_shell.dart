// cocinero_shell.dart
import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import 'cocinero_home.dart';
import 'conteo_preparados_screen.dart';

class CocineroShell extends StatefulWidget {
  const CocineroShell({super.key});
  @override
  State<CocineroShell> createState() => _CocineroShellState();
}

class _CocineroShellState extends State<CocineroShell> {
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
        body = const CocineroHome();
        title = 'Comandas';
        break;
      case 'historial':
        body = const ConteoPreparadosScreen();
        title = 'Historial';
        break;
      default:
        body = const CocineroHome();
        title = 'Comandas';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: AppDrawer(role: 'cocinero', onSelect: _onSelectDrawer),
      body: body,
    );
  }
}
