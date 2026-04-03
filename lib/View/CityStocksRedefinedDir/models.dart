// ─────────────────────────────────────────────
//  Models
// ─────────────────────────────────────────────

class ProductVariant {
  final String id;
  final String label; // e.g. "200ml", "500ml", "1L"
  final int currentStock;
  final int minLevel;
  int requestedQty;

  ProductVariant({
    required this.id,
    required this.label,
    required this.currentStock,
    required this.minLevel,
    this.requestedQty = 0,
  });

  StockStatus get stockStatus {
    final ratio = currentStock / minLevel;
    if (ratio < 0.3) return StockStatus.critical;
    if (ratio < 0.6) return StockStatus.low;
    if (ratio < 1.0) return StockStatus.warn;
    return StockStatus.ok;
  }
}

enum StockStatus { critical, low, warn, ok }

class Product {
  final String id;
  final String name;
  final String sku;
  final String subCategoryId;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.subCategoryId,
    required this.variants,
  });

  int get totalStock => variants.fold(0, (s, v) => s + v.currentStock);
  int get totalMin => variants.fold(0, (s, v) => s + v.minLevel);
  StockStatus get overallStatus {
    if (variants.any((v) => v.stockStatus == StockStatus.critical)) return StockStatus.critical;
    if (variants.any((v) => v.stockStatus == StockStatus.low)) return StockStatus.low;
    if (variants.any((v) => v.stockStatus == StockStatus.warn)) return StockStatus.warn;
    return StockStatus.ok;
  }
}

class SubCategory {
  final String id;
  final String name;
  final String emoji;
  final String categoryId;

  SubCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.categoryId,
  });
}

class Category {
  final String id;
  final String name;
  final String emoji;
  final String mainCategoryId;
  final String colorHex;

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.mainCategoryId,
    required this.colorHex,
  });
}

class MainCategory {
  final String id;
  final String name;
  final String emoji;
  final String bgColorHex;

  MainCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bgColorHex,
  });
}

// ── Cart ──
class CartItem {
  final String productId;
  final String productName;
  final String variantId;
  final String variantLabel;
  final String subCategory;
  int qty;

  CartItem({
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.variantLabel,
    required this.subCategory,
    required this.qty,
  });
}

// ── Request ──
enum RequestPriority { normal, urgent, critical }
enum RequestStatus { pending, approved, rejected, partial }

class RequestItem {
  final String name;
  final int qty;

  RequestItem({required this.name, required this.qty});
}

class StockRequest {
  final String id;
  final DateTime date;
  RequestStatus status;
  final RequestPriority priority;
  final List<RequestItem> items;
  final String note;

  StockRequest({
    required this.id,
    required this.date,
    required this.status,
    required this.priority,
    required this.items,
    this.note = '',
  });
}

// ── Incoming Shipment ──
enum ShipmentStatus { pending, inTransit, arrived, confirmed }

class ShipmentItem {
  final String productName;
  final String variantLabel;
  final int expectedQty;
  int? receivedQty;
  int? damagedQty;
  int? missingQty;

  ShipmentItem({
    required this.productName,
    required this.variantLabel,
    required this.expectedQty,
    this.receivedQty,
    this.damagedQty,
    this.missingQty,
  });
}

class IncomingShipment {
  final String id;
  final String requestId;
  final DateTime dispatchDate;
  ShipmentStatus status;
  final List<ShipmentItem> items;
  String? note;

  IncomingShipment({
    required this.id,
    required this.requestId,
    required this.dispatchDate,
    required this.status,
    required this.items,
    this.note,
  });
}
