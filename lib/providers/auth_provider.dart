import 'package:flutter/material.dart';
import 'package:svd_thebronx/services/auth_services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  bool loading = false;
  String? error;

  Future<bool> signInAdmin(String email, String password) async {
    try {
      loading = true; notifyListeners();
      await _auth.signInAdmin(email, password);
      loading = false; notifyListeners();
      return true;
    } catch (e) {
      loading = false; error = e.toString(); notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}