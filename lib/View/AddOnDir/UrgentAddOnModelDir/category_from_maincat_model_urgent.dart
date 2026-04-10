class UrgentCategoryFromMainCategoryListModel {
  List<Data>? data;

  UrgentCategoryFromMainCategoryListModel({this.data});

  UrgentCategoryFromMainCategoryListModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  dynamic mainCategoryName;
  dynamic mainCategoryImg;
  List<Categories>? categories;

  Data({this.mainCategoryName, this.mainCategoryImg, this.categories});

  Data.fromJson(Map<String, dynamic> json) {
    mainCategoryName = json['main_category_name'];
    mainCategoryImg = json['main_category_img'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_category_name'] = mainCategoryName;
    data['main_category_img'] = mainCategoryImg;
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
  List<Subcategories>? subcategories;

  Categories({
    this.categoryId,
    this.categoryName,
    this.categoryImg,
    this.subcategories,
  });

  Categories.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categoryImg = json['category_img'];
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
    if (subcategories != null) {
      data['subcategories'] = subcategories!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }
}

class Subcategories {
  dynamic subcatId;
  dynamic subcatName;
  dynamic subcatImg;
  List<Products>? products;

  Subcategories({
    this.subcatId,
    this.subcatName,
    this.subcatImg,
    this.products,
  });

  Subcategories.fromJson(Map<String, dynamic> json) {
    subcatId = json['subcat_id'];
    subcatName = json['subcat_name'];
    subcatImg = json['subcat_img'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subcat_id'] = subcatId;
    data['subcat_name'] = subcatName;
    data['subcat_img'] = subcatImg;
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
  List<Variants>? variants;

  Products({
    this.productId,
    this.productName,
    this.productImg,
    this.brandName,
    this.brandImg,
    this.variants,
  });

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    productImg = json['product_img'];
    brandName = json['brand_name'];
    brandImg = json['brand_img'];
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

  Variants({
    this.variantId,
    this.variantValue,
    this.sku,
    this.price,
    this.discountPrice,
    this.discountPercent,
    this.variantImg,
    this.currentStock,
    this.unitsSold,
  });

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
