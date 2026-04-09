class CityHubHistoryModel {
  String? message;
  List<CityHubHistoryData>? data;

  CityHubHistoryModel({this.message, this.data});

  CityHubHistoryModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <CityHubHistoryData>[];
      json['data'].forEach((v) {
        data!.add(CityHubHistoryData.fromJson(v));
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

class CityHubHistoryData {
  dynamic productId;
  dynamic productName;
  dynamic productImg;
  dynamic description;
  dynamic shortDescription;
  dynamic sku;
  dynamic status;
  dynamic mainCategoryName;
  dynamic mainCategoryImg;
  dynamic categoryName;
  dynamic categoryImg;
  dynamic subcategoryName;
  dynamic subcategoryImg;
  dynamic brandName;
  dynamic brandImg;
  List<Transfers>? transfers;

  CityHubHistoryData(
      {this.productId,
        this.productName,
        this.productImg,
        this.description,
        this.shortDescription,
        this.sku,
        this.status,
        this.mainCategoryName,
        this.mainCategoryImg,
        this.categoryName,
        this.categoryImg,
        this.subcategoryName,
        this.subcategoryImg,
        this.brandName,
        this.brandImg,
        this.transfers});

  CityHubHistoryData.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    productImg = json['product_img'];
    description = json['description'];
    shortDescription = json['short_description'];
    sku = json['sku'];
    status = json['status'];
    mainCategoryName = json['main_category_name'];
    mainCategoryImg = json['main_category_img'];
    categoryName = json['category_name'];
    categoryImg = json['category_img'];
    subcategoryName = json['subcategory_name'];
    subcategoryImg = json['subcategory_img'];
    brandName = json['brand_name'];
    brandImg = json['brand_img'];
    if (json['transfers'] != null) {
      transfers = <Transfers>[];
      json['transfers'].forEach((v) {
        transfers!.add(Transfers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['product_img'] = productImg;
    data['description'] = description;
    data['short_description'] = shortDescription;
    data['sku'] = sku;
    data['status'] = status;
    data['main_category_name'] = mainCategoryName;
    data['main_category_img'] = mainCategoryImg;
    data['category_name'] = categoryName;
    data['category_img'] = categoryImg;
    data['subcategory_name'] = subcategoryName;
    data['subcategory_img'] = subcategoryImg;
    data['brand_name'] = brandName;
    data['brand_img'] = brandImg;
    if (transfers != null) {
      data['transfers'] = transfers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transfers {
  dynamic transferId;
  dynamic hubId;
  dynamic hubName;
  dynamic status;
  dynamic createdAt;
  List<Variants>? variants;

  Transfers(
      {this.transferId,
        this.hubId,
        this.hubName,
        this.status,
        this.createdAt,
        this.variants});

  Transfers.fromJson(Map<String, dynamic> json) {
    transferId = json['transfer_id'];
    hubId = json['hub_id'];
    hubName = json['hub_name'];
    status = json['status'];
    createdAt = json['created_at'];
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(Variants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transfer_id'] = transferId;
    data['hub_id'] = hubId;
    data['hub_name'] = hubName;
    data['status'] = status;
    data['created_at'] = createdAt;
    if (variants != null) {
      data['variants'] = variants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Variants {
  dynamic variantId;
  dynamic value;
  dynamic price;
  dynamic discountPrice;
  dynamic sentQty;
  dynamic receivedQty;
  dynamic missingQty;
  dynamic disputeQty;
  dynamic currentStock;

  Variants(
      {this.variantId,
        this.value,
        this.price,
        this.discountPrice,
        this.sentQty,
        this.receivedQty,
        this.missingQty,
        this.disputeQty,
        this.currentStock});

  Variants.fromJson(Map<String, dynamic> json) {
    variantId = json['variant_id'];
    value = json['value'];
    price = json['price'];
    discountPrice = json['discount_price'];
    sentQty = json['sent_qty'];
    receivedQty = json['received_qty'];
    missingQty = json['missing_qty'];
    disputeQty = json['dispute_qty'];
    currentStock = json['current_stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_id'] = variantId;
    data['value'] = value;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['sent_qty'] = sentQty;
    data['received_qty'] = receivedQty;
    data['missing_qty'] = missingQty;
    data['dispute_qty'] = disputeQty;
    data['current_stock'] = currentStock;
    return data;
  }
}
