class ProfileDataModel {
  String? message;
  Data? data;

  ProfileDataModel({this.message, this.data});

  ProfileDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  dynamic id;
  dynamic cityzoneid;
  dynamic name;
  dynamic phone;
  dynamic email;
  dynamic address;
  dynamic adharno;
  dynamic panno;
  dynamic img;
  dynamic status;

  Data(
      {this.id,
        this.cityzoneid,
        this.name,
        this.phone,
        this.email,
        this.address,
        this.adharno,
        this.panno,
        this.img,
        this.status});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityzoneid = json['cityzoneid'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    address = json['address'];
    adharno = json['adharno'];
    panno = json['panno'];
    img = json['img'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cityzoneid'] = cityzoneid;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['address'] = address;
    data['adharno'] = adharno;
    data['panno'] = panno;
    data['img'] = img;
    data['status'] = status;
    return data;
  }
}
