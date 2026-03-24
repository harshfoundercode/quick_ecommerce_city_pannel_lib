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
  List<RevenueChart>? revenueChart;
  List<RecentDisputes>? recentDisputes;

  DashboardDetailsData({this.summary, this.hubs, this.revenueChart, this.recentDisputes});

  DashboardDetailsData.fromJson(Map<String, dynamic> json) {
    summary =
    json['summary'] != null ? Summary.fromJson(json['summary']) : null;
    if (json['hubs'] != null) {
      hubs = <Hubs>[];
      json['hubs'].forEach((v) {
        hubs!.add(Hubs.fromJson(v));
      });
    }
    if (json['revenue_chart'] != null) {
      revenueChart = <RevenueChart>[];
      json['revenue_chart'].forEach((v) {
        revenueChart!.add(RevenueChart.fromJson(v));
      });
    }
    if (json['recent_disputes'] != null) {
      recentDisputes = <RecentDisputes>[];
      json['recent_disputes'].forEach((v) {
        recentDisputes!.add(RecentDisputes.fromJson(v));
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
    if (revenueChart != null) {
      data['revenue_chart'] =
          revenueChart!.map((v) => v.toJson()).toList();
    }
    if (recentDisputes != null) {
      data['recent_disputes'] =
          recentDisputes!.map((v) => v.toJson()).toList();
    }
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
  dynamic status;
  dynamic deliveryBoys;
  dynamic inProgress;
  dynamic completedToday;
  dynamic revenue;

  Hubs(
      {this.hubId,
        this.hubName,
        this.address,
        this.status,
        this.deliveryBoys,
        this.inProgress,
        this.completedToday,
        this.revenue});

  Hubs.fromJson(Map<String, dynamic> json) {
    hubId = json['hub_id'];
    hubName = json['hub_name'];
    address = json['address'];
    status = json['status'];
    deliveryBoys = json['delivery_boys'];
    inProgress = json['in_progress'];
    completedToday = json['completed_today'];
    revenue = json['revenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hub_id'] = hubId;
    data['hub_name'] = hubName;
    data['address'] = address;
    data['status'] = status;
    data['delivery_boys'] = deliveryBoys;
    data['in_progress'] = inProgress;
    data['completed_today'] = completedToday;
    data['revenue'] = revenue;
    return data;
  }
}

class RevenueChart {
  dynamic day;
  dynamic revenue;

  RevenueChart({this.day, this.revenue});

  RevenueChart.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    revenue = json['revenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['revenue'] = revenue;
    return data;
  }
}

class RecentDisputes {
  dynamic orderNo;
  dynamic userid;
  dynamic finalAmount;
  dynamic createdAt;

  RecentDisputes({this.orderNo, this.userid, this.finalAmount, this.createdAt});

  RecentDisputes.fromJson(Map<String, dynamic> json) {
    orderNo = json['order_no'];
    userid = json['userid'];
    finalAmount = json['final_amount'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_no'] = orderNo;
    data['userid'] = userid;
    data['final_amount'] = finalAmount;
    data['created_at'] = createdAt;
    return data;
  }
}
