
class HubZoneListDataModel {
  String? message;
  List<HubZoneListData>? data;

  HubZoneListDataModel({this.message, this.data});

  HubZoneListDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <HubZoneListData>[];
      json['data'].forEach((v) {
        data!.add(HubZoneListData.fromJson(v));
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

class HubZoneListData {
  dynamic id;
  dynamic cityzoneid;
  dynamic name;
  dynamic radiuskm;
  dynamic lat;
  dynamic long;
  dynamic status;
  dynamic address;
  dynamic pincode;

  HubZoneListData({
    this.id,
    this.cityzoneid,
    this.name,
    this.radiuskm,
    this.lat,
    this.long,
    this.status,
    this.address,
    this.pincode
  });

  HubZoneListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityzoneid = json['cityzoneid'];
    name = json['name'];
    radiuskm = json['radiuskm'];
    lat = json['lat'];
    long = json['long'];
    status: json['status'] == 1
        ? HubZoneStatus.active
        : HubZoneStatus.inactive;
    address = json['address'];
    pincode = json['pincode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cityzoneid'] = cityzoneid;
    data['name'] = name;
    data['radiuskm'] = radiuskm;
    data['lat'] = lat;
    data['long'] = long;
    data['status'] = status;
    data['pincode'] = pincode;
    data['address'] = address;
    return data;
  }

  /// Creates a copy of this HubZoneListData with the given fields replaced
  HubZoneListData copyWith({
    dynamic id,
    dynamic cityzoneid,
    dynamic name,
    dynamic radiuskm,
    dynamic lat,
    dynamic long,
    dynamic status,
    dynamic pincode,
    dynamic address
  }) {
    return HubZoneListData(
      id: id ?? this.id,
      cityzoneid: cityzoneid ?? this.cityzoneid,
      name: name ?? this.name,
      radiuskm: radiuskm ?? this.radiuskm,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      status: status ?? this.status,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
    );
  }

  /// Helper method to get radius as double for calculations
  double get radiusInKm => double.tryParse(radiuskm ?? '0') ?? 0.0;

  /// Helper method to get latitude as double
  double get latitude => double.tryParse(lat ?? '0') ?? 0.0;

  /// Helper method to get longitude as double
  double get longitude => double.tryParse(long ?? '0') ?? 0.0;

  /// Helper method to check if location coordinates are valid
  bool get hasValidCoordinates {
    final lat = latitude;
    final lng = longitude;
    return lat != 0.0 && lng != 0.0 &&
        lat >= -90 && lat <= 90 &&
        lng >= -180 && lng <= 180;
  }

  /// Helper method to get status based on some logic (example)
  HubZoneStatus get statuss {
    // You can implement your own logic here
    // For example, based on isActive flag from API
    return HubZoneStatus.active; // Default for now
  }
}

enum HubZoneStatus {
  active,
  inactive
}




class Data {
  int? id;
  int? cityzoneid;
  String? name;
  String? address;
  int? pincode;
  String? radiuskm;
  String? lat;
  String? long;
  int? status;

  Data(
      {this.id,
        this.cityzoneid,
        this.name,
        this.address,
        this.pincode,
        this.radiuskm,
        this.lat,
        this.long,
        this.status});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityzoneid = json['cityzoneid'];
    name = json['name'];
    address = json['address'];
    pincode = json['pincode'];
    radiuskm = json['radiuskm'];
    lat = json['lat'];
    long = json['long'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cityzoneid'] = this.cityzoneid;
    data['name'] = this.name;
    data['address'] = this.address;
    data['pincode'] = this.pincode;
    data['radiuskm'] = this.radiuskm;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['status'] = this.status;
    return data;
  }
}
