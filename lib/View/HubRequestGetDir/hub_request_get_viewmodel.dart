import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_ecommerce_city_panel_redefined/View/HubRequestGetDir/hub_req_get_model.dart';


// ════════════════════════════════════════════════════════════════════════════
// STATUS FILTER ENUM
// ════════════════════════════════════════════════════════════════════════════

enum RequestFilter { all, pending, accepted, rejected }

// ════════════════════════════════════════════════════════════════════════════
// HUB REQUEST PROVIDER
// ════════════════════════════════════════════════════════════════════════════

class HubRequestProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  List<HubRequest> _allRequests = [];
  HubRequest? _selectedRequest;
  RequestFilter _filter = RequestFilter.all;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<HubRequest> get allRequests => _allRequests;
  HubRequest? get selectedRequest => _selectedRequest;
  RequestFilter get filter => _filter;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  List<HubRequest> get filteredRequests {
    if (_filter == RequestFilter.all) return _allRequests;
    return _allRequests
        .where((r) => r.status == _filter.name)
        .toList();
  }

  int get pendingCount =>
      _allRequests.where((r) => r.status == 'pending').length;

  // ── Select request ─────────────────────────────────────────────────────────
  void selectRequest(HubRequest req) {
    _selectedRequest = req;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRequest = null;
    notifyListeners();
  }

  // ── Set filter ─────────────────────────────────────────────────────────────
  void setFilter(RequestFilter f) {
    _filter = f;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH ALL HUB REQUESTS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> fetchHubRequests(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 🔥 DEMO JSON (your data)
      const demoJson = {
        "success": true,
        "message": "Requests fetched",
        "data": {
          "requests": [
            {
              "request_id": "REQ001",
              "hub_id": 12,
              "hub_name": "Sector 12 Hub",
              "city_name": "Lucknow",
              "status": "pending",
              "note": "Urgent hai",
              "created_at": "2 min ago",
              "products": [
                {
                  "product_id": 101,
                  "product_name": "Amul Full Cream Milk",
                  "product_img": "https://...",
                  "sku": "AMK-001",
                  "main_category": "Dairy",
                  "sub_category": "Milk",
                  "variants": [
                    {
                      "variant_id": 201,
                      "variant_name": "500ml",
                      "qty": 20,
                      "available_stock": 80
                    }
                  ]
                }
              ]
            }
          ]
        }
      };

      // 🔥 Convert map → JSON string → decode (important)
      final json = jsonDecode(jsonEncode(demoJson));

      final model = HubRequestListModel.fromJson(json);

      _allRequests = model.data?.requests ?? [];

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACCEPT REQUEST
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool> acceptRequest(BuildContext context, dynamic requestId) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('YOUR_BASE_URL/api/city/hub-requests/accept'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'request_id': requestId}),
      );

      if (response.statusCode == 200) {
        // Update local state
        final idx = _allRequests.indexWhere(
              (r) => r.requestId.toString() == requestId.toString(),
        );
        if (idx != -1) {
          _allRequests[idx].status = 'accepted';
          if (_selectedRequest?.requestId.toString() == requestId.toString()) {
            _selectedRequest = _allRequests[idx];
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REJECT REQUEST
  // ══════════════════════════════════════════════════════════════════════════

  // Future<bool> rejectRequest(
  //     BuildContext context,
  //     dynamic requestId, {
  //       String? rejectNote,
  //     }) async {
  //   _isActionLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse('YOUR_BASE_URL/api/city/hub-requests/reject'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         // 'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode({
  //         'request_id': requestId,
  //         if (rejectNote != null && rejectNote.isNotEmpty) 'note': rejectNote,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final idx = _allRequests.indexWhere(
  //             (r) => r.requestId.toString() == requestId.toString(),
  //       );
  //       if (idx != -1) {
  //         _allRequests[idx].status = 'rejected';
  //         if (_selectedRequest?.requestId.toString() == requestId.toString()) {
  //           _selectedRequest = _allRequests[idx];
  //         }
  //       }
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     return false;
  //   } finally {
  //     _isActionLoading = false;
  //     notifyListeners();
  //   }
  // }
}