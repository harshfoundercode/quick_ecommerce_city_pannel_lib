// import 'dart:ui';
//
// import 'package:flutter/material.dart';
//
// class HubZone {
//   final String id;
//   final String name;
//   final String city;
//   final String state;
//   final String pincode;
//   final String address;
//   final double latitude;
//   final double longitude;
//   final double coverageRadius; // in km
//   final String managerName;
//   final String managerPhone;
//   final String managerEmail;
//   final HubZoneStatus status;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   HubZone({
//     required this.id,
//     required this.name,
//     required this.city,
//     required this.state,
//     required this.pincode,
//     required this.address,
//     required this.latitude,
//     required this.longitude,
//     required this.coverageRadius,
//     required this.managerName,
//     required this.managerPhone,
//     required this.managerEmail,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory HubZone.fromJson(Map<String, dynamic> json) {
//     return HubZone(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       city: json['city'] ?? '',
//       state: json['state'] ?? '',
//       pincode: json['pincode'] ?? '',
//       address: json['address'] ?? '',
//       latitude: (json['latitude'] ?? 0.0).toDouble(),
//       longitude: (json['longitude'] ?? 0.0).toDouble(),
//       coverageRadius: (json['coverageRadius'] ?? 0.0).toDouble(),
//       managerName: json['managerName'] ?? '',
//       managerPhone: json['managerPhone'] ?? '',
//       managerEmail: json['managerEmail'] ?? '',
//       status: HubZoneStatus.values.firstWhere(
//             (e) => e.toString() == 'HubZoneStatus.${json['status']}',
//         orElse: () => HubZoneStatus.inactive,
//       ),
//       createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
//       updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'city': city,
//       'state': state,
//       'pincode': pincode,
//       'address': address,
//       'latitude': latitude,
//       'longitude': longitude,
//       'coverageRadius': coverageRadius,
//       'managerName': managerName,
//       'managerPhone': managerPhone,
//       'managerEmail': managerEmail,
//       'status': status.toString().split('.').last,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }
//
//   HubZone copyWith({
//     String? id,
//     String? name,
//     String? code,
//     String? city,
//     String? state,
//     String? pincode,
//     String? address,
//     double? latitude,
//     double? longitude,
//     int? totalStores,
//     int? activeStores,
//     int? deliveryAgents,
//     double? coverageRadius,
//     String? managerName,
//     String? managerPhone,
//     String? managerEmail,
//     HubZoneStatus? status,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     List<String>? coveredAreas,
//     Map<String, dynamic>? operatingHours,
//     List<String>? deliveryPincodes,
//   }) {
//     return HubZone(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       city: city ?? this.city,
//       state: state ?? this.state,
//       pincode: pincode ?? this.pincode,
//       address: address ?? this.address,
//       latitude: latitude ?? this.latitude,
//       longitude: longitude ?? this.longitude,
//       coverageRadius: coverageRadius ?? this.coverageRadius,
//       managerName: managerName ?? this.managerName,
//       managerPhone: managerPhone ?? this.managerPhone,
//       managerEmail: managerEmail ?? this.managerEmail,
//       status: status ?? this.status,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }
//
