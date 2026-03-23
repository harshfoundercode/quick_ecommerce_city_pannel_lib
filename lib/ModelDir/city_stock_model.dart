class CityStockModel {
  String? message;
  List<CityStockData>? data;

  CityStockModel({this.message, this.data});

  CityStockModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <CityStockData>[];
      json['data'].forEach((v) {
        data!.add(CityStockData.fromJson(v));
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

class CityStockData {
  dynamic mainCategory;
  dynamic category;
  dynamic subCategory;
  dynamic productid;
  dynamic productName;
  dynamic variantid;
  dynamic variantName;
  dynamic currentStock;
  dynamic totalReceived;

  CityStockData(
      {this.mainCategory,
        this.category,
        this.subCategory,
        this.productid,
        this.productName,
        this.variantid,
        this.variantName,
        this.currentStock,
        this.totalReceived});

  CityStockData.fromJson(Map<String, dynamic> json) {
    mainCategory = json['main_category'];
    category = json['category'];
    subCategory = json['sub_category'];
    productid = json['productid'];
    productName = json['product_name'];
    variantid = json['variantid'];
    variantName = json['variant_name'];
    currentStock = json['current_stock'];
    totalReceived = json['total_received'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_category'] = mainCategory;
    data['category'] = category;
    data['sub_category'] = subCategory;
    data['productid'] = productid;
    data['product_name'] = productName;
    data['variantid'] = variantid;
    data['variant_name'] = variantName;
    data['current_stock'] = currentStock;
    data['total_received'] = totalReceived;
    return data;
  }
}
