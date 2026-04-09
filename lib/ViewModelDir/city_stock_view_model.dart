import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_hub_history_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_request_history_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/city_stock_repo.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/dashboard_content.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';

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
        final adminVM = Provider.of<AdminViewModel>(context, listen: false);
        adminVM.changeScreen(const DashboardContent(), 0);
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.adminSliderLayoutScreen,
              (route) => false,
        );
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

  Future<void> cityTransferToHubBulkApi(
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
        final adminVM = Provider.of<AdminViewModel>(context, listen: false);
        adminVM.changeScreen(const DashboardContent(), 0);
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.adminSliderLayoutScreen,
              (route) => true,
        );
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


  ///========================== CITY REQUEST TO ADMIN ========================
  // ================= LOADING =================
  bool _cityRequestLoading = false;
  bool get cityRequestLoading => _cityRequestLoading;

  void _setCityRequestLoading(bool value) {
    _cityRequestLoading = value;
    notifyListeners();
  }

// ================= SELECTION =================
  final Set<int> _selectedProductIds = {};
  final Map<int, int> _selectedQty = {};

  Set<int> get selectedProductIds => _selectedProductIds;
  Map<int, int> get selectedQty => _selectedQty;

  void toggleSelection(int productId) {
    if (_selectedProductIds.contains(productId)) {
      _selectedProductIds.remove(productId);
      _selectedQty.remove(productId);
    } else {
      _selectedProductIds.add(productId);
      _selectedQty[productId] = 1;
    }
    notifyListeners();
  }

  void updateQty(int productId, int qty) {
    if (qty <= 0) qty = 1;
    _selectedQty[productId] = qty;
    notifyListeners();
  }

  void clearSelection() {
    _selectedProductIds.clear();
    _selectedQty.clear();
    notifyListeners();
  }

  void selectLowStock(List<CityStockData> items) {
    _selectedProductIds.clear();
    _selectedQty.clear();

    for (var item in items) {
      if ((item.totalStock ?? 0) < 10 && item.productId != null) {
        _selectedProductIds.add(item.productId!);
        _selectedQty[item.productId!] = 5;
      }
    }
    notifyListeners();
  }

  Future<void> cityRequestApi(BuildContext context, String remarks, List<Map<String, dynamic>> items,) async {
    if (!context.mounted) return;
    _setCityRequestLoading(true);
    final data = {
      "items": items,
    //   "items": [
    // {
    // "productid": e.selectedProduct!.productId,
    // "qty": int.tryParse(e.qtyController.text) ?? 1,
    // };
    //   ],
      "remarks": remarks,
    };

    try {
      final response = await _cityStockListRepo.cityRequestInventoryApi(data);

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        if (!context.mounted) return;

        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Request Successful',
          title: 'Success',
          type: SnackBarType.success,
        );
        final adminVM = Provider.of<AdminViewModel>(context, listen: false);
        adminVM.changeScreen(const DashboardContent(), 0);
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.adminSliderLayoutScreen,
              (route) => false,
        );
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Request Failed',
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

  // Future<void> bulkRequestStock(BuildContext context, String remarks) async {
  //   if (_selectedProductIds.isEmpty) return;
  //
  //   final items = _selectedProductIds.map((id) {
  //     return {
  //       "productid": id,
  //       "qty": _selectedQty[id] ?? 1,
  //     };
  //   }).toList();
  //
  //   await cityRequestApi(context, remarks, items);
  //
  //   clearSelection();
  // }

  ///============== CITY REQUEST TO HUB HISTORY API ====================================

  CityHubHistoryModel? _cityHubHistoryModel;
  CityHubHistoryModel? get cityHubHistoryModel => _cityHubHistoryModel;

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

