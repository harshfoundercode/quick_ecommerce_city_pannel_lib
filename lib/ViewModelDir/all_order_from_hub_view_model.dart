import 'package:flutter/material.dart';


class HubOrdersViewModel extends ChangeNotifier {

  String selectedFilter = "All";
  String searchQuery = "";


  HubOrderModel? selectedOrder;


  final List<HubOrderModel> _orders = [
    HubOrderModel(
      id: "#ORD-5521",
      customer: "Anjali Gupta",
      address: "Gomti Nagar",
      status: "Delivered",
      amount: "₹480",
      time: "10:34 AM",
      customerPhone: "1234567890",
      customerEmail: "abcd@gmail.com",
      landmark: "ABCD",
      pincode: "220653",
        boy: "Rahul Sharma",
      boyPhone: "2345273883",
      boyVehicle: "Bike",
      paymentMethod: "Online",
      paymentStatus: "Done",
      transactionId: "TRAN12345678"



    ),
    HubOrderModel(
      id: "#ORD-5522",
      customer: "Vikram Srivastava",
      address: "Aliganj",
      boy: "Amit Kumar",
      status: "In Transit",
      amount: "235",
      time: "11:15 AM",
        customerPhone: "1234567890",
        customerEmail: "abcd@gmail.com",
        landmark: "ABCD",
        pincode: "220653",
        boyPhone: "2345273883",
        boyVehicle: "Bike",
        paymentMethod: "Online",
        paymentStatus: "Done",
        transactionId: "TRAN12345678"
    ),
  ];

  List<HubOrderModel> get orders => _orders;


  void selectOrder(HubOrderModel order) {
    selectedOrder = order;
    notifyListeners();
  }


  void updateFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }


  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }
}
// ==================== HELPER CLASSES ====================
class TimelineEvent {
  final String title;
  final String time;
  final String status;
  final IconData icon;

  TimelineEvent({
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
  });
}

class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}

class OrderItem {
  final String name;
  final int quantity;
  final int price;
  final IconData image;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
  });
}

// ==================== HUB ORDER MODEL ====================
class HubOrderModel {
  final String id;
  final String customer;
  final String customerPhone;
  final String customerEmail;
  final String address;
  final String landmark;
  final String pincode;
  final String boy;
  final String boyPhone;
  final String boyVehicle;
  final String amount;
  final String status;
  final String time;
  final String paymentMethod;
  final String paymentStatus;
  final String transactionId;

  HubOrderModel({
    required this.id,
    required this.customer,
    this.customerPhone = '',
    this.customerEmail = '',
    required this.address,
    this.landmark = '',
    this.pincode = '',
    required this.boy,
    this.boyPhone = '',
    this.boyVehicle = '',
    required this.amount,
    required this.status,
    required this.time,
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.transactionId = '',
  });
}