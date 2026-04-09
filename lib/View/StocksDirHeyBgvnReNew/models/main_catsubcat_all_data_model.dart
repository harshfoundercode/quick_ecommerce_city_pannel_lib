class CityStocksFullModel {
  bool? status;
  String? message;
  List<CityStocksFullData>? data;

  CityStocksFullModel({this.status, this.message, this.data});

  CityStocksFullModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CityStocksFullData>[];
      json['data'].forEach((v) {
        data!.add(CityStocksFullData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CityStocksFullData {
  int? mainCategoryId;
  dynamic mainCategoryName;
  dynamic mainCategoryImg;
  int? categoryCount;
  List<Categories>? categories;

  CityStocksFullData(
      {this.mainCategoryId,
        this.mainCategoryName,
        this.mainCategoryImg,
        this.categoryCount,
        this.categories});

  CityStocksFullData.fromJson(Map<String, dynamic> json) {
    mainCategoryId = json['main_category_id'];
    mainCategoryName = json['main_category_name'];
    mainCategoryImg = json['main_category_img'];
    categoryCount = json['category_count'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_category_id'] = mainCategoryId;
    data['main_category_name'] = mainCategoryName;
    data['main_category_img'] = mainCategoryImg;
    data['category_count'] = categoryCount;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  dynamic categoryId;
  dynamic categoryName;
  dynamic categoryImg;
  dynamic subcategoryCount;
  List<Subcategories>? subcategories;

  Categories(
      {this.categoryId,
        this.categoryName,
        this.categoryImg,
        this.subcategoryCount,
        this.subcategories});

  Categories.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categoryImg = json['category_img'];
    subcategoryCount = json['subcategory_count'];
    if (json['subcategories'] != null) {
      subcategories = <Subcategories>[];
      json['subcategories'].forEach((v) {
        subcategories!.add(Subcategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    data['category_img'] = categoryImg;
    data['subcategory_count'] = subcategoryCount;
    if (subcategories != null) {
      data['subcategories'] =
          subcategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subcategories {
  dynamic subcategoryId;
  dynamic subcategoryName;
  dynamic subcategoryImg;
  dynamic productCount;
  List<Products>? products;

  Subcategories(
      {this.subcategoryId,
        this.subcategoryName,
        this.subcategoryImg,
        this.productCount,
        this.products});

  Subcategories.fromJson(Map<String, dynamic> json) {
    subcategoryId = json['subcategory_id'];
    subcategoryName = json['subcategory_name'];
    subcategoryImg = json['subcategory_img'];
    productCount = json['product_count'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subcategory_id'] = subcategoryId;
    data['subcategory_name'] = subcategoryName;
    data['subcategory_img'] = subcategoryImg;
    data['product_count'] = productCount;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  dynamic productId;
  dynamic name;
  dynamic img;
  dynamic description;
  dynamic shortDescription;
  dynamic sku;
  dynamic status;
  dynamic totalStock;
  List<Variants>? variants;

  Products(
      {this.productId,
        this.name,
        this.img,
        this.description,
        this.shortDescription,
        this.sku,
        this.status,
        this.totalStock,
        this.variants});

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    name = json['name'];
    img = json['img'];
    description = json['description'];
    shortDescription = json['short_description'];
    sku = json['sku'];
    status = json['status'];
    totalStock = json['total_stock'];
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
    data['name'] = name;
    data['img'] = img;
    data['description'] = description;
    data['short_description'] = shortDescription;
    data['sku'] = sku;
    data['status'] = status;
    data['total_stock'] = totalStock;
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
  dynamic stock;
  dynamic stockStatus;

  Variants(
      {this.variantId,
        this.value,
        this.price,
        this.discountPrice,
        this.stock,
        this.stockStatus});

  Variants.fromJson(Map<String, dynamic> json) {
    variantId = json['variant_id'];
    value = json['value'];
    price = json['price'];
    discountPrice = json['discount_price'];
    stock = json['stock'];
    stockStatus = json['stock_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_id'] = variantId;
    data['value'] = value;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['stock'] = stock;
    data['stock_status'] = stockStatus;
    return data;
  }
}
