class NotificationModel {
  String? message;
  NotificationData? data;

  NotificationModel({this.message, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? NotificationData.fromJson(json['data']) : null;
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

class NotificationData {
  int? count;
  Notifications? notifications;

  NotificationData({this.count, this.notifications});

  NotificationData.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    notifications = json['notifications'] != null
        ? Notifications.fromJson(json['notifications'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    if (notifications != null) {
      data['notifications'] = notifications!.toJson();
    }
    return data;
  }
}

class Notifications {
  List<Earlier>? today;
  List<Earlier>? yesterday;
  List<Earlier>? earlier;

  Notifications({this.today, this.yesterday, this.earlier});

  Notifications.fromJson(Map<String, dynamic> json) {
    if (json['today'] != null) {
      today = <Earlier>[];
      json['today'].forEach((v) {
        today!.add(Earlier.fromJson(v));
      });
    }
    if (json['yesterday'] != null) {
      yesterday = <Earlier>[];
      json['yesterday'].forEach((v) {
        yesterday!.add(Earlier.fromJson(v));
      });
    }
    if (json['earlier'] != null) {
      earlier = <Earlier>[];
      json['earlier'].forEach((v) {
        earlier!.add(Earlier.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (today != null) {
      data['today'] = today!.map((v) => v.toJson()).toList();
    }
    if (yesterday != null) {
      data['yesterday'] = yesterday!.map((v) => v.toJson()).toList();
    }
    if (earlier != null) {
      data['earlier'] = earlier!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Earlier {
  int? id;
  String? title;
  String? message;
  int? type;
  int? senderType;
  int? isRead;
  String? datetime;

  Earlier(
      {this.id,
        this.title,
        this.message,
        this.type,
        this.senderType,
        this.isRead,
        this.datetime});

  Earlier.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    senderType = json['sender_type'];
    isRead = json['isRead'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['message'] = message;
    data['type'] = type;
    data['sender_type'] = senderType;
    data['isRead'] = isRead;
    data['datetime'] = datetime;
    return data;
  }
}
