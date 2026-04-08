import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/city_stock_repo.dart';


class AdminStockListRecieveViewModel extends ChangeNotifier {
  final CityStockListRepo _repo = CityStockListRepo();

  // ── State ─────────────────────────────────────────────────────────────────
  CityStockModel? _model;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All'; // filter chip
  StockFilter _stockFilter = StockFilter.all;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  StockFilter get stockFilter => _stockFilter;

  /// All products from API (unfiltered)
  List<CityStockData> get allProducts => _model?.data ?? [];

  /// Products after applying search + category + stock filter
  List<CityStockData> get filteredProducts {
    List<CityStockData> list = allProducts;

    // Search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return (p.productName?.toString().toLowerCase().contains(q) ?? false) ||
            (p.brandName?.toString().toLowerCase().contains(q) ?? false) ||
            (p.categoryName?.toString().toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      list = list
          .where((p) =>
      p.mainCategoryName?.toString() == _selectedCategory)
          .toList();
    }

    // Stock filter
    switch (_stockFilter) {
      case StockFilter.inStock:
        list = list.where((p) => (p.totalStock ?? 0) > 0).toList();
        break;
      case StockFilter.lowStock:
        list = list
            .where((p) =>
        (p.totalStock ?? 0) > 0 && (p.totalStock ?? 0) <= 10)
            .toList();
        break;
      case StockFilter.outOfStock:
        list = list.where((p) => (p.totalStock ?? 0) == 0).toList();
        break;
      case StockFilter.all:
        break;
    }

    return list;
  }

  /// Unique main-category names for filter chips
  List<String> get categoryFilters {
    final cats = allProducts
        .map((p) => p.mainCategoryName?.toString() ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    return ['All', ...cats];
  }

  // Summary stats
  int get totalProducts   => allProducts.length;
  int get inStockCount    => allProducts.where((p) => (p.totalStock ?? 0) > 0).length;
  int get outOfStockCount => allProducts.where((p) => (p.totalStock ?? 0) == 0).length;
  int get lowStockCount   =>
      allProducts.where((p) => (p.totalStock ?? 0) > 0 && (p.totalStock ?? 0) <= 10).length;
  int get totalUnits      =>
      allProducts.fold(0, (sum, p) => sum + ((p.totalStock ?? 0) as int));

  // ── Actions ───────────────────────────────────────────────────────────────

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setStockFilter(StockFilter filter) {
    _stockFilter = filter;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _stockFilter = StockFilter.all;
    notifyListeners();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchCityStock(context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with real API call
      final response = await _repo.cityStockListApi();
      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};
      if (statusCode == 200) {
        _model = CityStockModel.fromJson(body);
      }
    } catch (e) {
      if (kDebugMode) print('❌ fetchCityStock error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ── Stock filter enum ─────────────────────────────────────────────────────────

enum StockFilter { all, inStock, lowStock, outOfStock }

extension StockFilterLabel on StockFilter {
  String get label {
    switch (this) {
      case StockFilter.all:        return 'All';
      case StockFilter.inStock:    return 'In Stock';
      case StockFilter.lowStock:   return 'Low Stock';
      case StockFilter.outOfStock: return 'Out of Stock';
    }
  }
}