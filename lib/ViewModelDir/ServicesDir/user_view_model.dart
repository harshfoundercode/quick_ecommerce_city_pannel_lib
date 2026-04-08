import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/user_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel with ChangeNotifier {

  String? _token;
  String? _userId;

  /// ---------------- INIT (optional but useful) ----------------
  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString('token');
    _userId = sp.getString('user_id');
  }

  /// ---------------- GETTERS ----------------
  String? get token => _token;
  String? get userId => _userId;

  /// ---------------- SAVE TOKEN ----------------

  Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', token);

    _token = token;
    await updateLastActivity();
  }

  /// ---------------- GET TOKEN (fallback safe) ----------------
  Future<String?> getToken() async {
    if (_token != null) return _token;

    final sp = await SharedPreferences.getInstance();
    _token = sp.getString('token');
    return _token;
  }

  /// ---------------- SAVE USER ----------------
  Future<void> saveUser(String userId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('user_id', userId);

    _userId = userId;
  }

  /// ---------------- GET USER ----------------
  Future<User> getUser() async {
    if (_userId != null) {
      return User(id: _userId!);
    }

    final sp = await SharedPreferences.getInstance();
    final id = sp.getString('user_id') ?? "0";
    _userId = id;

    return User(id: id);
  }

  /// ---------------- LOGOUT / CLEAR ----------------
  Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();

    await sp.remove('token');
    await sp.remove('user_id');

    _token = null;
    _userId = null;

    notifyListeners(); // only here makes sense
  }

  /// ---------------- SAVE LAST ACTIVITY ----------------
  Future<void> updateLastActivity() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(
      'last_activity',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// ---------------- CHECK SESSION EXPIRED ----------------
  Future<bool> isSessionExpired() async {
    final sp = await SharedPreferences.getInstance();
    final lastActivity = sp.getInt('last_activity');

    if (lastActivity == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - lastActivity;

    return difference > (30 * 60 * 1000); // 30 min
  }

}