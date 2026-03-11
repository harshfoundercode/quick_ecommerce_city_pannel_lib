class OrderDataModel {
  String? message;
  OrderData? data;

  OrderDataModel({this.message, this.data});

  OrderDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? OrderData.fromJson(json['data']) : null;
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

class OrderData {
  dynamic total;
  dynamic placed;
  dynamic confirmed;
  dynamic picked;
  dynamic outForDelivery;
  dynamic completed;
  dynamic cancelled;
  dynamic totalRevenue;
  dynamic selectedType;
  List<Orders>? orders;

  OrderData(
      {this.total,
        this.placed,
        this.confirmed,
        this.picked,
        this.outForDelivery,
        this.completed,
        this.cancelled,
        this.totalRevenue,
        this.selectedType,
        this.orders});

  OrderData.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    placed = json['placed'];
    confirmed = json['confirmed'];
    picked = json['picked'];
    outForDelivery = json['out_for_delivery'];
    completed = json['completed'];
    cancelled = json['cancelled'];
    totalRevenue = json['total_revenue'];
    selectedType = json['selected_type'];
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['placed'] = placed;
    data['confirmed'] = confirmed;
    data['picked'] = picked;
    data['out_for_delivery'] = outForDelivery;
    data['completed'] = completed;
    data['cancelled'] = cancelled;
    data['total_revenue'] = totalRevenue;
    data['selected_type'] = selectedType;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  dynamic id;
  dynamic orderNo;
  dynamic totalAmount;
  dynamic status;
  dynamic createdAt;
  dynamic customerName;

  Orders(
      {this.id,
        this.orderNo,
        this.totalAmount,
        this.status,
        this.createdAt,
        this.customerName});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNo = json['order_no'];
    totalAmount = json['total_amount'];
    status = json['status'];
    createdAt = json['created_at'];
    customerName = json['customer_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_no'] = orderNo;
    data['total_amount'] = totalAmount;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['customer_name'] = customerName;
    return data;
  }
}
