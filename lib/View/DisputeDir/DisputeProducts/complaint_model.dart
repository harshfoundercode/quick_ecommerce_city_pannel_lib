// ─────────────────────────────────────────────────────────────────────────────
// complaint_model.dart
// ─────────────────────────────────────────────────────────────────────────────

class ComplaintListModel {
  final String? message;
  final List<ComplaintData>? data;

  ComplaintListModel({this.message, this.data});

  factory ComplaintListModel.fromJson(Map<String, dynamic> json) {
    return ComplaintListModel(
      message: json['message'],
      data: (json['data'] as List?)
          ?.map((e) => ComplaintData.fromJson(e))
          .toList(),
    );
  }
}

class ComplaintData {
  final int? id;
  final int? stockRequestId;
  final String? productName;
  final int? orderedQty;
  final int? receivedQty;
  final List<String>? complaintTypes;// damaged | missing | wrong | quality
  final int? damagedQty;
  final int? missingQty;
  final int? wrongQty;
  final String? description;
  final String? photoUrl;
  final String? status; // pending | under_review | resolved | rejected
  final String? adminResponse;
  final String? createdAt;
  final String? updatedAt;
  String? complaintType;
  Map<String, int>? issueQuantities;

  ComplaintData({
    this.id,
    this.stockRequestId,
    this.productName,
    this.orderedQty,
    this.receivedQty,
    this.complaintType,
    this.damagedQty,
    this.missingQty,
    this.wrongQty,
    this.description,
    this.photoUrl,
    this.status,
    this.adminResponse,
    this.createdAt,
    this.updatedAt,
    this.complaintTypes,
    this.issueQuantities
  });

  factory ComplaintData.fromJson(Map<String, dynamic> json) {
    return ComplaintData(
      id: json['id'],
      stockRequestId: json['stock_request_id'],
      productName: json['product_name'],
      orderedQty: json['ordered_qty'],
      receivedQty: json['received_qty'],
      complaintType: json['complaint_type'],
      damagedQty: json['damaged_qty'],
      missingQty: json['missing_qty'],
      wrongQty: json['wrong_qty'],
      description: json['description'],
      photoUrl: json['photo_url'],
      status: json['status'],
      adminResponse: json['admin_response'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      issueQuantities: json['issueQuantities'],
      complaintTypes: json['complaintTypes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'stock_request_id': stockRequestId,
    'product_name': productName,
    'ordered_qty': orderedQty,
    'received_qty': receivedQty,
    'complaint_type': complaintType,
    'damaged_qty': damagedQty,
    'missing_qty': missingQty,
    'wrong_qty': wrongQty,
    'description': description,
    'photo_url': photoUrl,
    'issueQuantities': issueQuantities,
    'complaintTypes': complaintTypes,
  };
}

class SubmitComplaintModel {
  final String? message;
  final bool? success;

  SubmitComplaintModel({this.message, this.success});

  factory SubmitComplaintModel.fromJson(Map<String, dynamic> json) {
    return SubmitComplaintModel(
      message: json['message'],
      success: json['success'],
    );
  }
}