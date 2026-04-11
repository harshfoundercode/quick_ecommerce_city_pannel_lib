class HubRequestListModel {
  String? message;
  List<Data>? data;

  HubRequestListModel({this.message, this.data});

  HubRequestListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  dynamic requestId;
  dynamic status;
  dynamic createdAt;
  Hubmanager? hubmanager;
  List<Products>? products;

  Data(
      {this.requestId,
        this.status,
        this.createdAt,
        this.hubmanager,
        this.products});

  Data.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id'];
    status = json['status'];
    createdAt = json['created_at'];
    hubmanager = json['hubmanager'] != null
        ? Hubmanager.fromJson(json['hubmanager'])
        : null;
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
    data['created_at'] = createdAt;
    if (hubmanager != null) {
      data['hubmanager'] = hubmanager!.toJson();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Hubmanager {
  dynamic id;
  dynamic name;

  Hubmanager({this.id, this.name});

  Hubmanager.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Products {
  dynamic productId;
  dynamic productName;
  dynamic productImg;
  dynamic categoryName;
  dynamic brandName;
  dynamic brandImg;
  dynamic requestedQuantity;
  List<Variants>? variants;

  Products(
      {this.productId,
        this.productName,
        this.productImg,
        this.categoryName,
        this.brandName,
        this.brandImg,
        this.requestedQuantity,
        this.variants});

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    productImg = json['product_img'];
    categoryName = json['category_name'];
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
    data['category_name'] = categoryName;
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

  Variants(
      {this.variantId,
        this.variantValue,
        this.sku,
        this.price,
        this.discountPrice,
        this.discountPercent,
        this.variantImg,
        this.currentStock});

  Variants.fromJson(Map<String, dynamic> json) {
    variantId = json['variant_id'];
    variantValue = json['variant_value'];
    sku = json['sku'];
    price = json['price'];
    discountPrice = json['discount_price'];
    discountPercent = json['discount_percent'];
    variantImg = json['variant_img'];
    currentStock = json['current_stock'];
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
    return data;
  }
}
