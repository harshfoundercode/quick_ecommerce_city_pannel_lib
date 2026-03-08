class UserDataModel {
  String? message;
  Data? data;

  UserDataModel({this.message, this.data});

  UserDataModel.fromJson(Map<String, dynamic> json) {
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
  User? user;
  String? token;

  Data({this.user, this.token});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['token'] = token;
    return data;
  }
}

class User {
  dynamic id;
  dynamic cityzoneid;
  dynamic name;
  dynamic phone;
  dynamic email;

  User({this.id, this.cityzoneid, this.name, this.phone, this.email});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityzoneid = json['cityzoneid'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cityzoneid'] = cityzoneid;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    return data;
  }
}
