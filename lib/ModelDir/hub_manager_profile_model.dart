// class HubProfileDataModel {
//   dynamic message;
//   Data? data;
//
//   HubProfileDataModel({this.message, this.data});
//
//   HubProfileDataModel.fromJson(Map<String, dynamic> json) {
//     message = json['message'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['message'] = message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   dynamic id;
//   dynamic hubzoneid;
//   dynamic citymanagerid;
//   dynamic name;
//   dynamic phone;
//   dynamic address;
//   dynamic adharno;
//   dynamic panno;
//   dynamic img;
//   dynamic email;
//   dynamic password;
//   dynamic createdBy;
//   dynamic status;
//   dynamic fcmToken;
//
//   Data(
//       {this.id,
//         this.hubzoneid,
//         this.citymanagerid,
//         this.name,
//         this.phone,
//         this.address,
//         this.adharno,
//         this.panno,
//         this.img,
//         this.email,
//         this.password,
//         this.createdBy,
//         this.status,
//         this.fcmToken});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     hubzoneid = json['hubzoneid'];
//     citymanagerid = json['citymanagerid'];
//     name = json['name'];
//     phone = json['phone'];
//     address = json['address'];
//     adharno = json['adharno'];
//     panno = json['panno'];
//     img = json['img'];
//     email = json['email'];
//     password = json['password'];
//     createdBy = json['created_by'];
//     status = json['status'];
//     fcmToken = json['fcm_token'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['hubzoneid'] = hubzoneid;
//     data['citymanagerid'] = citymanagerid;
//     data['name'] = name;
//     data['phone'] = phone;
//     data['address'] = address;
//     data['adharno'] = adharno;
//     data['panno'] = panno;
//     data['img'] = img;
//     data['email'] = email;
//     data['password'] = password;
//     data['created_by'] = createdBy;
//     data['status'] = status;
//     data['fcm_token'] = fcmToken;
//     return data;
//   }
// }
class HubProfileDataModel {
  dynamic message;
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
  dynamic name;
  dynamic email;
  dynamic phone;
  dynamic img;
  dynamic address;
  dynamic adharno;
  dynamic panno;
  dynamic citymanagerid;
  dynamic password;
  HubDetails? hubDetails;
  PerformanceStats? performanceStats;

  Data(
      {this.id,
        this.name,
        this.email,
        this.phone,
        this.img,
        this.address,
        this.adharno,
        this.panno,
        this.citymanagerid,
        this.hubDetails,
        this.performanceStats,
        this.password
      });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    img = json['img'];
    address = json['address'];
    adharno = json['adharno'];
    panno = json['panno'];
    citymanagerid = json['citymanagerid'];
    password = json['password'];
    hubDetails = json['hub_details'] != null
        ? HubDetails.fromJson(json['hub_details'])
        : null;
    performanceStats = json['performance_stats'] != null
        ? PerformanceStats.fromJson(json['performance_stats'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['img'] = img;
    data['address'] = address;
    data['adharno'] = adharno;
    data['panno'] = panno;
    data['citymanagerid'] = citymanagerid;
    data['password'] = password;
    if (hubDetails != null) {
      data['hub_details'] = hubDetails!.toJson();
    }
    if (performanceStats != null) {
      data['performance_stats'] = performanceStats!.toJson();
    }
    return data;
  }
}

class HubDetails {
  dynamic hubId;
  dynamic hubName;
  dynamic status;
  dynamic address;
  dynamic cityId;
  dynamic cityhubName;
  dynamic cityhubStatus;
  dynamic cityName;

  HubDetails(
      {this.hubId,
        this.hubName,
        this.status,
        this.address,
        this.cityId,
        this.cityhubName,
        this.cityhubStatus,
        this.cityName});

  HubDetails.fromJson(Map<String, dynamic> json) {
    hubId = json['hub_id'];
    hubName = json['hub_name'];
    status = json['status'];
    address = json['address'];
    cityId = json['city_id'];
    cityhubName = json['cityhub_name'];
    cityhubStatus = json['cityhub_status'];
    cityName = json['city_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hub_id'] = hubId;
    data['hub_name'] = hubName;
    data['status'] = status;
    data['address'] = address;
    data['city_id'] = cityId;
    data['cityhub_name'] = cityhubName;
    data['cityhub_status'] = cityhubStatus;
    data['city_name'] = cityName;
    return data;
  }
}

class PerformanceStats {
  dynamic managedOrders;
  dynamic activeStaff;
  dynamic punctuality;
  Trends? trends;

  PerformanceStats(
      {this.managedOrders, this.activeStaff, this.punctuality, this.trends});

  PerformanceStats.fromJson(Map<String, dynamic> json) {
    managedOrders = json['managed_orders'];
    activeStaff = json['active_staff'];
    punctuality = json['punctuality'];
    trends =
    json['trends'] != null ? Trends.fromJson(json['trends']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['managed_orders'] = managedOrders;
    data['active_staff'] = activeStaff;
    data['punctuality'] = punctuality;
    if (trends != null) {
      data['trends'] = trends!.toJson();
    }
    return data;
  }
}

class Trends {
  dynamic orders;
  dynamic staff;
  dynamic punctuality;

  Trends({this.orders, this.staff, this.punctuality});

  Trends.fromJson(Map<String, dynamic> json) {
    orders = json['orders'];
    staff = json['staff'];
    punctuality = json['punctuality'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orders'] = orders;
    data['staff'] = staff;
    data['punctuality'] = punctuality;
    return data;
  }
}
