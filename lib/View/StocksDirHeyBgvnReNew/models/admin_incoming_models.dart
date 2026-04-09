class AdminIncomingStockModel {
  String? message;
  List<AdminIncomingStockData>? data;

  AdminIncomingStockModel({this.message, this.data});

  AdminIncomingStockModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <AdminIncomingStockData>[];
      json['data'].forEach((v) {
        data!.add(AdminIncomingStockData.fromJson(v));
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

class AdminIncomingStockData {
  dynamic transferId;
  dynamic status;
  dynamic createdAt;
  dynamic remark;
  List<Items>? items;

  AdminIncomingStockData({this.transferId, this.status, this.createdAt, this.remark, this.items});

  AdminIncomingStockData.fromJson(Map<String, dynamic> json) {
    transferId = json['transfer_id'];
    status = json['status'];
    createdAt = json['created_at'];
    remark = json['remark'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transfer_id'] = transferId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['remark'] = remark;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  dynamic productid;
  dynamic productName;
  dynamic productImage;
  dynamic mainCategory;
  dynamic category;
  dynamic subcategory;
  dynamic gstPercent;
  dynamic brandname;
  dynamic brandImage;
  List<String>? images;
  List<Variants>? variants;

  Items(
      {this.productid,
        this.productName,
        this.productImage,
        this.mainCategory,
        this.category,
        this.subcategory,
        this.gstPercent,
        this.brandname,
        this.brandImage,
        this.images,
        this.variants});

  Items.fromJson(Map<String, dynamic> json) {
    productid = json['productid'];
    productName = json['product_name'];
    productImage = json['product_image'];
    mainCategory = json['main_category'];
    category = json['category'];
    subcategory = json['subcategory'];
    gstPercent = json['gst_percent'];
    brandname = json['brandname'];
    brandImage = json['brand_image'];
    images = json['images'].cast<String>();
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(Variants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productid'] = productid;
    data['product_name'] = productName;
    data['product_image'] = productImage;
    data['main_category'] = mainCategory;
    data['category'] = category;
    data['subcategory'] = subcategory;
    data['gst_percent'] = gstPercent;
    data['brandname'] = brandname;
    data['brand_image'] = brandImage;
    data['images'] = images;
    if (variants != null) {
      data['variants'] = variants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Variants {
  dynamic variantid;
  dynamic value;
  dynamic quantity;
  dynamic receivedQty;
  dynamic missingQty;
  dynamic disputeQty;
  dynamic image;
  dynamic price;
  dynamic discountPrice;
  dynamic discountPercent;
  dynamic status;

  Variants(
      {this.variantid,
        this.value,
        this.quantity,
        this.receivedQty,
        this.missingQty,
        this.disputeQty,
        this.image,
        this.price,
        this.discountPrice,
        this.discountPercent,
        this.status});

  Variants.fromJson(Map<String, dynamic> json) {
    variantid = json['variantid'];
    value = json['value'];
    quantity = json['quantity'];
    receivedQty = json['received_qty'];
    missingQty = json['missing_qty'];
    disputeQty = json['dispute_qty'];
    image = json['image'];
    price = json['price'];
    discountPrice = json['discount_price'];
    discountPercent = json['discount_percent'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variantid'] = variantid;
    data['value'] = value;
    data['quantity'] = quantity;
    data['received_qty'] = receivedQty;
    data['missing_qty'] = missingQty;
    data['dispute_qty'] = disputeQty;
    data['image'] = image;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['discount_percent'] = discountPercent;
    data['status'] = status;
    return data;
  }
}
