import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/notification_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/notification_repo.dart';

class NotificationViewModel extends ChangeNotifier {

  final _notificationRepo = NotificationRepo();

  NotificationModel? _notificationModel;
  NotificationModel? get notificationModel => _notificationModel;

  void setNotificationDataModel(NotificationModel data) {
    _notificationModel = data;
    notifyListeners();
  }

  Future<void> getNotificationDataApi(context) async {
    _notificationModel = null;
    notifyListeners();
    try {
      final value = await _notificationRepo.notificationApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final notificationDataModel = NotificationModel.fromJson(body);
        setNotificationDataModel(notificationDataModel);
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
