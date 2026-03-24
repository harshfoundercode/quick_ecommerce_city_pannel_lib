import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_order_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_view_order_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/hub_performance_repo.dart';

class HubPerformanceViewModel extends ChangeNotifier {
  final _hubPerformanceRepo = HubPerformanceRepo();

  HubPerformanceModel? _hubPerformanceModel;
  HubPerformanceModel? get hubPerformanceModel => _hubPerformanceModel;

  void setHubPerformanceDataModel(HubPerformanceModel data) {
    _hubPerformanceModel = data;
    notifyListeners();
  }

  Future<void> getHubPerformanceDataApi(context) async {
    _hubPerformanceModel = null;
    notifyListeners();
    try {
      final value = await _hubPerformanceRepo.hubPerformanceApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final hubPerformanceModel = HubPerformanceModel.fromJson(body);
        setHubPerformanceDataModel(hubPerformanceModel);
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

  /// =============== HUB PERFORMANCE ORDERS LIST ===========================

  HubPerformanceOrderListModel? _hubPerformanceOrderListModel;
  HubPerformanceOrderListModel? get hubPerformanceOrderListModel =>
      _hubPerformanceOrderListModel;

  List<HubPerformanceOrderListData> _allOrders = [];
  List<HubPerformanceOrderListData> _filteredOrders = [];

  List<HubPerformanceOrderListData> get orders => _filteredOrders;

  String _searchQuery = '';
  String _selectedFilter = 'All';

  String get selectedFilter => _selectedFilter;

  HubPerformanceOrderListData? selectedOrder;

  void setHubPerformanceOrderListDataModel(
      HubPerformanceOrderListModel data) {
    _hubPerformanceOrderListModel = data;

    _allOrders = data.data ?? [];
    _applyFilters();
  }

  /// 🔍 SEARCH
  void updateSearch(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  /// 🎯 FILTER
  void updateFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters();
  }

  /// 👉 SELECT ORDER
  Future<void> selectOrder(BuildContext context, HubPerformanceOrderListData order) async {
    selectedOrder = order;
    notifyListeners();

    /// 🔥 CALL DETAILS API
    await getHubPerformanceOrderDetailsDataApi(
      context,
      order.orderId.toString(),
    );
  }

  /// 🧠 CORE LOGIC
  void _applyFilters() {
    _filteredOrders = _allOrders.where((order) {
      final id = (order.orderNo ?? "").toString().toLowerCase();
      final customer =
      (order.customerName ?? "").toString().toLowerCase();
      final status =
      (order.statusText ?? "").toString().toLowerCase();

      final matchesSearch =
          id.contains(_searchQuery) || customer.contains(_searchQuery);

      final matchesFilter = _selectedFilter == 'All'
          ? true
          : status == _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();

    notifyListeners();
  }

  Future<void> getHubPerformanceOrderListDataApi(context,String hubId) async {
    _hubPerformanceOrderListModel = null;
    notifyListeners();
    try {
      final value = await _hubPerformanceRepo.hubPerformanceOrderListApi(hubId);
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final hubPerformanceOrderModel = HubPerformanceOrderListModel.fromJson(body);
        setHubPerformanceOrderListDataModel(hubPerformanceOrderModel);
        _allOrders = hubPerformanceOrderModel.data ?? [];
        _applyFilters();
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


  ///=============== HUB PERFORMANCE ORDER DETAILS VIEW API ===================


  HubPerformanceViewOrderDetailsModel? _hubPerformanceViewOrderDetailsModel;
  HubPerformanceViewOrderDetailsModel? get hubPerformanceViewOrderDetailsModel => _hubPerformanceViewOrderDetailsModel;

  void setHubPerformanceOrderDetailsDataModel(HubPerformanceViewOrderDetailsModel data) {
    _hubPerformanceViewOrderDetailsModel = data;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setIsLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> getHubPerformanceOrderDetailsDataApi(context,String orderId) async {
    setIsLoading(true);
    _hubPerformanceViewOrderDetailsModel = null;
    notifyListeners();
    try {
      final value = await _hubPerformanceRepo.hubPerformanceViewOrderListApi(orderId);
      setIsLoading(false);
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final hubPerformanceOrderDetailsModel = HubPerformanceViewOrderDetailsModel.fromJson(body);
        setHubPerformanceOrderDetailsDataModel(hubPerformanceOrderDetailsModel);
      } else {
        CustomSnackBar.show(
          context,
          message: body["message"],
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      setIsLoading(false);
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
