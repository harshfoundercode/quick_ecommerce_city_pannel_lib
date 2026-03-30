import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/user_data_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/login_repo.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  bool _loginLoading = false;
  bool get loginLoading => _loginLoading;

  UserDataModel? _loginResponse;
  UserDataModel? get loginResponse => _loginResponse;

  // ==================== Loading State Setters ====================

  void _setLoginLoading(bool value) {
    _loginLoading = value;
    notifyListeners();
  }

  // ==================== Data Model Setters ====================

  void _setDataInModel(UserDataModel loginData) {
    _loginResponse = loginData;
    notifyListeners();
  }

  // ==================== Clear Methods ====================

  void clearAllForms() {
    passwordController.clear();
    emailController.clear();
    notifyListeners();
  }

  Future<void> loginApi(BuildContext context) async {
    if (!context.mounted) return;

    _setLoginLoading(true);

    final data = {
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "fcm_token": "",
    };
    try {
      final response = await _authRepository.loginApi(data);

      if (!context.mounted) {
        _setLoginLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        final authModel = UserDataModel.fromJson(body);
        _setDataInModel(authModel);

        final userPref = Provider.of<UserViewModel>(context, listen: false);
        await userPref.saveToken(authModel.data!.token.toString());
        await userPref.saveUser(authModel.data!.user!.id.toString());

        if (!context.mounted) {
          _setLoginLoading(false);
          return;
        }

        CustomSnackBar.show(
          context,
          message: authModel.message ?? 'Login Successful',
          title: 'Success',
          type: SnackBarType.success,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.adminSliderLayoutScreen,
              (route) => false,
        );
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Login Failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ loginApi error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setLoginLoading(false);
    }
  }
}
