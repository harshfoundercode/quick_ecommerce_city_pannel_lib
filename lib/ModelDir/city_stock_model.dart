// class CityStockModel {
//   String? message;
//   List<CityStockData>? data;
//
//   CityStockModel({this.message, this.data});
//
//   CityStockModel.fromJson(Map<String, dynamic> json) {
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <CityStockData>[];
//       json['data'].forEach((v) {
//         data!.add(CityStockData.fromJson(v));
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
// class CityStockData {
//   dynamic productId;
//   dynamic productName;
//   dynamic productImg;
//   dynamic description;
//   dynamic shortDescription;
//   dynamic sku;
//   dynamic status;
//   dynamic mainCategoryName;
//   dynamic mainCategoryImg;
//   dynamic categoryName;
//   dynamic categoryImg;
//   dynamic subcategoryName;
//   dynamic subcategoryImg;
//   dynamic brandName;
//   dynamic brandImg;
//   List<Variants>? variants;
//   dynamic totalStock;
//
//   CityStockData(
//       {this.productId,
//         this.productName,
//         this.productImg,
//         this.description,
//         this.shortDescription,
//         this.sku,
//         this.status,
//         this.mainCategoryName,
//         this.mainCategoryImg,
//         this.categoryName,
//         this.categoryImg,
//         this.subcategoryName,
//         this.subcategoryImg,
//         this.brandName,
//         this.brandImg,
//         this.variants,
//         this.totalStock});
//
//   CityStockData.fromJson(Map<String, dynamic> json) {
//     productId = json['product_id'];
//     productName = json['product_name'];
//     productImg = json['product_img'];
//     description = json['description'];
//     shortDescription = json['short_description'];
//     sku = json['sku'];
//     status = json['status'];
//     mainCategoryName = json['main_category_name'];
//     mainCategoryImg = json['main_category_img'];
//     categoryName = json['category_name'];
//     categoryImg = json['category_img'];
//     subcategoryName = json['subcategory_name'];
//     subcategoryImg = json['subcategory_img'];
//     brandName = json['brand_name'];
//     brandImg = json['brand_img'];
//     if (json['variants'] != null) {
//       variants = <Variants>[];
//       json['variants'].forEach((v) {
//         variants!.add(Variants.fromJson(v));
//       });
//     }
//     totalStock = json['total_stock'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['product_id'] = productId;
//     data['product_name'] = productName;
//     data['product_img'] = productImg;
//     data['description'] = description;
//     data['short_description'] = shortDescription;
//     data['sku'] = sku;
//     data['status'] = status;
//     data['main_category_name'] = mainCategoryName;
//     data['main_category_img'] = mainCategoryImg;
//     data['category_name'] = categoryName;
//     data['category_img'] = categoryImg;
//     data['subcategory_name'] = subcategoryName;
//     data['subcategory_img'] = subcategoryImg;
//     data['brand_name'] = brandName;
//     data['brand_img'] = brandImg;
//     if (variants != null) {
//       data['variants'] = variants!.map((v) => v.toJson()).toList();
//     }
//     data['total_stock'] = totalStock;
//     return data;
//   }
// }
//
// class Variants {
//   dynamic variantId;
//   dynamic value;
//   dynamic price;
//   dynamic discountPrice;
//   dynamic stock;
//   dynamic stockStatus;
//
//   Variants(
//       {this.variantId,
//         this.value,
//         this.price,
//         this.discountPrice,
//         this.stock,
//         this.stockStatus});
//
//   Variants.fromJson(Map<String, dynamic> json) {
//     variantId = json['variant_id'];
//     value = json['value'];
//     price = json['price'];
//     discountPrice = json['discount_price'];
//     stock = json['stock'];
//     stockStatus = json['stock_status'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['variant_id'] = variantId;
//     data['value'] = value;
//     data['price'] = price;
//     data['discount_price'] = discountPrice;
//     data['stock'] = stock;
//     data['stock_status'] = stockStatus;
//     return data;
//   }
// }
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
  List<Variants>? variants;
  dynamic totalStock;

  CityStockData(
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
        this.variants,
        this.totalStock});

  CityStockData.fromJson(Map<String, dynamic> json) {
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
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(Variants.fromJson(v));
      });
    }
    totalStock = json['total_stock'];
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
    if (variants != null) {
      data['variants'] = variants!.map((v) => v.toJson()).toList();
    }
    data['total_stock'] = totalStock;
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
