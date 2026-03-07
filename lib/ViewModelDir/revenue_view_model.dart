import 'package:flutter/material.dart';

class RevenueViewModel extends ChangeNotifier {
  String selectedHub = "All Hubs";
  DateTimeRange? dateRange;

  // 🔥 Summary
  double totalRevenue = 2456789;
  double todayRevenue = 45678;
  double weekRevenue = 234567;
  double monthRevenue = 987654;

  // 🔥 Chart data
  List<double> weeklyTrend = [12, 18, 14, 22, 28, 24, 30];

  // 🔥 Hub revenue table
  List<HubRevenueModel> hubRevenue = [
    HubRevenueModel("Gomti Nagar Hub", 456789, 120),
    HubRevenueModel("Indira Nagar Hub", 356000, 98),
    HubRevenueModel("Aliganj Hub", 298765, 76),
  ];

  // 🔥 Transactions
  List<TransactionModel> transactions = [
    TransactionModel("#ORD-98234", "Rahul Sharma", 899, "Paid"),
    TransactionModel("#ORD-98235", "Amit Verma", 1299, "Paid"),
    TransactionModel("#ORD-98236", "Sneha Gupta", 499, "Refunded"),
  ];
}

class HubRevenueModel {
  final String hub;
  final double revenue;
  final int orders;

  HubRevenueModel(this.hub, this.revenue, this.orders);
}

class TransactionModel {
  final String orderId;
  final String customer;
  final double amount;
  final String status;

  TransactionModel(this.orderId, this.customer, this.amount, this.status);
}