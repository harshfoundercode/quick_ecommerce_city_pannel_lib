
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
  dynamic id;
  dynamic citymanagerid;
  dynamic productid;
  dynamic variantid;
  dynamic perUnitPrice;
  dynamic stockStatus;
  dynamic stock;
  dynamic createdAt;
  dynamic updatedAt;
  Product? product;
  Category? category;
  Brand? brand;
  Variant? variant;
  List<Images>? images;
  dynamic totalReceived;
  dynamic totalSent;

  CityStockData(
      {this.id,
        this.citymanagerid,
        this.productid,
        this.variantid,
        this.perUnitPrice,
        this.stockStatus,
        this.stock,
        this.createdAt,
        this.updatedAt,
        this.product,
        this.category,
        this.brand,
        this.variant,
        this.images,
        this.totalReceived,
        this.totalSent});

  CityStockData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    citymanagerid = json['citymanagerid'];
    productid = json['productid'];
    variantid = json['variantid'];
    perUnitPrice = json['per_unit_price'];
    stockStatus = json['stock_status'];
    stock = json['stock'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product =
    json['product'] != null ? Product.fromJson(json['product']) : null;
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    variant =
    json['variant'] != null ? Variant.fromJson(json['variant']) : null;
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    totalReceived = json['total_received'];
    totalSent = json['total_sent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['citymanagerid'] = citymanagerid;
    data['productid'] = productid;
    data['variantid'] = variantid;
    data['per_unit_price'] = perUnitPrice;
    data['stock_status'] = stockStatus;
    data['stock'] = stock;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (variant != null) {
      data['variant'] = variant!.toJson();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    data['total_received'] = totalReceived;
    data['total_sent'] = totalSent;
    return data;
  }
}

class Product {
  dynamic id;
  dynamic maincatid;
  dynamic catid;
  dynamic subcatid;
  dynamic brandid;
  dynamic name;
  dynamic slug;
  dynamic img;
  dynamic shortDescription;
  dynamic description;
  dynamic price;
  dynamic discountPrice;
  dynamic sku;
  dynamic stock;
  dynamic unit;
  dynamic type;
  dynamic isFeatured;
  dynamic isTrending;
  dynamic catorder;
  dynamic status;
  dynamic createdAt;
  dynamic updatedAt;

  Product(
      {this.id,
        this.maincatid,
        this.catid,
        this.subcatid,
        this.brandid,
        this.name,
        this.slug,
        this.img,
        this.shortDescription,
        this.description,
        this.price,
        this.discountPrice,
        this.sku,
        this.stock,
        this.unit,
        this.type,
        this.isFeatured,
        this.isTrending,
        this.catorder,
        this.status,
        this.createdAt,
        this.updatedAt});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    maincatid = json['maincatid'];
    catid = json['catid'];
    subcatid = json['subcatid'];
    brandid = json['brandid'];
    name = json['name'];
    slug = json['slug'];
    img = json['img'];
    shortDescription = json['short_description'];
    description = json['description'];
    price = json['price'];
    discountPrice = json['discount_price'];
    sku = json['sku'];
    stock = json['stock'];
    unit = json['unit'];
    type = json['type'];
    isFeatured = json['is_featured'];
    isTrending = json['is_trending'];
    catorder = json['catorder'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['maincatid'] = maincatid;
    data['catid'] = catid;
    data['subcatid'] = subcatid;
    data['brandid'] = brandid;
    data['name'] = name;
    data['slug'] = slug;
    data['img'] = img;
    data['short_description'] = shortDescription;
    data['description'] = description;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['sku'] = sku;
    data['stock'] = stock;
    data['unit'] = unit;
    data['type'] = type;
    data['is_featured'] = isFeatured;
    data['is_trending'] = isTrending;
    data['catorder'] = catorder;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Category {
  dynamic mainCategoryId;
  dynamic mainCategoryName;
  dynamic categoryId;
  dynamic categoryName;
  dynamic subcategoryId;
  dynamic subcategoryName;

  Category(
      {this.mainCategoryId,
        this.mainCategoryName,
        this.categoryId,
        this.categoryName,
        this.subcategoryId,
        this.subcategoryName});

  Category.fromJson(Map<String, dynamic> json) {
    mainCategoryId = json['main_category_id'];
    mainCategoryName = json['main_category_name'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    subcategoryId = json['subcategory_id'];
    subcategoryName = json['subcategory_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_category_id'] = mainCategoryId;
    data['main_category_name'] = mainCategoryName;
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    data['subcategory_id'] = subcategoryId;
    data['subcategory_name'] = subcategoryName;
    return data;
  }
}

class Brand {
  dynamic id;
  dynamic brandid;
  dynamic name;
  dynamic img;
  dynamic description;
  dynamic status;
  dynamic createdAt;
  dynamic updatedAt;

  Brand(
      {this.id,
        this.brandid,
        this.name,
        this.img,
        this.description,
        this.status,
        this.createdAt,
        this.updatedAt});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    brandid = json['brandid'];
    name = json['name'];
    img = json['img'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['brandid'] = brandid;
    data['name'] = name;
    data['img'] = img;
    data['description'] = description;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Variant {
  dynamic id;
  dynamic productid;
  dynamic name;
  dynamic value;
  dynamic price;
  dynamic discountPrice;
  dynamic sku;
  dynamic stock;
  dynamic img;
  dynamic status;
  dynamic createdAt;
  dynamic updatedAt;

  Variant(
      {this.id,
        this.productid,
        this.name,
        this.value,
        this.price,
        this.discountPrice,
        this.sku,
        this.stock,
        this.img,
        this.status,
        this.createdAt,
        this.updatedAt});

  Variant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productid = json['productid'];
    name = json['name'];
    value = json['value'];
    price = json['price'];
    discountPrice = json['discount_price'];
    sku = json['sku'];
    stock = json['stock'];
    img = json['img'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['productid'] = productid;
    data['name'] = name;
    data['value'] = value;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['sku'] = sku;
    data['stock'] = stock;
    data['img'] = img;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Images {
  dynamic id;
  dynamic image;
  dynamic status;

  Images({this.id, this.image, this.status});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['status'] = status;
    return data;
  }
}
