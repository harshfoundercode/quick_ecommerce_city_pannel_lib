class CityRequestHistoryModel {
  String? message;
  List<CityRequestHistoryData>? data;

  CityRequestHistoryModel({this.message, this.data});

  CityRequestHistoryModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <CityRequestHistoryData>[];
      json['data'].forEach((v) {
        data!.add(CityRequestHistoryData.fromJson(v));
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

class CityRequestHistoryData {
  dynamic id;
  dynamic status;
  dynamic remarks;
  dynamic createdAt;
  dynamic name;
  dynamic quantity;

  CityRequestHistoryData(
      {this.id,
        this.status,
        this.remarks,
        this.createdAt,
        this.name,
        this.quantity});

  CityRequestHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    remarks = json['remarks'];
    createdAt = json['created_at'];
    name = json['name'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['remarks'] = remarks;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['quantity'] = quantity;
    return data;
  }
}
