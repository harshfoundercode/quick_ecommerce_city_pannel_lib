import 'package:flutter/material.dart';

class DisputeViewModel extends ChangeNotifier {
  String selectedFilter = "All Disputes";
  String selectedHub = "All Hubs";
  String searchQuery = "";
  DateTimeRange? dateRange;
  List<DisputeModel> disputes = [];
  Map<String, dynamic> stats = {};

  DisputeViewModel() {
    _loadMockData();
  }

  void _loadMockData() {
    disputes = List.generate(
      20,
          (index) => DisputeModel(
        id: "DSP-${2024000 + index}",
        orderId: "ORD-${2024000 + index}",
        customerName: ["Rahul Sharma", "Priya Patel", "Amit Kumar", "Neha Singh", "Vikram Mehta"][index % 5],
        customerAvatar: ["RS", "PP", "AK", "NS", "VM"][index % 5],
        hubName: ["Gomti Nagar Hub", "Indira Nagar Hub", "Alambagh Hub", "Charbagh Hub"][index % 4],
        issueType: ["Delivery Delay", "Wrong Item", "Missing Item", "Quality Issue", "Refund Issue", "Payment Issue"][index % 6],
        description: "Customer reported issue with the order. Please investigate and take necessary action.",
        amount: 450.0 + (index * 50),
        status: ["Open", "In Progress", "Resolved", "Escalated"][index % 4],
        priority: ["High", "Medium", "Low"][index % 3],
        raisedBy: "Customer",
        raisedDate: DateTime.now().subtract(Duration(days: index % 7)),
        lastUpdated: DateTime.now().subtract(Duration(hours: index % 24)),
        assignedTo: index % 3 == 0 ? "Support Team" : "Hub Manager",
        resolution: index % 4 == 2 ? "Refund processed successfully" : null,
        images: index % 3 == 0 ? ["image1.jpg", "image2.jpg"] : [],
      ),
    );

    stats = {
      'totalDisputes': 156,
      'openDisputes': 45,
      'inProgress': 38,
      'resolved': 62,
      'escalated': 11,
      'avgResolutionTime': '4.5 hours',
      'satisfactionRate': '92%',
    };
  }

  void updateFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void updateHub(String hub) {
    selectedHub = hub;
    notifyListeners();
  }

  void updateSearch(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<DisputeModel> get filteredDisputes {
    return disputes.where((d) {
      if (selectedFilter != "All Disputes" && d.status != selectedFilter) return false;
      if (selectedHub != "All Hubs" && d.hubName != selectedHub) return false;
      if (searchQuery.isNotEmpty) {
        return d.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
            d.orderId.toLowerCase().contains(searchQuery.toLowerCase()) ||
            d.customerName.toLowerCase().contains(searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }
}

// ==================== DISPUTE MODEL ====================
class DisputeModel {
  final String id;
  final String orderId;
  final String customerName;
  final String customerAvatar;
  final String hubName;
  final String issueType;
  final String description;
  final double amount;
  final String status;
  final String priority;
  final String raisedBy;
  final DateTime raisedDate;
  final DateTime lastUpdated;
  final String assignedTo;
  final String? resolution;
  final List<String> images;

  DisputeModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerAvatar,
    required this.hubName,
    required this.issueType,
    required this.description,
    required this.amount,
    required this.status,
    required this.priority,
    required this.raisedBy,
    required this.raisedDate,
    required this.lastUpdated,
    required this.assignedTo,
    this.resolution,
    this.images = const [],
  });
}