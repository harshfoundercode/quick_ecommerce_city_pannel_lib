class HubListModel {
  String? message;
  HubListData? data;

  HubListModel({this.message, this.data});

  HubListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? HubListData.fromJson(json['data']) : null;
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

class HubListData {
  Summary? summary;
  List<Hubs>? hubs;

  HubListData({this.summary, this.hubs});

  HubListData.fromJson(Map<String, dynamic> json) {
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
  dynamic totalHubs;
  dynamic activeHubs;
  dynamic totalDeliveryBoys;
  dynamic totalActiveOrders;

  Summary(
      {this.totalHubs,
        this.activeHubs,
        this.totalDeliveryBoys,
        this.totalActiveOrders});

  Summary.fromJson(Map<String, dynamic> json) {
    totalHubs = json['total_hubs'];
    activeHubs = json['active_hubs'];
    totalDeliveryBoys = json['total_delivery_boys'];
    totalActiveOrders = json['total_active_orders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_hubs'] = totalHubs;
    data['active_hubs'] = activeHubs;
    data['total_delivery_boys'] = totalDeliveryBoys;
    data['total_active_orders'] = totalActiveOrders;
    return data;
  }
}

class Hubs {
  dynamic hubId;
  dynamic hubName;
  dynamic address;
  dynamic managerName;
  dynamic managerPhone;
  dynamic status;
  dynamic deliveryBoys;
  dynamic activeOrders;
  dynamic completedOrders;

  Hubs(
      {this.hubId,
        this.hubName,
        this.address,
        this.managerName,
        this.managerPhone,
        this.status,
        this.deliveryBoys,
        this.activeOrders,
        this.completedOrders});

  Hubs.fromJson(Map<String, dynamic> json) {
    hubId = json['hub_id'];
    hubName = json['hub_name'];
    address = json['address'];
    managerName = json['manager_name'];
    managerPhone = json['manager_phone'];
    status = json['status'];
    deliveryBoys = json['delivery_boys'];
    activeOrders = json['active_orders'];
    completedOrders = json['completed_orders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hub_id'] = hubId;
    data['hub_name'] = hubName;
    data['address'] = address;
    data['manager_name'] = managerName;
    data['manager_phone'] = managerPhone;
    data['status'] = status;
    data['delivery_boys'] = deliveryBoys;
    data['active_orders'] = activeOrders;
    data['completed_orders'] = completedOrders;
    return data;
  }
}
