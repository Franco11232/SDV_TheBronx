import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/comanda_provider.dart';
import 'screens/login_screen.dart';
import 'screens/cajero/cajer_home.dart';
import 'screens/cocinero/cocinero_home.dart';
import 'screens/admin/admin_home.dart';
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
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider()), ChangeNotifierProvider(create: (_) => ComandaProvider())],
      child: MaterialApp(
        title: 'Comandas',
        initialRoute: '/',
        routes: {
          '/': (_) => LoginScreen(),
          '/cajero': (_) => CajeroHome(),
          '/cocinero': (_) => CocineroHome(),
          '/admin': (_) => AdminHome(),
        },
      ),
    );
  }
}