class HubPerformanceOrderListModel {
  String? message;
  List<HubPerformanceOrderListData>? data;

  HubPerformanceOrderListModel({this.message, this.data});

  HubPerformanceOrderListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <HubPerformanceOrderListData>[];
      json['data'].forEach((v) {
        data!.add(HubPerformanceOrderListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HubPerformanceOrderListData {
  dynamic orderId;
  dynamic orderNo;
  dynamic customerName;
  dynamic finalAmount;
  dynamic status;
  dynamic createdAt;
  dynamic statusText;

  HubPerformanceOrderListData(
      {this.orderId,
        this.orderNo,
        this.customerName,
        this.finalAmount,
        this.status,
        this.createdAt,
        this.statusText});

  HubPerformanceOrderListData.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderNo = json['order_no'];
    customerName = json['customer_name'];
    finalAmount = json['final_amount'];
    status = json['status'];
    createdAt = json['created_at'];
    statusText = json['status_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['order_no'] = orderNo;
    data['customer_name'] = customerName;
    data['final_amount'] = finalAmount;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['status_text'] = statusText;
    return data;
  }
}
