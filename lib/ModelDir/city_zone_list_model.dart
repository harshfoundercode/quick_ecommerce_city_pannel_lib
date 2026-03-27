class CityZoneDataModel {
  String? message;
  List<Data>? data;

  CityZoneDataModel({this.message, this.data});

  CityZoneDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  dynamic id;
  dynamic name;
  dynamic radiuskm;
  dynamic lat;
  dynamic long;
  dynamic status;

  Data({this.id, this.name, this.radiuskm, this.lat, this.long, this.status});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    radiuskm = json['radiuskm'];
    lat = json['lat'];
    long = json['long'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['radiuskm'] = radiuskm;
    data['lat'] = lat;
    data['long'] = long;
    data['status'] = status;
    return data;
  }
}
