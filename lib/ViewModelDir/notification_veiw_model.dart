import 'package:flutter/material.dart';

enum NotificationType { finance, onboarding, system }
enum NotificationStatus { unread, read }


class NotificationViewModel extends ChangeNotifier {
  List<NotificationItem> notifications = [
    NotificationItem(
      title: "Settlement Transfer Failed",
      message:
      "The NEFT transfer of ₹1,96,100 to Hub - Gomti Nagar (HB-01) failed due to invalid beneficiary details.",
      time: "10:42 AM",
      type: NotificationType.finance,
      status: NotificationStatus.unread,
      tags: ["Finance", "HB-01"],
      isToday: true,
    ),
    NotificationItem(
      title: "New Hub Successfully Onboarded",
      message:
      "Hub - Ashiyana (HB-05) has completed verification and is now active.",
      time: "09:15 AM",
      type: NotificationType.onboarding,
      status: NotificationStatus.read,
      tags: ["Onboarding"],
      isToday: true,
    ),
    NotificationItem(
      title: "High Order Volume Alert",
      message:
      "Hub - Indira Nagar is experiencing unusually high order volume.",
      time: "08:30 AM",
      type: NotificationType.system,
      status: NotificationStatus.read,
      tags: ["System Alert", "HB-64"],
      isToday: false,
    ),
  ];

  List<NotificationItem> get todayList =>
      notifications.where((e) => e.isToday).toList();

  List<NotificationItem> get yesterdayList =>
      notifications.where((e) => !e.isToday).toList();

  void markAllRead() {
    for (var n in notifications) {
      n.status = NotificationStatus.read;
    }
    notifyListeners();
  }
}
class NotificationItem {
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  NotificationStatus status;
  final List<String> tags;
  final bool isToday;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.status,
    required this.tags,
    required this.isToday,
  });
}
