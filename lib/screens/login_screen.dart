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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/cajero'),
              child: Text('Entrar como Cajero')),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/cocinero'),
              child: Text('Entrar como Cocinero')),
            SizedBox(height:20),
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email admin')),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height:8),
            auth.loading ? CircularProgressIndicator() : ElevatedButton(
              onPressed: () async {
                final ok = await auth.signInAdmin(_emailCtrl.text.trim(), _passCtrl.text.trim());
                if (ok) {
                  Navigator.pushReplacementNamed(context, '/admin');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \${auth.error}')));
                }
              },
              child: Text('Entrar como Admin')),
          ],
        ),
      ),
    );
  }
}