import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _loginAdmin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.signInAdmin(_emailCtrl.text.trim(), _passCtrl.text.trim());

    if (ok) {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${auth.error ?? 'Login failed'}')),
      );
    }
  }

  void _enterAs(String role) {
    // Podrías guardar este rol en un provider
    Navigator.pushReplacementNamed(context, '/$role');
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _enterAs("cajero"),
              child: const Text('Entrar como Cajero'),
            ),
            ElevatedButton(
              onPressed: () => _enterAs("cocinero"),
              child: const Text('Entrar como Cocinero'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email admin'),
            ),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 8),
            auth.loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _loginAdmin,
                    child: const Text('Entrar como Admin'),
                  ),
          ],
        ),
      ),
    );
  }
}