// ─────────────────────────────────────────────────────────────────────────────
// complaint_view_model.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';

import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/DisputeProducts/complaint_model.dart';

class ComplaintViewModel with ChangeNotifier {
  // final _repo = ComplaintRepo();

  // ── State ─────────────────────────────────────────────────────────────────
  ComplaintListModel? _complaintListModel;
  ComplaintListModel? get complaintListModel => _complaintListModel;

  bool _listLoading = false;
  bool get listLoading => _listLoading;

  bool _submitLoading = false;
  bool get submitLoading => _submitLoading;

  // ── Filter for history ────────────────────────────────────────────────────
  String _statusFilter = 'all'; // all | pending | under_review | resolved | rejected
  String get statusFilter => _statusFilter;

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  List<ComplaintData> get filteredComplaints {
    final all = _complaintListModel?.data ?? [];
    if (_statusFilter == 'all') return all;
    return all.where((c) => c.status == _statusFilter).toList();
  }



  // ── Demo data (for UI testing without API) ────────────────────────────────
  void loadDemoData() {
    _complaintListModel = ComplaintListModel(
      message: 'success',
      data: [
        ComplaintData(
          id: 1,
          stockRequestId: 101,
          productName: 'Cold Drink (250ml)',
          orderedQty: 400,
          receivedQty: 380,
          missingQty: 20,
          description: '20 bottles missing from the shipment.',
          status: 'pending',
          createdAt: '2025-07-10T10:30:00',
          complaintTypes: ["damaged", "missing"], // multi
          issueQuantities: {
            "damaged": 5,
            "missing": 10,
          },
        ),
        ComplaintData(
          id: 2,
          stockRequestId: 101,
          productName: 'Cold Drink (250ml)',
          orderedQty: 400,
          receivedQty: 380,
          complaintType: 'damaged',
          damagedQty: 15,
          description: '15 bottles damaged during transit. Caps broken.',
          photoUrl: 'https://picsum.photos/400/300',
          status: 'under_review',
          adminResponse: 'We are reviewing your complaint. Will respond in 24 hours.',
          createdAt: '2025-07-08T14:00:00',
          complaintTypes: ["damaged", "missing"], // multi
          issueQuantities: {
            "damaged": 5,
            "missing": 10,
          },
        ),
        ComplaintData(
          id: 3,
          stockRequestId: 98,
          productName: 'Juice Pack (1L)',
          orderedQty: 200,
          receivedQty: 195,
          complaintType: 'wrong',
          wrongQty: 10,
          description: 'Received mango flavour instead of orange flavour.',
          status: 'resolved',
          adminResponse: 'Replacement has been dispatched. Expected delivery in 2 days.',
          createdAt: '2025-07-05T09:15:00',
          complaintTypes: ["damaged", "missing"], // multi
          issueQuantities: {
            "damaged": 5,
            "missing": 10,
          },
        ),
        ComplaintData(
          id: 4,
          stockRequestId: 95,
          productName: 'Biscuit Box (200g)',
          orderedQty: 100,
          receivedQty: 100,
          complaintType: 'quality',
          description: 'Biscuits were stale. Manufacturing date shows last year.',
          status: 'rejected',
          adminResponse: 'After inspection, items were within expiry date. Complaint rejected.',
          createdAt: '2025-07-01T11:00:00',
          complaintTypes: ["damaged", "missing"], // multi
          issueQuantities: {
            "damaged": 5,
            "missing": 10,
          },
        ),
      ],
    );
    notifyListeners();
  }
}