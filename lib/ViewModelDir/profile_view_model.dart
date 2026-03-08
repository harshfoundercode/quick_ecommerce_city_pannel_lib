import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_manager_profile_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/profile_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/profile_repo.dart';

class ProfileViewModel with ChangeNotifier {
  final _profileRepo = ProfileRepo();

  ProfileDataModel? _profileData;
  ProfileDataModel? get profileData => _profileData;

  void setProfileDataModel(ProfileDataModel data) {
    _profileData = data;
    notifyListeners();
  }

  Future<void> getProfileDataApi(context) async {
    _profileData = null;
    notifyListeners();
    try {
      final value = await _profileRepo.profileApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final profileDataModel = ProfileDataModel.fromJson(body);
        setProfileDataModel(profileDataModel);
      } else {
        CustomSnackBar.show(
          context,
          message: body["message"],
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }


  HubProfileDataModel? _managerProfileData;
  HubProfileDataModel? get managerProfileData => _managerProfileData;

  void setManagerProfileDataModel(HubProfileDataModel data) {
    _managerProfileData = data;
    notifyListeners();
  }

  Future<void> getManagerProfileDataApi(context) async {
    _managerProfileData = null;
    notifyListeners();
    try {
      final value = await _profileRepo.hubProfileApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final hubProfileDataModel = HubProfileDataModel.fromJson(body);
        setManagerProfileDataModel(hubProfileDataModel);
      } else {
        CustomSnackBar.show(
          context,
          message: body["message"],
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
