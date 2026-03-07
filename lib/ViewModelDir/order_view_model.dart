import 'package:flutter/material.dart';

class OrderDetailsViewModel extends ChangeNotifier {
  String orderId = "#ORD-98234";
  String status = "Completed";
  String placedDate = "Placed on October 24, 2023 at 10:45 AM";

  // 🔹 Order Items
  List<OrderItemModel> items = [
    OrderItemModel(
      name: "Noise Cancelling Wireless Earbuds",
      sku: "SKU: ELEC-WE-001",
      price: 899,
      qty: 1,
      image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5yqD9RzcZaa9OGgt5eDdAJYLPDpki1Wb_0g&s",
    ),
    OrderItemModel(
      name: "Silicone Smartphone Case - Midnight Blue",
      sku: "SKU: ACC-SC-042",
      price: 350,
      qty: 1,
      image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUFCAgtS-nlbX8Z3O0flWplvFUQTk7hy2GnQ&s",
    ),
  ];

  // 🔹 Pricing
  double subtotal = 1249;
  double shipping = 40;
  double tax = 224.82;
  double discount = 200;
  double grandTotal = 1313.82;

  // 🔹 Customer
  String customerName = "Rahul Sharma";
  String customerSince = "Customer since Jan 2022";
  String email = "rahul.sharma@example.com";
  String phone = "+91 98765 43210";
  String address =
      "12A, Vibhav Khand\nGomti Nagar, Phase 2\nLucknow, Uttar Pradesh 226010\nIndia";

  // 🔹 Hub
  String hubName = "Gomti Nagar Hub";
  String zone = "Lucknow East";
  String deliveryBoy = "Amit Kumar";
  String deliveryPhone = "+91 78543 21098";

  // 🔹 Payment
  String paymentMethod = "UPI (Google Pay)";
  String transactionId = "TXN9876543210123";
  String paymentStatus = "Paid in Full";
}

class OrderItemModel {
  final String name;
  final String sku;
  final double price;
  final int qty;
  final String image;

  OrderItemModel({
    required this.name,
    required this.sku,
    required this.price,
    required this.qty,
    required this.image,
  });
}