import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel with ChangeNotifier {

  /// REMOVE USER DATA (LOGOUT)
  Future<void> removeUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();
    notifyListeners();
  }

  /// SAVE TOKEN
  Future<bool> saveToken(String token) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('token', token);
    notifyListeners();
    return true;
  }

  /// GET TOKEN
  Future<String?> getToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('token');
  }
}
