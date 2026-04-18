import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/incommin_stock_model.dart' show IncomingStatus, ItemStatus, IncomingStock;
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/transfer_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/main_catsubcat_all_data_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/providers/category_viewmodel.dart';

class StockProvider extends ChangeNotifier {

  final AllCityStockDataNewViewModel _apiViewModel = AllCityStockDataNewViewModel();

  // ─── DATA FROM API ───────────────────────────────────────────────────
  CityStocksFullModel? _cityStocksData;

  bool _isLoading = false;
  String? _error;

  // Getters
  CityStocksFullModel? get cityStocksData => _cityStocksData;
  List<CityStocksFullData> get mainCategories => _cityStocksData?.data ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  StockProvider() {
    _initIncoming();
    _setupViewModelListener();
  }

  /// Listen to ViewModel changes
  void _setupViewModelListener() {
    _apiViewModel.addListener(() {
      if (_apiViewModel.cityStockModel != null) {
        _cityStocksData = _apiViewModel.cityStockModel;
        _isLoading = false;
        _error = null;
        _resetSelection();
        notifyListeners();
      }
    });
  }

  /// Fetch data from API
  Future<void> fetchStockData(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiViewModel.getCityStockDataApi(context);
      // Data will be loaded automatically through listener
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch data: $e';
      notifyListeners();
    }
  }

  /// Refresh data
  Future<void> refreshData(BuildContext context) async {
    await fetchStockData(context);
  }

  // ─── SELECTION STATE FOR HIERARCHY ─────────────────────────────────
  int? _selectedMainCategoryIndex;
  int? _selectedCategoryIndex;
  int? _selectedSubCategoryIndex;

  int? get selectedMainCategoryIndex => _selectedMainCategoryIndex;
  int? get selectedCategoryIndex => _selectedCategoryIndex;
  int? get selectedSubCategoryIndex => _selectedSubCategoryIndex;

  // Get selected items
  CityStocksFullData? get selectedMainCategory {
    if (_selectedMainCategoryIndex != null && mainCategories.isNotEmpty) {
      return mainCategories[_selectedMainCategoryIndex!];
    }
    return null;
  }

  Categories? get selectedCategory {
    if (_selectedMainCategoryIndex != null &&
        _selectedCategoryIndex != null &&
        selectedMainCategory?.categories != null) {
      return selectedMainCategory!.categories![_selectedCategoryIndex!];
    }
    return null;
  }

  Subcategories? get selectedSubCategory {
    if (selectedCategory?.subcategories != null &&
        _selectedSubCategoryIndex != null) {
      return selectedCategory!.subcategories![_selectedSubCategoryIndex!];
    }
    return null;
  }

  // Get lists for current level
  List<Categories> get categoriesForSelectedMain {
    return selectedMainCategory?.categories ?? [];
  }

  List<Subcategories> get subcategoriesForSelectedCategory {
    return selectedCategory?.subcategories ?? [];
  }

  List<Products> get productsForSelectedSubCategory {
    return selectedSubCategory?.products ?? [];
  }

  // Selection methods
  void selectMainCategory(int index) {
    _selectedMainCategoryIndex = index;
    _selectedCategoryIndex = null;
    _selectedSubCategoryIndex = null;
    notifyListeners();
  }

  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    _selectedSubCategoryIndex = null;
    notifyListeners();
  }

  void selectSubCategory(int index) {
    _selectedSubCategoryIndex = index;
    notifyListeners();
  }

  void goBack() {
    if (_selectedSubCategoryIndex != null) {
      _selectedSubCategoryIndex = null;
    } else if (_selectedCategoryIndex != null) {
      _selectedCategoryIndex = null;
    } else if (_selectedMainCategoryIndex != null) {
      _selectedMainCategoryIndex = null;
    }
    notifyListeners();
  }

  void resetSelection() {
    _selectedMainCategoryIndex = null;
    _selectedCategoryIndex = null;
    _selectedSubCategoryIndex = null;
    _selectedProductIds.clear();
    notifyListeners();
  }

  // ─── PRODUCT SELECTION ─────────────────────────────────────────────
  final Set<String> _selectedProductIds = {};

  Set<String> get selectedProductIds => Set.unmodifiable(_selectedProductIds);

  List<Products> get selectedProducts {
    if (kDebugMode) {
      print('=== selectedProducts getter called ===');
      print('Selected IDs count: ${_selectedProductIds.length}');
      print('Selected IDs: $_selectedProductIds');
    }


    final allProducts = <Products>[];
    for (var mainCat in mainCategories) {
      for (var cat in mainCat.categories ?? []) {
        for (var subCat in cat.subcategories ?? []) {
          for (var product in subCat.products ?? []) {
            final productId = product.productId.toString();
            print('Checking product: $productId - ${product.name}');
            if (_selectedProductIds.contains(productId)) {
              print('✓ Found selected product: $productId');
              allProducts.add(product);
            }
          }
        }
      }
    }
    return allProducts;
  }

  void toggleProductSelection(String productId) {

    // Ensure productId is string
    final id = productId.toString();

    if (_selectedProductIds.contains(id)) {
      _selectedProductIds.remove(id);
    } else {
      _selectedProductIds.add(id);
    }

    notifyListeners();
  }


  void selectAllProductsInCurrentView() {
    for (var product in productsForSelectedSubCategory) {
      _selectedProductIds.add(product.productId.toString());
    }
    notifyListeners();
  }

  void clearProductSelection() {
    _selectedProductIds.clear();
    notifyListeners();
  }

  bool isProductSelected(String productId) {
    return _selectedProductIds.contains(productId);
  }

  void _resetSelection() {
    _selectedMainCategoryIndex = null;
    _selectedCategoryIndex = null;
    _selectedSubCategoryIndex = null;
    _selectedProductIds.clear();
  }

  // ─── SEARCH ────────────────────────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Products> get searchedProducts {
    if (_searchQuery.isEmpty) return [];

    final results = <Products>[];
    for (var mainCat in mainCategories) {
      for (var cat in mainCat.categories ?? []) {
        for (var subCat in cat.subcategories ?? []) {
          for (var product in subCat.products ?? []) {
            if (product.productName.toString().toLowerCase().contains(_searchQuery.toLowerCase())) {
              results.add(product);
            }
          }
        }
      }
    }
    return results;
  }

  // ─── STATISTICS ─────────────────────────────────────────────────────
  int get totalMainCategories => mainCategories.length;

  int get totalCategories {
    int count = 0;
    for (var mainCat in mainCategories) {
      count += mainCat.categories?.length ?? 0;
    }
    return count;
  }

  int get totalProducts => mainCategories.fold(
    0,
        (mainTotal, mainCat) =>
    mainTotal +
        (mainCat.categories ?? []).fold(
          0,
              (catTotal, cat) =>
          catTotal +
              (cat.subcategories ?? []).fold(
                0,
                    (subTotal, subCat) =>
                subTotal + (subCat.products?.length ?? 0),
              ),
        ),
  );


  int get totalStock {
    int stock = 0;
    for (var mainCat in mainCategories) {
      for (var cat in mainCat.categories ?? []) {
        for (var subCat in cat.subcategories ?? []) {
          for (var product in subCat.products ?? []) {
            stock += _parseInt(product.totalStock);
          }
        }
      }
    }
    return stock;
  }

  int get lowStockCount {
    int count = 0;
    for (var mainCat in mainCategories) {
      for (var cat in mainCat.categories ?? []) {
        for (var subCat in cat.subcategories ?? []) {
          for (var product in subCat.products ?? []) {
            final stock = _parseInt(product.totalStock);
            if (stock > 0 && stock <= 5) count++;
          }
        }
      }
    }
    return count;
  }

  int get outOfStockCount {
    int count = 0;
    for (var mainCat in mainCategories) {
      for (var cat in mainCat.categories ?? []) {
        for (var subCat in cat.subcategories ?? []) {
          for (var product in subCat.products ?? []) {
            if (_parseInt(product.totalStock) == 0) count++;
          }
        }
      }
    }
    return count;
  }

  // Helper parsing methods
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ─── BULK REQUESTS ──────────────────────────────────────────────────
  final List<BulkStockRequest> _bulkRequests = [];

  List<BulkStockRequest> get bulkRequests => List.unmodifiable(_bulkRequests);

  /// Create a bulk request from currently selected products
  Future<void> createBulkRequestFromSelected({
    required BuildContext context,
    String? note,
    TransferType transferType = TransferType.adminRequest,
    String? hubName,
  }) async {
    if (selectedProducts.isEmpty) {
      _showMessage(context, 'Please select at least one product', isError: true);
      return;
    }

    final items = <StockRequestItem>[];

    for (var product in selectedProducts) {
      for (var variant in product.variants ?? []) {
        items.add(StockRequestItem(
          productId: product.productId.toString(),
          productName: product.name?.toString() ?? 'Unknown',
          variantId: variant.variantId.toString(),
          variantName: variant.value?.toString() ?? 'Default',
          quantityRequested: _calculateRequestedQuantity(variant),
        ));
      }
    }

    submitBulkRequest(
      items: items,
      note: note ?? 'Bulk request for ${selectedProducts.length} products',
      transferType: transferType,
      hubName: hubName,
    );

    clearProductSelection();
    _showMessage(context, 'Bulk request created successfully for ${selectedProducts.length} products');
  }

  int _calculateRequestedQuantity(Variants variant) {
    final currentStock = _parseInt(variant.stock);
    if (currentStock == 0) return 10;
    if (currentStock <= 5) return 20 - currentStock;
    return 0;
  }

  Map<String, dynamic> getBulkRequestSummary() {
    final summary = <String, dynamic>{
      'totalProducts': selectedProducts.length,
      'totalVariants': 0,
      'totalQuantity': 0,
      'outOfStockCount': 0,
      'lowStockCount': 0,
      'products': <Map<String, dynamic>>[],
    };

    for (var product in selectedProducts) {
      final productSummary = <String, dynamic>{
        'productId': product.productId.toString(),
        'productName': product.name?.toString() ?? 'Unknown',
        'image': product.img?.toString() ?? '',
        'variants': <Map<String, dynamic>>[],
      };

      for (var variant in product.variants ?? []) {
        final quantity = _calculateRequestedQuantity(variant);
        final stock = _parseInt(variant.stock);

        if (quantity > 0) {
          summary['totalVariants'] += 1;
          summary['totalQuantity'] += quantity;

          if (stock == 0) summary['outOfStockCount'] += 1;
          if (stock > 0 && stock <= 5) summary['lowStockCount'] += 1;

          (productSummary['variants'] as List).add({
            'variantId': variant.variantId.toString(),
            'variantName': variant.value?.toString() ?? 'Default',
            'currentStock': stock,
            'requestedQuantity': quantity,
            'price': _parseDouble(variant.price),
            'discountPrice': _parseDouble(variant.discountPrice),
          });
        }
      }

      if ((productSummary['variants'] as List).isNotEmpty) {
        (summary['products'] as List).add(productSummary);
      }
    }

    return summary;
  }

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void submitBulkRequest({
    required List<StockRequestItem> items,
    String? note,
    TransferType transferType = TransferType.adminRequest,
    String? hubName,
  }) {
    _bulkRequests.insert(0, BulkStockRequest(
      id: 'req${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      requestedBy: 'Admin',
      items: items,
      note: note,
      transferType: transferType,
      hubName: hubName,
    ));
    notifyListeners();
  }

  List<BulkStockRequest> get allBulkRequests => List.unmodifiable(_bulkRequests);

  List<BulkStockRequest> get pendingBulkRequests =>
      _bulkRequests.where((req) => req.status == RequestStatus.pending).toList();

  List<BulkStockRequest> get fulfilledBulkRequests =>
      _bulkRequests.where((req) => req.status == RequestStatus.fulfilled).toList();

  void updateBulkRequestStatus(String requestId, RequestStatus status) {
    final index = _bulkRequests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      _bulkRequests[index].status = status;
      notifyListeners();
    }
  }

  void deleteBulkRequest(String requestId) {
    _bulkRequests.removeWhere((req) => req.id == requestId);
    notifyListeners();
  }
  // ─── INCOMING STOCK ─────────────────────────────────────────────────
  List<IncomingStock> _incomingStocks = [];

  void _initIncoming() {
    _incomingStocks = [];
  }

  List<IncomingStock> get incomingStocks => List.unmodifiable(_incomingStocks);

  void loadIncomingStocks(List<IncomingStock> stocks) {
    _incomingStocks = stocks;
    notifyListeners();
  }

  void updateIncomingItem({
    required String incomingId,
    required String itemId,
    required int receivedQty,
    required int defectiveQty,
    required ItemStatus status,
    String? note,
    required int missingQty,
  }) {
    final stock = _incomingStocks.firstWhere((s) => s.id == incomingId);
    final item = stock.items.firstWhere((i) => i.id == itemId);

    final safeReceived = receivedQty.clamp(0, item.expectedQty);
    final safeDefective = defectiveQty.clamp(0, safeReceived);

    item.receivedQty = safeReceived;
    item.defectiveQty = safeDefective;
    item.itemStatus = status;
    item.note = note;

    final allDone = stock.items.every((i) => i.itemStatus != ItemStatus.pending);
    final hasIssue = stock.items.any((i) =>
    i.itemStatus == ItemStatus.defective ||
        i.itemStatus == ItemStatus.missing ||
        i.itemStatus == ItemStatus.mixed);

    if (allDone) {
      stock.status = hasIssue ? IncomingStatus.disputed : IncomingStatus.received;
    } else {
      stock.status = IncomingStatus.partiallyReceived;
    }

    notifyListeners();
  }

  void addDefectivePhoto(String incomingId, String itemId, String path) {
    final stock = _incomingStocks.firstWhere((s) => s.id == incomingId);
    final item = stock.items.firstWhere((i) => i.id == itemId);
    item.defectivePhotos.add(path);
    notifyListeners();
  }

  // ─── UTILITY METHODS ───────────────────────────────────────────────

  /// Get stock status text
  String getStockStatusText(dynamic stock) {
    final stockValue = _parseInt(stock);
    if (stockValue == 0) return 'Out of Stock';
    if (stockValue <= 5) return 'Low Stock';
    return 'In Stock';
  }

  /// Get stock status color
  Color getStockStatusColor(dynamic stock) {
    final stockValue = _parseInt(stock);
    if (stockValue == 0) return Colors.red;
    if (stockValue <= 5) return Colors.orange;
    return Colors.green;
  }

  /// Get variant stock status
  String getVariantStockStatusText(Variants variant) {
    final stock = _parseInt(variant.stock);
    if (stock == 0) return 'Out of Stock';
    if (stock <= 5) return 'Low Stock';
    return 'In Stock';
  }

  @override
  void dispose() {
    _apiViewModel.dispose();
    super.dispose();
  }
}