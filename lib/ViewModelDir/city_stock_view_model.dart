import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_hub_history_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_request_history_model.dart';
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

  ///=================== CITY REQUEST FOR PRODUCTS STOCK TO ADMIN ===================


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
      // "items": [
      //   {
      //     "productid": 1,
      //     "qty": 10
      //   }
      // ],
      "items": items,
      "remarks": "Stock khatam ho raha hai, urgent bhejo"
    };

    try {
      final response = await _cityStockListRepo.cityRequestInventoryApi(data);

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


  ///============== CITY HUB HISTORY API ====================================

  CityHubHistoryModel? _cityHubHistoryModel;
  CityHubHistoryModel? get cityHubHistoryModel => _cityHubHistoryModel;

  List<HubGroup> get hubGroups {
    final raw = _cityHubHistoryModel?.data ?? [];
    final Map<int, HubGroup> map = {};
    for (final item in raw) {
      final id = item.hubId ?? 0;
      if (!map.containsKey(id)) {
        map[id] = HubGroup(
          hubId: id,
          hubName: item.hubName ?? '',
          items: [],
        );
      }
      map[id]!.items.add(item);
    }
    return map.values.toList();
  }

  bool _historyLoading = false;
  bool get historyLoading => _historyLoading;

  void _setHistoryLoading(bool value) {
    _historyLoading = value;
    notifyListeners();
  }

  Future<void> cityHubHistoryApi(BuildContext context) async {
    if (!context.mounted) return;

    _cityHubHistoryModel = null;
    _setHistoryLoading(true);

    try {
      final response = await _cityStockListRepo.cityHubHistoryApi();

      if (!context.mounted) {
        _setHistoryLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200) {
        _cityHubHistoryModel = CityHubHistoryModel.fromJson(body);
        notifyListeners();
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'History fetch failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ history error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setHistoryLoading(false);
    }
  }



  /// ==================== CITY REQUEST HISTORY LIST API FROM ADMIN ===========

  CityRequestHistoryModel? _cityRequestHistoryModel;
  CityRequestHistoryModel? get cityRequestHistoryModel => _cityRequestHistoryModel;

  void setCityRequestHistoryModel(CityRequestHistoryModel data) {
    _cityRequestHistoryModel = data;
    notifyListeners();
  }

  bool _adminHistoryLoading = false;
  bool get adminHistoryLoading => _adminHistoryLoading;

  void _setAdminHistoryLoading(bool value) {
    _adminHistoryLoading = value;
    notifyListeners();
  }

  Future<void> cityRequestHistoryApi(BuildContext context) async {
    if (!context.mounted) return;

    _cityRequestHistoryModel = null;
    _setAdminHistoryLoading(true);

    try {
      final response = await _cityStockListRepo.cityRequestInventoryHistoryApi();

      if (!context.mounted) {
        _setAdminHistoryLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200) {
        final cityRequestHistoryDataModel = CityRequestHistoryModel.fromJson(body);
        setCityRequestHistoryModel(cityRequestHistoryDataModel);
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'History fetch failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ history error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setAdminHistoryLoading(false);
    }
  }


}
