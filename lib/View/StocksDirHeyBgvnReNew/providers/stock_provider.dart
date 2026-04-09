import 'package:flutter/material.dart';
import '../models/models.dart';

class StockProvider extends ChangeNotifier {
  // ─── CATEGORIES ───────────────────────────────────────────────────
  final List<Category> categories = [
    Category(id: 'cat1', name: 'Electronics', icon: Icons.devices, subCategories: [
      SubCategory(id: 'sub1', name: 'Smartphones', categoryId: 'cat1'),
      SubCategory(id: 'sub2', name: 'Laptops', categoryId: 'cat1'),
      SubCategory(id: 'sub3', name: 'Accessories', categoryId: 'cat1'),
    ]),
    Category(id: 'cat2', name: 'Clothing', icon: Icons.checkroom, subCategories: [
      SubCategory(id: 'sub4', name: "Men's Wear", categoryId: 'cat2'),
      SubCategory(id: 'sub5', name: "Women's Wear", categoryId: 'cat2'),
      SubCategory(id: 'sub6', name: "Kids' Wear", categoryId: 'cat2'),
    ]),
    Category(id: 'cat3', name: 'Home & Kitchen', icon: Icons.kitchen, subCategories: [
      SubCategory(id: 'sub7', name: 'Cookware', categoryId: 'cat3'),
      SubCategory(id: 'sub8', name: 'Furniture', categoryId: 'cat3'),
    ]),
    Category(id: 'cat4', name: 'Sports', icon: Icons.sports_soccer, subCategories: [
      SubCategory(id: 'sub9', name: 'Fitness', categoryId: 'cat4'),
      SubCategory(id: 'sub10', name: 'Outdoor', categoryId: 'cat4'),
    ]),
  ];

  late List<Product> _products;

  StockProvider() {
    _initProducts();
    _initIncoming();
  }

  void _initProducts() {
    _products = [
      Product(id: 'p1', name: 'iPhone 15 Pro', categoryId: 'cat1', subCategoryId: 'sub1', imageUrl: '', variants: [
        ProductVariant(id: 'v1', name: '128GB / Black', sku: 'IP15-128-BLK', stock: 45, reservedStock: 10, price: 79999),
        ProductVariant(id: 'v2', name: '256GB / White', sku: 'IP15-256-WHT', stock: 8,  reservedStock: 2,  price: 89999),
        ProductVariant(id: 'v3', name: '512GB / Gold',  sku: 'IP15-512-GLD', stock: 0,  reservedStock: 0,  price: 109999),
      ]),
      Product(id: 'p2', name: 'Samsung Galaxy S24', categoryId: 'cat1', subCategoryId: 'sub1', imageUrl: '', variants: [
        ProductVariant(id: 'v4', name: '8GB / Phantom Black', sku: 'SGS24-8-BLK',  stock: 30, reservedStock: 5, price: 69999),
        ProductVariant(id: 'v5', name: '12GB / Cream',         sku: 'SGS24-12-CRM', stock: 5,  reservedStock: 1, price: 79999),
      ]),
      Product(id: 'p3', name: 'MacBook Pro M3', categoryId: 'cat1', subCategoryId: 'sub2', imageUrl: '', variants: [
        ProductVariant(id: 'v6', name: '8GB / 256GB',  sku: 'MBP-M3-8-256',  stock: 15, reservedStock: 3, price: 149999),
        ProductVariant(id: 'v7', name: '16GB / 512GB', sku: 'MBP-M3-16-512', stock: 7,  reservedStock: 0, price: 199999),
      ]),
      Product(id: 'p4', name: 'Premium T-Shirt', categoryId: 'cat2', subCategoryId: 'sub4', imageUrl: '', variants: [
        ProductVariant(id: 'v8',  name: 'S / Red',  sku: 'TSH-S-RED',  stock: 100, reservedStock: 20, price: 599),
        ProductVariant(id: 'v9',  name: 'M / Red',  sku: 'TSH-M-RED',  stock: 80,  reservedStock: 15, price: 599),
        ProductVariant(id: 'v10', name: 'L / Blue', sku: 'TSH-L-BLU',  stock: 3,   reservedStock: 1,  price: 599),
        ProductVariant(id: 'v11', name: 'XL / Blue',sku: 'TSH-XL-BLU', stock: 0,   reservedStock: 0,  price: 599),
      ]),
      Product(id: 'p5', name: 'Yoga Mat Premium', categoryId: 'cat4', subCategoryId: 'sub9', imageUrl: '', variants: [
        ProductVariant(id: 'v12', name: '6mm / Purple', sku: 'YGM-6-PRP', stock: 50, reservedStock: 5, price: 1299),
        ProductVariant(id: 'v13', name: '8mm / Black',  sku: 'YGM-8-BLK', stock: 9,  reservedStock: 2, price: 1499),
      ]),
      Product(id: 'p6', name: 'Non-Stick Cookware Set', categoryId: 'cat3', subCategoryId: 'sub7', imageUrl: '', variants: [
        ProductVariant(id: 'v14', name: '5-Piece Set', sku: 'CWR-5PC', stock: 25, reservedStock: 3, price: 3499),
        ProductVariant(id: 'v15', name: '8-Piece Set', sku: 'CWR-8PC', stock: 2,  reservedStock: 0, price: 4999),
      ]),
    ];
  }

