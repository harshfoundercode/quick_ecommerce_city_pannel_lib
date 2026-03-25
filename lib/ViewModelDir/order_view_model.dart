import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/utils.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/order_view_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/orders_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/orders_repo.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart';
import '../ConstDir/tost_msg/custom_snackbar.dart';

class OrderDetailsViewModel extends ChangeNotifier {

  final OrdersRepo _ordersRepo = OrdersRepo();

  OrderDataModel? _orderDataModel;
  OrderDataModel? get orderDataModel => _orderDataModel;

  void setOrderListDataModel(OrderDataModel data) {
    _orderDataModel = data;
    notifyListeners();
  }

  Future<void> getOrdersListDataApi(context) async {
    _orderDataModel = null;
    notifyListeners();
    final userPref = Provider.of<UserViewModel>(context, listen: false);
    final authModel = await userPref.getUser();
    final data ={
      "citymanagerid":authModel.id.toString(),
      "type":""
    };
    try {
      final value = await _ordersRepo.ordersListApi(data);
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final orderDataModel = OrderDataModel.fromJson(body);
        setOrderListDataModel(orderDataModel);
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


  ///============================= ORDER VIEW DETAILS API  =====================


  OrderViewDataModel? _orderViewDataModel;
  OrderViewDataModel? get orderViewDataModel => _orderViewDataModel;

  void setOrderViewDetailsDetailsModel(OrderViewDataModel homeData) {
    _orderViewDataModel = homeData;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setIsLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> orderDetailsApi(context,String orderId, {bool showLoader = false,}) async {
    if (showLoader) setIsLoading(true);
    _orderViewDataModel = null;
    notifyListeners();
    final data = {
      "id": orderId
    };
    try {
      final response = await _ordersRepo.ordersViewDetailsApi(data);
      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200) {
        final ordersDetailsModel = OrderViewDataModel.fromJson(body);
        setOrderViewDetailsDetailsModel(ordersDetailsModel);
      } else if (statusCode == 400) {
        Utils.show(body['message'], context);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Category Subcategory Product details error: $e');
      if (context.mounted) {
        Utils.show('Something went wrong', context);
      }
    } finally {
      setIsLoading(false);
    }
  }
}

