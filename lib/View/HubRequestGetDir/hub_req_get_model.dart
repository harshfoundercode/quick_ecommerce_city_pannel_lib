// ════════════════════════════════════════════════════════════════════════════
// HUB REQUEST MODEL
// ════════════════════════════════════════════════════════════════════════════

class HubRequestListModel {
  bool? success;
  String? message;
  HubRequestData? data;

  HubRequestListModel({this.success, this.message, this.data});

  factory HubRequestListModel.fromJson(Map<String, dynamic> json) {
    return HubRequestListModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? HubRequestData.fromJson(json['data']) : null,
    );
  }
}

class HubRequestData {
  List<HubRequest>? requests;

  HubRequestData({this.requests});

  factory HubRequestData.fromJson(Map<String, dynamic> json) {
    return HubRequestData(
      requests: json['requests'] != null
          ? (json['requests'] as List)
          .map((e) => HubRequest.fromJson(e))
          .toList()
          : null,
    );
  }
}

class HubRequest {
  dynamic requestId;
  dynamic hubId;
  String? hubName;
  String? cityName;
  String? status; // "pending" | "accepted" | "rejected"
  String? note;
  String? createdAt;
  List<RequestProduct>? products;

  HubRequest({
    this.requestId,
    this.hubId,
    this.hubName,
    this.cityName,
    this.status,
    this.note,
    this.createdAt,
    this.products,
  });

  factory HubRequest.fromJson(Map<String, dynamic> json) {
    return HubRequest(
      requestId: json['request_id'],
      hubId: json['hub_id'],
      hubName: json['hub_name'],
      cityName: json['city_name'],
      status: json['status'],
      note: json['note'],
      createdAt: json['created_at'],
      products: json['products'] != null
          ? (json['products'] as List)
          .map((e) => RequestProduct.fromJson(e))
          .toList()
          : null,
    );
  }

  int get totalQty =>
      products?.fold(0, (sum, p) => sum! + p.totalQty) ?? 0;

  int get totalVariants =>
      products?.fold(0, (sum, p) => sum! + (p.variants?.length ?? 0)) ?? 0;
}

class RequestProduct {
  dynamic productId;
  String? productName;
  String? productImg;
  String? sku;
  String? mainCategory;
  String? subCategory;
  List<RequestVariant>? variants;

  RequestProduct({
    this.productId,
    this.productName,
    this.productImg,
    this.sku,
    this.mainCategory,
    this.subCategory,
    this.variants,
  });

  factory RequestProduct.fromJson(Map<String, dynamic> json) {
    return RequestProduct(
      productId: json['product_id'],
      productName: json['product_name'],
      productImg: json['product_img'],
      sku: json['sku'],
      mainCategory: json['main_category'],
      subCategory: json['sub_category'],
      variants: json['variants'] != null
          ? (json['variants'] as List)
          .map((e) => RequestVariant.fromJson(e))
          .toList()
          : null,
    );
  }

  int get totalQty =>
      variants?.fold(0, (sum, v) => sum! + (int.tryParse(v.qty.toString()) ?? 0)) ?? 0;
}

class RequestVariant {
  dynamic variantId;
  String? variantName;
  dynamic qty;
  dynamic availableStock;

  RequestVariant({
    this.variantId,
    this.variantName,
    this.qty,
    this.availableStock,
  });

  factory RequestVariant.fromJson(Map<String, dynamic> json) {
    return RequestVariant(
      variantId: json['variant_id'],
      variantName: json['variant_name'],
      qty: json['qty'],
      availableStock: json['available_stock'],
    );
  }

  bool get isLowStock {
    final q = int.tryParse(qty.toString()) ?? 0;
    final s = int.tryParse(availableStock.toString()) ?? 0;
    return q > s;
  }
}