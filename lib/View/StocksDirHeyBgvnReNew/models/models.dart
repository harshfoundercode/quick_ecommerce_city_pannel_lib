//
// // ─── CATEGORY MODEL ───────────────────────────────────────────────
// import 'package:flutter/material.dart';
//
// class Category {
//   final String id;
//   final String name;
//   final String icon;
//   final List<SubCategory> subCategories;
//   Category({
//     required this.id,
//     required this.name,
//     required this.icon,
//     required this.subCategories,
//   });
// }
//
// class SubCategory {
//   final String id;
//   final String name;
//   final String categoryId;
//   final String imageUrl;
//   SubCategory({required this.id, required this.name, required this.categoryId, required this.imageUrl});
// }
//
// // ─── PRODUCT VARIANT MODEL ─────────────────────────────────────────
// class ProductVariant {
//   final String id;
//   final String name;
//   final String sku;
//   int stock;
//   int reservedStock;
//   final double price;
//   ProductVariant({
//     required this.id,
//     required this.name,
//     required this.sku,
//     required this.stock,
//     required this.reservedStock,
//     required this.price,
//   });
//   int get availableStock => stock - reservedStock;
//   StockStatus get stockStatus {
//     if (availableStock <= 0) return StockStatus.outOfStock;
//     if (availableStock <= 10) return StockStatus.lowStock;
//     return StockStatus.inStock;
//   }
// }
//
// enum StockStatus { inStock, lowStock, outOfStock }
//
// //─── PRODUCT MODEL ─────────────────────────────────────────────────
// class Product {
//   final String id;
//   final String name;
//   final String categoryId;
//   final String subCategoryId;
//   final String imageUrl;
//   final List<ProductVariant> variants;
//   bool isSelected;
//   Product({
//     required this.id,
//     required this.name,
//     required this.categoryId,
//     required this.subCategoryId,
//     required this.imageUrl,
//     required this.variants,
//     this.isSelected = false,
//   });
//   int get totalStock => variants.fold(0, (sum, v) => sum + v.stock);
//   int get totalAvailable => variants.fold(0, (sum, v) => sum + v.availableStock);
// }
//
//
