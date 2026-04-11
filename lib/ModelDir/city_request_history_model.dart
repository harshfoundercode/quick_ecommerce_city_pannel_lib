// class CityRequestHistoryModel {
//   String? message;
//   List<CityRequestHistoryData>? data;
//
//   CityRequestHistoryModel({this.message, this.data});
//
//   CityRequestHistoryModel.fromJson(Map<String, dynamic> json) {
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <CityRequestHistoryData>[];
//       json['data'].forEach((v) {
//         data!.add(CityRequestHistoryData.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['message'] = message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class CityRequestHistoryData {
//   dynamic id;
//   dynamic status;
//   dynamic remarks;
//   dynamic createdAt;
//   dynamic name;
//   dynamic quantity;
//
//   CityRequestHistoryData(
//       {this.id,
//         this.status,
//         this.remarks,
//         this.createdAt,
//         this.name,
//         this.quantity});
//
//   CityRequestHistoryData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     status = json['status'];
//     remarks = json['remarks'];
//     createdAt = json['created_at'];
//     name = json['name'];
//     quantity = json['quantity'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['status'] = status;
//     data['remarks'] = remarks;
//     data['created_at'] = createdAt;
//     data['name'] = name;
//     data['quantity'] = quantity;
//     return data;
//   }
// }

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
  dynamic requestId;
  dynamic status;
  dynamic remarks;
  dynamic createdAt;
  List<Products>? products;

  CityRequestHistoryData(
      {this.requestId,
        this.status,
        this.remarks,
        this.createdAt,
        this.products});

  CityRequestHistoryData.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id'];
    status = json['status'];
    remarks = json['remarks'];
    createdAt = json['created_at'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_id'] = requestId;
    data['status'] = status;
    data['remarks'] = remarks;
    data['created_at'] = createdAt;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  dynamic productId;
  dynamic productName;
  dynamic productImg;
  dynamic brandName;
  dynamic brandImg;
  dynamic requestedQuantity;
  List<Variants>? variants;

  Products(
      {this.productId,
        this.productName,
        this.productImg,
        this.brandName,
        this.brandImg,
        this.requestedQuantity,
        this.variants});

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    productImg = json['product_img'];
    brandName = json['brand_name'];
    brandImg = json['brand_img'];
    requestedQuantity = json['requested_quantity'];
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(Variants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['product_img'] = productImg;
    data['brand_name'] = brandName;
    data['brand_img'] = brandImg;
    data['requested_quantity'] = requestedQuantity;
    if (variants != null) {
      data['variants'] = variants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Variants {
  dynamic variantId;
  dynamic variantValue;
  dynamic sku;
  dynamic price;
  dynamic discountPrice;
  dynamic discountPercent;
  dynamic variantImg;
  dynamic currentStock;
  dynamic unitsSold;

  Variants(
      {this.variantId,
        this.variantValue,
        this.sku,
        this.price,
        this.discountPrice,
        this.discountPercent,
        this.variantImg,
        this.currentStock,
        this.unitsSold});

  Variants.fromJson(Map<String, dynamic> json) {
    variantId = json['variant_id'];
    variantValue = json['variant_value'];
    sku = json['sku'];
    price = json['price'];
    discountPrice = json['discount_price'];
    discountPercent = json['discount_percent'];
    variantImg = json['variant_img'];
    currentStock = json['current_stock'];
    unitsSold = json['units_sold'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_id'] = variantId;
    data['variant_value'] = variantValue;
    data['sku'] = sku;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['discount_percent'] = discountPercent;
    data['variant_img'] = variantImg;
    data['current_stock'] = currentStock;
    data['units_sold'] = unitsSold;
    return data;
  }
}
