import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/city_stock_repo.dart';

class CityStockViewModel with ChangeNotifier {
  final _cityStockListRepo = CityStockListRepo();

  CityStockModel? _cityStockModel;
  CityStockModel? get cityStockModel => _cityStockModel;

  void setCityStockModel(CityStockModel data) {
    _cityStockModel = data;
    notifyListeners();
  }

  Future<void> getCityStockDataApi(context) async {
    _cityStockModel = null;
    notifyListeners();
    try {
      final value = await _cityStockListRepo.cityStockListApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final cityStockDataModel = CityStockModel.fromJson(body);
        setCityStockModel(cityStockDataModel);
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

  ///============ CITY TRANSFER TO HUB API ===============================


  bool _transferLoading = false;
  bool get transferLoading => _transferLoading;

  void _setTransferLoading(bool value) {
    _transferLoading = value;
    notifyListeners();
  }

  Future<void> cityTransferToHubApi(
      BuildContext context,
      String hubManagerId,
      String remarks,
      final List<Map<String, dynamic>> items
      ) async {
    if (!context.mounted) return;

    _setTransferLoading(true);

    final data = {
      "hubmanagerid": hubManagerId,
      "remarks": remarks,
      "items": items,
      // "items": [
      //   {
      //     "productid": 1,
      //     "variantid": 1,
      //     "qty": 20
      //   },
      // ]
    };

    try {
      final response = await _cityStockListRepo.cityTransferToHubApi(data);

      if (!context.mounted) {
        _setTransferLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        if (!context.mounted) {
          _setTransferLoading(false);
          return;
        }
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'transfer Successful',
          title: 'Success',
          type: SnackBarType.success,
        );
       Navigator.pop(context);
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'transfer Failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ transfer error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setTransferLoading(false);
    }
  }

  ///=================== CITY REQUEST FOR PRODUCTS STOCK ===================


  bool _cityRequestLoading = false;
  bool get cityRequestLoading => _cityRequestLoading;

  void _setCityRequestLoading(bool value) {
    _cityRequestLoading = value;
    notifyListeners();
  }

  Future<void> cityRequestApi(
      BuildContext context,
      String hubManagerId,
      String remarks,
      final List<Map<String, dynamic>> items
      ) async {
    if (!context.mounted) return;

    _setCityRequestLoading(true);

    final data = {
      "hubmanagerid": hubManagerId,
      "remarks": remarks,
      "items": items,
      // "items": [
      //   {
      //     "productid": 1,
      //     "variantid": 1,
      //     "qty": 20
      //   },
      // ]
    };

    try {
      final response = await _cityStockListRepo.cityTransferToHubApi(data);

      if (!context.mounted) {
        _setTransferLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        if (!context.mounted) {
          _setTransferLoading(false);
          return;
        }
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'request Successful',
          title: 'Success',
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'transfer Failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ request error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setCityRequestLoading(false);
    }
  }

}