  // ─── INVENTORY STATS (for overview screen) ────────────────────────
  int get totalCategories => categories.length;
  int get totalProducts   => _products.length;
  int get totalStock      => _products.fold(0, (s, p) => s + p.totalStock);

  int get lowStockCount {
    int count = 0;
    for (final p in _products) {
      for (final v in p.variants) {
        if (v.stockStatus == StockStatus.lowStock) count++;
      }
    }
    return count;
  }

  int get outOfStockCount {
    int count = 0;
    for (final p in _products) {
      for (final v in p.variants) {
        if (v.stockStatus == StockStatus.outOfStock) count++;
      }
    }
    return count;
  }

  // ─── FILTER STATE ─────────────────────────────────────────────────
  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  String _searchQuery = '';

  String? get selectedCategoryId    => _selectedCategoryId;
  String? get selectedSubCategoryId => _selectedSubCategoryId;

  List<Product> get filteredProducts => _products.where((p) {
    final mc = _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
    final ms = _selectedSubCategoryId == null || p.subCategoryId == _selectedSubCategoryId;
    final mq = _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    return mc && ms && mq;
  }).toList();

  /// All selected products regardless of current filter
  List<Product> get selectedProducts => _products.where((p) => p.isSelected).toList();

  void selectCategory(String? id)    { _selectedCategoryId = id; _selectedSubCategoryId = null; notifyListeners(); }
  void selectSubCategory(String? id) { _selectedSubCategoryId = id; notifyListeners(); }
  void setSearchQuery(String q)      { _searchQuery = q; notifyListeners(); }

