// // ─────────────────────────────────────────────────────────────────────────────
// // complaint_repo.dart
// // ─────────────────────────────────────────────────────────────────────────────
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/shared_pref.dart';
//
// class ComplaintRepo {
//   // ── GET: complaint history ────────────────────────────────────────────────
//   Future<Map<String, dynamic>> getComplaintListApi() async {
//     try {
//       final token = await SharedPrefHelper.getToken();
//       final response = await http.get(
//         Uri.parse(ApiUrl.complaintList), // add this to ApiUrl
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       return {
//         'statusCode': response.statusCode,
//         'body': jsonDecode(response.body),
//       };
//     } catch (e) {
//       return {'statusCode': 500, 'body': {'message': e.toString()}};
//     }
//   }
//
//   // ── POST: submit complaint with optional photo ────────────────────────────
//   Future<Map<String, dynamic>> submitComplaintApi({
//     required int stockRequestId,
//     required String productName,
//     required int orderedQty,
//     required int receivedQty,
//     required String complaintType,
//     int? damagedQty,
//     int? missingQty,
//     int? wrongQty,
//     required String description,
//     File? photo,
//   }) async {
//     try {
//       final token = await SharedPrefHelper.getToken();
//       final uri = Uri.parse(ApiUrl.submitComplaint); // add this to ApiUrl
//
//       final request = http.MultipartRequest('POST', uri)
//         ..headers['Authorization'] = 'Bearer $token'
//         ..fields['stock_request_id'] = stockRequestId.toString()
//         ..fields['product_name'] = productName
//         ..fields['ordered_qty'] = orderedQty.toString()
//         ..fields['received_qty'] = receivedQty.toString()
//         ..fields['complaint_type'] = complaintType
//         ..fields['description'] = description;
//
//       if (damagedQty != null) {
//         request.fields['damaged_qty'] = damagedQty.toString();
//       }
//       if (missingQty != null) {
//         request.fields['missing_qty'] = missingQty.toString();
//       }
//       if (wrongQty != null) {
//         request.fields['wrong_qty'] = wrongQty.toString();
//       }
//       if (photo != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath('photo', photo.path),
//         );
//       }
//
//       final streamed = await request.send();
//       final response = await http.Response.fromStream(streamed);
//       return {
//         'statusCode': response.statusCode,
//         'body': jsonDecode(response.body),
//       };
//     } catch (e) {
//       return {'statusCode': 500, 'body': {'message': e.toString()}};
//     }
//   }
// }