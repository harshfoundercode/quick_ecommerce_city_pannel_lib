class HubPerformanceModel {
  String? message;
  HubPerformanceData? data;

  HubPerformanceModel({this.message, this.data});

  HubPerformanceModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? HubPerformanceData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class HubPerformanceData {
  Summary? summary;
  List<Hubs>? hubs;

  HubPerformanceData({this.summary, this.hubs});

  HubPerformanceData.fromJson(Map<String, dynamic> json) {
    summary =
    json['summary'] != null ? Summary.fromJson(json['summary']) : null;
    if (json['hubs'] != null) {
      hubs = <Hubs>[];
      json['hubs'].forEach((v) {
        hubs!.add(Hubs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (hubs != null) {
      data['hubs'] = hubs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Summary {
  dynamic totalDeliveries;
  dynamic avgSuccessRate;
  dynamic activeDeliveryBoys;
  dynamic totalHubs;

  Summary(
      {this.totalDeliveries,
        this.avgSuccessRate,
        this.activeDeliveryBoys,
        this.totalHubs});

  Summary.fromJson(Map<String, dynamic> json) {
    totalDeliveries = json['total_deliveries'];
    avgSuccessRate = json['avg_success_rate'];
    activeDeliveryBoys = json['active_delivery_boys'];
    totalHubs = json['total_hubs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_deliveries'] = totalDeliveries;
    data['avg_success_rate'] = avgSuccessRate;
    data['active_delivery_boys'] = activeDeliveryBoys;
    data['total_hubs'] = totalHubs;
    return data;
  }
}

class Hubs {
  dynamic hubId;
  dynamic hubName;
  dynamic totalOrders;
  dynamic deliveredOrders;
  dynamic successRate;
  dynamic avgDeliveryTime;
  dynamic activeBoys;

  Hubs(
      {this.hubId,
        this.hubName,
        this.totalOrders,
        this.deliveredOrders,
        this.successRate,
        this.avgDeliveryTime,
        this.activeBoys});

  Hubs.fromJson(Map<String, dynamic> json) {
    hubId = json['hub_id'];
    hubName = json['hub_name'];
    totalOrders = json['total_orders'];
    deliveredOrders = json['delivered_orders'];
    successRate = json['success_rate'];
    avgDeliveryTime = json['avg_delivery_time'];
    activeBoys = json['active_boys'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hub_id'] = hubId;
    data['hub_name'] = hubName;
    data['total_orders'] = totalOrders;
    data['delivered_orders'] = deliveredOrders;
    data['success_rate'] = successRate;
    data['avg_delivery_time'] = avgDeliveryTime;
    data['active_boys'] = activeBoys;
    return data;
  }
}
