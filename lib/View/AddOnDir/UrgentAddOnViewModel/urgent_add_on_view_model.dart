
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnModelDir/category_from_maincat_model_urgent.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnModelDir/main_category_list_model_urgent.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnRepoDir/urgent_add_inventory_repo.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/dashboard_content.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';

class UrgentAddOnViewModel with ChangeNotifier {
  final _urgentAddInventoryRepo = UrgentAddInventoryRepo();

  // ── Main Category ──────────────────────────────────────────────────────────

  UrgentMainCategoryListModel? _urgentMainCategoryListModel;
  UrgentMainCategoryListModel? get urgentMainCategoryListModel =>
      _urgentMainCategoryListModel;

  void setUrgentAddOnMainCatModel(UrgentMainCategoryListModel data) {
    _urgentMainCategoryListModel = data;
    notifyListeners();
  }

  Future<void> getMainCategoryDataApi(context) async {
    _urgentMainCategoryListModel = null;
    notifyListeners();
    try {
      final value = await _urgentAddInventoryRepo.mainCategoryListApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final model = UrgentMainCategoryListModel.fromJson(body);
        setUrgentAddOnMainCatModel(model);
      } else {
        CustomSnackBar.show(context,
            message: body["message"], title: 'Error', type: SnackBarType.error);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  // ── Category from Main Cat ID ──────────────────────────────────────────────

  UrgentCategoryFromMainCategoryListModel? _categoryFromMainCategoryListModel;
  UrgentCategoryFromMainCategoryListModel? get categoryFromMainCategoryListModel =>
      _categoryFromMainCategoryListModel;

  void setUrgentAddOnCatModel(UrgentCategoryFromMainCategoryListModel data) {
    _categoryFromMainCategoryListModel = data;
    notifyListeners();
  }

  Future<void> getCategoryFromMainCatIdApi(
      context, {
        required String mainCatId,
      }) async {
    _categoryFromMainCategoryListModel = null;
    notifyListeners();

    final data = {"maincatid": mainCatId}; // ← CHANGED: dynamic id
    try {
      final value =
      await _urgentAddInventoryRepo.categoryFromMainCategoryListApi(data);
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final model =
        UrgentCategoryFromMainCategoryListModel.fromJson(body);
        setUrgentAddOnCatModel(model);
      } else {
        CustomSnackBar.show(context,
            message: body["message"], title: 'Error', type: SnackBarType.error);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  // ── Add-On Inventory ───────────────────────────────────────────────────────

  bool _addLoading = false;
  bool get addLoading => _addLoading;

  void _setAddLoading(bool value) {
    _addLoading = value;
    notifyListeners();
  }

  // ← CHANGED: accepts dynamic items list built from the cart
  Future<void> addOnInventoryApi( BuildContext context, {
    required List<Map<String, dynamic>> items,
  }) async {
    if (!context.mounted) return;
    _setAddLoading(true);
    final data = {
      "items": items,
      //   "items": [
      // {
      // "productid": e.selectedProduct!.productId,
      // "qty": int.tryParse(e.qtyController.text) ?? 1,
      // };
      //   ],
      "remarks": "Stock needed urgently",

    };

    try {
      final response = await _urgentAddInventoryRepo.requestAddOnInventoryApi(data);

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
      _setAddLoading(false);
    }
  }
}