import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:svd_thebronx/providers/almacen_provider.dart';
import 'package:svd_thebronx/screens/admin/admin_shell.dart';
import 'package:svd_thebronx/screens/cajero/cajero_shell.dart';
import 'package:svd_thebronx/screens/cocinero/cocinero_shell.dart';
import 'providers/auth_provider.dart';
import 'providers/comanda_provider.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override Widget build(BuildContext context){
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider()), ChangeNotifierProvider(create: (_) => ComandaProvider()),ChangeNotifierProvider(create: (_) => AlmacenProvider())],
      child: MaterialApp(
        title: 'The Bronx FT',
        initialRoute: '/',
        routes: {
          '/': (_) => LoginScreen(),
          '/cajero': (_) => CajeroShell(),
          '/cocinero': (_) => CocineroShell(),
          '/admin': (_) => AdminShell(),
        },
      ),
    );
  }
}