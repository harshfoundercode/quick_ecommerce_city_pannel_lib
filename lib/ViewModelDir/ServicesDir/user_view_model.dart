// import 'package:flutter/material.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ModelDir/user_data_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class UserViewModel with ChangeNotifier {
//
//   /// REMOVE USER DATA (LOGOUT)
//   Future<void> removeUser() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     await sp.clear();
//     notifyListeners();
//   }
//
//   /// SAVE TOKEN
//   Future<bool> saveToken(String token) async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     sp.setString('token', token);
//     notifyListeners();
//     return true;
//   }
//
//   /// GET TOKEN
//   Future<String?> getToken() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     return sp.getString('token');
//   }
//
//
//   ///==========================================================================
//   Future<bool> saveUser(token) async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     sp.setString('user_id', token);
//     notifyListeners();
//     return true;
//   }
//
//   Future<User> getUser() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String userId = sp.getString('user_id') ?? "0";
//     return User(id: userId.toString());
//   }
//
//   Future<bool> remove() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     bool userIdRemoved = await sp.remove('user_id');
//     return userIdRemoved;
//   }
//
//   /// 🔥 LOGOUT (REMOVE EVERYTHING)
//   Future<void> logout() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     await sp.remove('token');
//     await sp.remove('user_id');
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/user_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel with ChangeNotifier {

  /// SAVE TOKEN
  Future<bool> saveToken(String token) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('token', token);
    notifyListeners();
    return true;
  }

  /// GET TOKEN
  Future<String?> getToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('token');
  }

  /// SAVE USER ID
  Future<bool> saveUser(String userId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('user_id', userId);
    notifyListeners();
    return true;
  }

  /// GET USER
  Future<User> getUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString('user_id') ?? "0";
    return User(id: userId);
  }

  /// 🔥 LOGOUT (REMOVE EVERYTHING)
  Future<void> logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.remove('token');
    await sp.remove('user_id');
    notifyListeners();
  }
}