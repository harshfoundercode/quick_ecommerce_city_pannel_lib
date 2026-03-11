import 'dart:ui';
import 'package:flutter/material.dart';

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

  HubZoneListData({
    this.id,
    this.cityzoneid,
    this.name,
    this.radiuskm,
    this.lat,
    this.long,
    this.status
  });

  HubZoneListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityzoneid = json['cityzoneid'];
    name = json['name'];
    radiuskm = json['radiuskm'];
    lat = json['lat'];
    long = json['long'];
    status = json['status'];
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
    dynamic status
  }) {
    return HubZoneListData(
      id: id ?? this.id,
      cityzoneid: cityzoneid ?? this.cityzoneid,
      name: name ?? this.name,
      radiuskm: radiuskm ?? this.radiuskm,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      status: status ?? this.status
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

extension HubZoneStatusExtension on HubZoneStatus {
  String get displayName {
    switch (this) {
      case HubZoneStatus.active:
        return 'Active';
      case HubZoneStatus.inactive:
        return 'Inactive';
    }
  }

  Color get color {
    switch (this) {
      case HubZoneStatus.active:
        return const Color(0xFF10B981);
      case HubZoneStatus.inactive:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case HubZoneStatus.active:
        return Icons.check_circle_rounded;
      case HubZoneStatus.inactive:
        return Icons.cancel_rounded;
    }
  }
}