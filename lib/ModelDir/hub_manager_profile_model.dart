class HubProfileDataModel {
  String? message;
  Data? data;

  HubProfileDataModel({this.message, this.data});

  HubProfileDataModel.fromJson(Map<String, dynamic> json) {
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
  dynamic hubzoneid;
  dynamic citymanagerid;
  dynamic name;
  dynamic phone;
  dynamic address;
  dynamic adharno;
  dynamic panno;
  dynamic img;
  dynamic email;
  dynamic password;
  dynamic createdBy;
  dynamic status;
  dynamic fcmToken;

  Data(
      {this.id,
        this.hubzoneid,
        this.citymanagerid,
        this.name,
        this.phone,
        this.address,
        this.adharno,
        this.panno,
        this.img,
        this.email,
        this.password,
        this.createdBy,
        this.status,
        this.fcmToken});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hubzoneid = json['hubzoneid'];
    citymanagerid = json['citymanagerid'];
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
    adharno = json['adharno'];
    panno = json['panno'];
    img = json['img'];
    email = json['email'];
    password = json['password'];
    createdBy = json['created_by'];
    status = json['status'];
    fcmToken = json['fcm_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['hubzoneid'] = hubzoneid;
    data['citymanagerid'] = citymanagerid;
    data['name'] = name;
    data['phone'] = phone;
    data['address'] = address;
    data['adharno'] = adharno;
    data['panno'] = panno;
    data['img'] = img;
    data['email'] = email;
    data['password'] = password;
    data['created_by'] = createdBy;
    data['status'] = status;
    data['fcm_token'] = fcmToken;
    return data;
  }
}
