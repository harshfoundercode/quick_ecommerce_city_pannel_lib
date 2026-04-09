import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/admin_incoming_models.dart' show AdminIncomingStockModel;
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/stock_repo/all_stock_repo.dart';

class AdminIncomingStockNewViewModel with ChangeNotifier {
  final _allCityStockListRepo = AllCityStockDataNewRepo();

  AdminIncomingStockModel? _adminIncomingStockModel;

  AdminIncomingStockModel? get cityStockModel => _adminIncomingStockModel;

  void setAdminIncomingStockModel(AdminIncomingStockModel data) {
    _adminIncomingStockModel = data;
    notifyListeners();
  }

  Future<void> getAdminIncomingDataApi(context) async {
    _adminIncomingStockModel = null;
    notifyListeners();
    try {
      final value = await _allCityStockListRepo.adminIncomingStockApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final adminIncomingStockModel = AdminIncomingStockModel.fromJson(body);
        setAdminIncomingStockModel(adminIncomingStockModel);
      } else {
        CustomSnackBar.show(
          context,
          message: body["message"] ?? 'Failed to fetch data',
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching incoming stock: $e');
      }
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    }
  }

  /// ---------------------- Accept Transfer API -------------------------------------
  bool _loading = false;
  bool get loading => _loading;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> acceptAdminTransferApi({
    required BuildContext context,
    required String transferId,
    required String remark,
    required List<Map<String, dynamic>> items,
    VoidCallback? onSuccess,
  }) async {
    if (!context.mounted) return;
    _setLoading(true);

    final data = {
      "transfer_id": transferId,
      "status": 1, // 1 for accepted/received
      "remark": remark,
      "items": items,
    };

    try {
      final response = await _allCityStockListRepo.adminIncomingStockAcceptApi(data);

      if (!context.mounted) {
        _setLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Transfer accepted successfully',
          title: 'Success',
          type: SnackBarType.success,
        );

        // Refresh the list
        await getAdminIncomingDataApi(context);

        // Call success callback
        onSuccess?.call();
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Failed to accept transfer',
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ accept transfer error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } finally {
      _setLoading(false);
    }
  }
}