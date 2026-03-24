class CityHubHistoryModel {
  final String? message;
  final List<CityHubHistoryData>? data;

  CityHubHistoryModel({this.message, this.data});

  factory CityHubHistoryModel.fromJson(Map<String, dynamic> json) {
    return CityHubHistoryModel(
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CityHubHistoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CityHubHistoryData {
  final int? hubId;
  final String? hubName;
  final int? productId;
  final String? productName;
  final int? variantId;
  final String? variant;
  final int? hubCurrentStock;
  final int totalSent;

  CityHubHistoryData({
    this.hubId,
    this.hubName,
    this.productId,
    this.productName,
    this.variantId,
    this.variant,
    this.hubCurrentStock,
    required this.totalSent,
  });

  factory CityHubHistoryData.fromJson(Map<String, dynamic> json) {
    return CityHubHistoryData(
      hubId: json['hub_id'],
      hubName: json['hub_name'],
      productId: json['productid'],
      productName: json['product_name'],
      variantId: json['variantid'],
      variant: json['variant'],
      hubCurrentStock: json['hub_current_stock'],
      totalSent: int.tryParse(json['total_sent']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Grouped model for UI
class HubGroup {
  final int hubId;
  final String hubName;
  final List<CityHubHistoryData> items;

  HubGroup({
    required this.hubId,
    required this.hubName,
    required this.items,
  });

  bool get hasProducts => items.any((i) => i.productId != null);
  int get totalStockSent => items.fold(
    0,
        (s, i) => s + (int.tryParse(i.totalSent.toString()) ?? 0),
  );
  int get totalCurrentStock =>
      items.fold(0, (s, i) => s + (int.tryParse(i.hubCurrentStock.toString()) ?? 0));
  int get productCount =>
      items.where((i) => i.productId != null).length;

  /// Groups items by product name for variant rows
  Map<String, List<CityHubHistoryData>> get byProduct {
    final Map<String, List<CityHubHistoryData>> map = {};
    for (final item in items) {
      if (item.productId == null) continue;
      map.putIfAbsent(item.productName ?? 'Unknown', () => []).add(item);
    }
    return map;
  }
}