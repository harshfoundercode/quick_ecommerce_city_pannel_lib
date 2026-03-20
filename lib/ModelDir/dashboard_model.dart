class DashboardDetailsModel {
  String? message;
  DashboardDetailsData? data;

  DashboardDetailsModel({this.message, this.data});

  DashboardDetailsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? DashboardDetailsData.fromJson(json['data']) : null;
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

class DashboardDetailsData {
  Summary? summary;
  List<Hubs>? hubs;
  // List<Null>? revenueChart;
  // List<Null>? recentDisputes;

  DashboardDetailsData({this.summary,
    this.hubs,
    // this.revenueChart,
    // this.recentDisputes
  });

  DashboardDetailsData.fromJson(Map<String, dynamic> json) {
    summary =
    json['summary'] != null ? Summary.fromJson(json['summary']) : null;
    if (json['hubs'] != null) {
      hubs = <Hubs>[];
      json['hubs'].forEach((v) {
        hubs!.add(Hubs.fromJson(v));
      });
    }
    // if (json['revenue_chart'] != null) {
    //   revenueChart = <Null>[];
    //   json['revenue_chart'].forEach((v) {
    //     revenueChart!.add(new Null.fromJson(v));
    //   });
    // }
    // if (json['recent_disputes'] != null) {
    //   recentDisputes = <Null>[];
    //   json['recent_disputes'].forEach((v) {
    //     recentDisputes!.add(new Null.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (hubs != null) {
      data['hubs'] = hubs!.map((v) => v.toJson()).toList();
    }
    // if (this.revenueChart != null) {
    //   data['revenue_chart'] =
    //       this.revenueChart!.map((v) => v.toJson()).toList();
    // }
    // if (this.recentDisputes != null) {
    //   data['recent_disputes'] =
    //       this.recentDisputes!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class Summary {
  dynamic cityName;
  dynamic totalHubs;
  dynamic deliveryBoys;
  dynamic activeOrders;
  dynamic totalOrders;
  dynamic deliveredOrders;
  dynamic pendingOrders;
  dynamic revenue;

  Summary(
      {this.cityName,
        this.totalHubs,
        this.deliveryBoys,
        this.activeOrders,
        this.totalOrders,
        this.deliveredOrders,
        this.pendingOrders,
        this.revenue});

  Summary.fromJson(Map<String, dynamic> json) {
    cityName = json['city_name'];
    totalHubs = json['total_hubs'];
    deliveryBoys = json['delivery_boys'];
    activeOrders = json['active_orders'];
    totalOrders = json['total_orders'];
    deliveredOrders = json['delivered_orders'];
    pendingOrders = json['pending_orders'];
    revenue = json['revenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city_name'] = cityName;
    data['total_hubs'] = totalHubs;
    data['delivery_boys'] = deliveryBoys;
    data['active_orders'] = activeOrders;
    data['total_orders'] = totalOrders;
    data['delivered_orders'] = deliveredOrders;
    data['pending_orders'] = pendingOrders;
    data['revenue'] = revenue;
    return data;
  }
}

class Hubs {
  dynamic hubId;
  dynamic hubName;
  dynamic address;
  dynamic deliveryBoys;
  dynamic inProgress;
  dynamic completedToday;
  dynamic status;

  Hubs(
      {this.hubId,
        this.hubName,
        this.address,
        this.deliveryBoys,
        this.inProgress,
        this.completedToday,
        this.status});

  Hubs.fromJson(Map<String, dynamic> json) {
    hubId = json['hub_id'];
    hubName = json['hub_name'];
    address = json['address'];
    deliveryBoys = json['delivery_boys'];
    inProgress = json['in_progress'];
    completedToday = json['completed_today'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hub_id'] = hubId;
    data['hub_name'] = hubName;
    data['address'] = address;
    data['delivery_boys'] = deliveryBoys;
    data['in_progress'] = inProgress;
    data['completed_today'] = completedToday;
    data['status'] = status;
    return data;
  }
}
