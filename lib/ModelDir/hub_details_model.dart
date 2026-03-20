class HubDetailsModel {
  String? message;
  HubDetailsData? data;

  HubDetailsModel({this.message, this.data});

  HubDetailsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? HubDetailsData.fromJson(json['data']) : null;
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

class HubDetailsData {
  Hub? hub;
  Performance? performance;
  Drivers? drivers;
  // List<Null>? topDeliveryBoys;
  // List<Null>? recentDisruptions;

  HubDetailsData(
      {this.hub,
        this.performance,
        this.drivers,
        // this.topDeliveryBoys,
        // this.recentDisruptions
      });

  HubDetailsData.fromJson(Map<String, dynamic> json) {
    hub = json['hub'] != null ? Hub.fromJson(json['hub']) : null;
    performance = json['performance'] != null
        ? Performance.fromJson(json['performance'])
        : null;
    drivers =
    json['drivers'] != null ? Drivers.fromJson(json['drivers']) : null;
    // if (json['top_delivery_boys'] != null) {
    //   topDeliveryBoys = <Null>[];
    //   json['top_delivery_boys'].forEach((v) {
    //     topDeliveryBoys!.add(new Null.fromJson(v));
    //   });
    // }
    // if (json['recent_disruptions'] != null) {
    //   recentDisruptions = <Null>[];
    //   json['recent_disruptions'].forEach((v) {
    //     recentDisruptions!.add(new Null.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (hub != null) {
      data['hub'] = hub!.toJson();
    }
    if (performance != null) {
      data['performance'] = performance!.toJson();
    }
    if (drivers != null) {
      data['drivers'] = drivers!.toJson();
    }
    // if (this.topDeliveryBoys != null) {
    //   data['top_delivery_boys'] =
    //       this.topDeliveryBoys!.map((v) => v.toJson()).toList();
    // }
    // if (this.recentDisruptions != null) {
    //   data['recent_disruptions'] =
    //       this.recentDisruptions!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class Hub {
  dynamic id;
  dynamic managerName;
  dynamic managerPhone;
  dynamic hubName;
  dynamic address;
  dynamic cityName;

  Hub(
      {this.id,
        this.managerName,
        this.managerPhone,
        this.hubName,
        this.address,
        this.cityName});

  Hub.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    managerName = json['manager_name'];
    managerPhone = json['manager_phone'];
    hubName = json['hub_name'];
    address = json['address'];
    cityName = json['city_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['manager_name'] = managerName;
    data['manager_phone'] = managerPhone;
    data['hub_name'] = hubName;
    data['address'] = address;
    data['city_name'] = cityName;
    return data;
  }
}

class Performance {
  dynamic totalOrders;
  dynamic completedDeliveries;
  dynamic cancelledOrders;
  dynamic successRate;
  dynamic avgDeliveryTime;
  dynamic cancellationRate;

  Performance(
      {this.totalOrders,
        this.completedDeliveries,
        this.cancelledOrders,
        this.successRate,
        this.avgDeliveryTime,
        this.cancellationRate});

  Performance.fromJson(Map<String, dynamic> json) {
    totalOrders = json['total_orders'];
    completedDeliveries = json['completed_deliveries'];
    cancelledOrders = json['cancelled_orders'];
    successRate = json['success_rate'];
    avgDeliveryTime = json['avg_delivery_time'];
    cancellationRate = json['cancellation_rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_orders'] = totalOrders;
    data['completed_deliveries'] = completedDeliveries;
    data['cancelled_orders'] = cancelledOrders;
    data['success_rate'] = successRate;
    data['avg_delivery_time'] = avgDeliveryTime;
    data['cancellation_rate'] = cancellationRate;
    return data;
  }
}

class Drivers {
  dynamic totalDeliveryBoys;
  dynamic activeBoys;

  Drivers({this.totalDeliveryBoys, this.activeBoys});

  Drivers.fromJson(Map<String, dynamic> json) {
    totalDeliveryBoys = json['total_delivery_boys'];
    activeBoys = json['active_boys'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_delivery_boys'] = totalDeliveryBoys;
    data['active_boys'] = activeBoys;
    return data;
  }
}
