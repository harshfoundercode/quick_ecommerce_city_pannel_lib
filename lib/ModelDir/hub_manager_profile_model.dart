class HubProfileDataModel {
  String? message;
  Data? data;

  HubProfileDataModel({this.message, this.data});

  HubProfileDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  int? hubzoneid;
  int? citymanagerid;
  String? name;
  String? phone;
  String? address;
  String? adharno;
  String? panno;
  String? img;
  String? email;
  String? password;
  int? createdBy;
  int? status;
  Null? fcmToken;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hubzoneid'] = this.hubzoneid;
    data['citymanagerid'] = this.citymanagerid;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['adharno'] = this.adharno;
    data['panno'] = this.panno;
    data['img'] = this.img;
    data['email'] = this.email;
    data['password'] = this.password;
    data['created_by'] = this.createdBy;
    data['status'] = this.status;
    data['fcm_token'] = this.fcmToken;
    return data;
  }
}