  void toggleProductSelection(String productId) {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) { _products[idx].isSelected = !_products[idx].isSelected; notifyListeners(); }
  }

  void clearSelection() {
    for (var p in _products) p.isSelected = false;
    notifyListeners();
  }

  // ─── BULK REQUESTS ────────────────────────────────────────────────
  final List<BulkStockRequest> _bulkRequests = [
    BulkStockRequest(
      id: 'req1',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      requestedBy: 'Admin',
      status: RequestStatus.fulfilled,
      transferType: TransferType.adminRequest,
      items: [
        StockRequestItem(productId: 'p1', productName: 'iPhone 15 Pro',  variantId: 'v1', variantName: '128GB / Black', quantityRequested: 20),
        StockRequestItem(productId: 'p4', productName: 'Premium T-Shirt', variantId: 'v8', variantName: 'S / Red',       quantityRequested: 50),
      ],
      note: 'Festive season restock',
    ),
    BulkStockRequest(
      id: 'req2',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      requestedBy: 'Admin',
      status: RequestStatus.pending,
      transferType: TransferType.hubTransfer,
      hubName: 'Delhi Hub',
      items: [
        StockRequestItem(productId: 'p3', productName: 'MacBook Pro M3', variantId: 'v6', variantName: '8GB / 256GB', quantityRequested: 10),
      ],
      note: 'Delhi hub restock',
    ),
  ];

  List<BulkStockRequest> get bulkRequests => List.unmodifiable(_bulkRequests);

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
    // NOTE: We do NOT clear selection here — caller handles it.
    notifyListeners();
  }

  // ─── INCOMING STOCK ───────────────────────────────────────────────
  late List<IncomingStock> _incomingStocks;

  void _initIncoming() {
    _incomingStocks = [
      IncomingStock(
        id: 'inc1', supplierName: 'TechWorld Distributors',
        expectedDate: DateTime.now().add(const Duration(days: 1)),
        status: IncomingStatus.pending,
        items: [
          IncomingStockItem(id: 'ii1', productId: 'p1', productName: 'iPhone 15 Pro',     variantId: 'v3', variantName: '512GB / Gold', expectedQty: 15),
          IncomingStockItem(id: 'ii2', productId: 'p2', productName: 'Samsung Galaxy S24', variantId: 'v5', variantName: '12GB / Cream', expectedQty: 20),
        ],
      ),
      IncomingStock(
        id: 'inc2', supplierName: 'FashionHub Supplies',
        expectedDate: DateTime.now(),
        status: IncomingStatus.partiallyReceived,
        items: [
          IncomingStockItem(id: 'ii3', productId: 'p4', productName: 'Premium T-Shirt', variantId: 'v10', variantName: 'L / Blue', expectedQty: 100, receivedQty: 85, defectiveQty: 5,  itemStatus: ItemStatus.defective),
          IncomingStockItem(id: 'ii4', productId: 'p4', productName: 'Premium T-Shirt', variantId: 'v11', variantName: 'XL / Blue',expectedQty: 50,  receivedQty: 45, defectiveQty: 0,  itemStatus: ItemStatus.missing),
        ],
      ),
    ];
  }

  List<IncomingStock> get incomingStocks => List.unmodifiable(_incomingStocks);

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
    final item  = stock.items.firstWhere((i) => i.id == itemId);

    final safeReceived  = receivedQty.clamp(0, item.expectedQty);
    final safeDefective = defectiveQty.clamp(0, safeReceived);

    item.receivedQty  = safeReceived;
    item.defectiveQty = safeDefective;
    item.itemStatus   = status;
    item.note         = note;

    // Update product stock with only accepted (good) qty
    final goodQty = safeReceived - safeDefective;
    if (goodQty > 0) {
      final pIdx = _products.indexWhere((p) => p.id == item.productId);
      if (pIdx != -1) {
        final vIdx = _products[pIdx].variants.indexWhere((v) => v.id == item.variantId);
        if (vIdx != -1) _products[pIdx].variants[vIdx].stock += goodQty;
      }
    }

    // Update shipment-level status
    final allDone  = stock.items.every((i) => i.itemStatus != ItemStatus.pending);
    final hasIssue = stock.items.any((i) => i.itemStatus == ItemStatus.defective || i.itemStatus == ItemStatus.missing || i.itemStatus == ItemStatus.mixed);
    if (allDone) {
      stock.status = hasIssue ? IncomingStatus.disputed : IncomingStatus.received;
    } else {
      stock.status = IncomingStatus.partiallyReceived;
    }

    notifyListeners();
  }

  void addDefectivePhoto(String incomingId, String itemId, String path) {
    final stock = _incomingStocks.firstWhere((s) => s.id == incomingId);
    final item  = stock.items.firstWhere((i) => i.id == itemId);
    item.defectivePhotos.add(path);
    notifyListeners();
  }
}
