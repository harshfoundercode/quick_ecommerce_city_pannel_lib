class HubZoneListDataModel {
  String? message;
  List<Data>? data;

  HubZoneListDataModel({this.message, this.data});

  HubZoneListDataModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? cityzoneid;
  String? name;
  String? radiuskm;
  String? lat;
  String? long;

  Data(
      {this.id,
        this.cityzoneid,
        this.name,
        this.radiuskm,
        this.lat,
        this.long});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityzoneid = json['cityzoneid'];
    name = json['name'];
    radiuskm = json['radiuskm'];
    lat = json['lat'];
    long = json['long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cityzoneid'] = cityzoneid;
    data['name'] = name;
    data['radiuskm'] = radiuskm;
    data['lat'] = lat;
    data['long'] = long;
    return data;
  }
}
