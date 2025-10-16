import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String role;
  final void Function(String) onSelect;

  const AppDrawer({super.key, required this.role, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.brown.shade400,
            ),
            child: Text(
              'Bienvenido $role',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          if (role == 'admin') ...[
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => onSelect('dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Productos'),
              onTap: () => onSelect('productos'),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Almacén'),
              onTap: () => onSelect('almacen'),
            ),
          ],
          if (role == 'cajero') ...[
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Nueva Comanda'),
              onTap: () => onSelect('home'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Ventas'),
              onTap: () => onSelect('ventas'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial'),
              onTap: () => onSelect('historial'),
            ),
          ],
          if (role == 'cocinero') ...[
            ListTile(
              leading: const Icon(Icons.kitchen),
              title: const Text('Comandas'),
              onTap: () => onSelect('home'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial'),
              onTap: () => onSelect('historial'),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Salir'),
            onTap: () => onSelect('logout'),
          ),
        ],
      ),
    );
  }
}