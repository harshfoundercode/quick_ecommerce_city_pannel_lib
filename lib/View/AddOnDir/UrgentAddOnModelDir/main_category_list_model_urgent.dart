class UrgentMainCategoryListModel {
  String? message;
  int? count;
  List<UrgentMainCategoryData>? data;

  UrgentMainCategoryListModel({this.message, this.count, this.data});

  UrgentMainCategoryListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    count = json['count'];
    if (json['data'] != null) {
      data = <UrgentMainCategoryData>[];
      json['data'].forEach((v) {
        data!.add(UrgentMainCategoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['count'] = count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UrgentMainCategoryData {
  dynamic id;
  dynamic name;
  dynamic img;
  dynamic description;
  dynamic catorder;
  dynamic slug;
  dynamic status;
  dynamic createdAt;
  dynamic updatedAt;

  UrgentMainCategoryData(
      {this.id,
        this.name,
        this.img,
        this.description,
        this.catorder,
        this.slug,
        this.status,
        this.createdAt,
        this.updatedAt});

  UrgentMainCategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    img = json['img'];
    description = json['description'];
    catorder = json['catorder'];
    slug = json['slug'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['img'] = img;
    data['description'] = description;
    data['catorder'] = catorder;
    data['slug'] = slug;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
