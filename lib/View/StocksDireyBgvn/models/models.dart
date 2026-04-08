import 'package:flutter/material.dart';

// ─── CATEGORY MODEL ───────────────────────────────────────────────
class Category {
  final String id;
  final String name;
  final IconData icon;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.subCategories,
  });
}

class SubCategory {
  final String id;
  final String name;
  final String categoryId;

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
  });
}

// ─── PRODUCT VARIANT MODEL ─────────────────────────────────────────
class ProductVariant {
  final String id;
  final String name; // e.g. "Red / XL"
  final String sku;
  int stock;
  int reservedStock;
  final double price;

  ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.stock,
    required this.reservedStock,
    required this.price,
  });

  int get availableStock => stock - reservedStock;

  StockStatus get stockStatus {
    if (availableStock <= 0) return StockStatus.outOfStock;
    if (availableStock <= 10) return StockStatus.lowStock;
    return StockStatus.inStock;
  }
}

enum StockStatus { inStock, lowStock, outOfStock }

// ─── PRODUCT MODEL ─────────────────────────────────────────────────
class Product {
  final String id;
  final String name;
  final String categoryId;
  final String subCategoryId;
  final String imageUrl;
  final List<ProductVariant> variants;
  bool isSelected;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.subCategoryId,
    required this.imageUrl,
    required this.variants,
    this.isSelected = false,
  });

  int get totalStock => variants.fold(0, (sum, v) => sum + v.stock);
  int get totalAvailable => variants.fold(0, (sum, v) => sum + v.availableStock);
}

// ─── BULK STOCK REQUEST MODEL ──────────────────────────────────────
class BulkStockRequest {
  final String id;
  final DateTime createdAt;
  final String requestedBy;
  final List<StockRequestItem> items;
  RequestStatus status;
  String? note;

  BulkStockRequest({
    required this.id,
    required this.createdAt,
    required this.requestedBy,
    required this.items,
    this.status = RequestStatus.pending,
    this.note,
  });

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantityRequested);
}

class StockRequestItem {
  final String productId;
  final String productName;
  final String variantId;
  final String variantName;
  final int quantityRequested;

  StockRequestItem({
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.variantName,
    required this.quantityRequested,
  });
}

enum RequestStatus { pending, approved, rejected, fulfilled }

// ─── INCOMING STOCK MODEL ──────────────────────────────────────────
class IncomingStock {
  final String id;
  final String supplierName;
  final DateTime expectedDate;
  final List<IncomingStockItem> items;
  IncomingStatus status;
  DateTime? receivedDate;

  IncomingStock({
    required this.id,
    required this.supplierName,
    required this.expectedDate,
    required this.items,
    this.status = IncomingStatus.pending,
    this.receivedDate,
  });
}

class IncomingStockItem {
  final String id;
  final String productId;
  final String productName;
  final String variantId;
  final String variantName;
  final int expectedQty;
  int receivedQty;
  int defectiveQty;
  int missingQty;
  List<String> defectivePhotos;
  String? note;
  ItemStatus itemStatus;

  IncomingStockItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.variantName,
    required this.expectedQty,
    this.receivedQty = 0,
    this.defectiveQty = 0,
    this.missingQty = 0,
    List<String>? defectivePhotos,
    this.note,
    this.itemStatus = ItemStatus.pending,
  }) : defectivePhotos = defectivePhotos ?? [];
}

enum IncomingStatus { pending, partiallyReceived, received, disputed }
enum ItemStatus { pending, accepted, defective, missing }
