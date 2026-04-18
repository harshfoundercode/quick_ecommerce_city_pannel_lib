import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/constant_popup.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/api_exception.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/base_api_service.dart';
import 'package:quick_ecommerce_city_panel_redefined/main.dart';



class NetworkApiServices extends BaseApiServices {
  String? bearerToken;
  NetworkApiServices({this.bearerToken});

  Future<void> initializeToken() async {
    bearerToken = await UserViewModel().getToken();
  }

  // ----------------------------- HEADERS -----------------------------
  Map<String, String> _jsonHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
      "Cache-Control": "no-cache, no-store, must-revalidate",
      "Pragma": "no-cache",
      "Expires": "0",

    };
  }

  Map<String, String> _formHeaders() {
    return {
      if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
    };
  }

  // ----------------------------- GET -----------------------------
  @override
  Future getGetApiResponse(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _jsonHeaders());
      return _returnResponse(response,url);
    }  on SocketException {
      _showServerErrorDialog(503, url);
      throw FetchDataException('Server not reachable');
    } on TimeoutException {
      _showServerErrorDialog(504, url);
      throw FetchDataException('Server timeout');
    } catch (e) {
      _showServerErrorDialog(500, url);
      rethrow;
    }
  }

  // ----------------------------- POST JSON -----------------------------
  @override
  Future getPostApiResponse(String url, data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _jsonHeaders(),
        body: jsonEncode(data),
      );
      return _returnResponse(response,url);
    }  on SocketException {
      _showServerErrorDialog(503, url);
      throw FetchDataException('Server not reachable');
    } on TimeoutException {
      _showServerErrorDialog(504, url);
      throw FetchDataException('Server timeout');
    } catch (e) {
      _showServerErrorDialog(500, url);
      rethrow;
    }
  }

  // ----------------------------- PATCH JSON -----------------------------
  @override
  Future getPatchApiResponse(String url, data) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: _jsonHeaders(),
        body: jsonEncode(data),
      );
      return _returnResponse(response,url);
    }  on SocketException {
      _showServerErrorDialog(503, url);
      throw FetchDataException('Server not reachable');
    } on TimeoutException {
      _showServerErrorDialog(504, url);
      throw FetchDataException('Server timeout');
    } catch (e) {
      _showServerErrorDialog(500, url);
      rethrow;
    }
  }

  // ----------------------------- PATCH FORM DATA -----------------------------
  @override
  Future getPatchApiFormData(
      String url, Map<String, String> fields, Map<String, dynamic> files) async {
    try {
      var request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(_formHeaders());
      request.fields.addAll(fields);

      await _addFilesToRequest(request, files);

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      return _returnResponse(response,url);
    }  on SocketException {
      _showServerErrorDialog(503, url);
      throw FetchDataException('Server not reachable');
    } on TimeoutException {
      _showServerErrorDialog(504, url);
      throw FetchDataException('Server timeout');
    } catch (e) {
      if (kDebugMode) print("PATCH FormData Error: $e");
      _showServerErrorDialog(500, url);
      rethrow;
    }
  }

  // ----------------------------- PUT JSON -----------------------------
  @override
  Future getPutApiResponse(String url, data) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _jsonHeaders(),
        body: jsonEncode(data),
      );
      return _returnResponse(response,url);
    } on SocketException {
      _showServerErrorDialog(503, url);
      throw FetchDataException('Server not reachable');
    } on TimeoutException {
      _showServerErrorDialog(504, url);
      throw FetchDataException('Server timeout');
    } catch (e) {
      _showServerErrorDialog(500, url);
      rethrow;
    }
  }

  // ----------------------------- PUT FORM DATA -----------------------------
  @override
  Future getPutApiFormData(
      String url, Map<String, String> fields, Map<String, dynamic> files) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers.addAll(_formHeaders());
      request.fields.addAll(fields);

      await _addFilesToRequest(request, files);

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      return _returnResponse(response,url);
    } on SocketException {
      _showServerErrorDialog(503, url);
      throw FetchDataException('Server not reachable');
    } on TimeoutException {
      _showServerErrorDialog(504, url);
      throw FetchDataException('Server timeout');
    } catch (e) {
      if (kDebugMode) print("PUT FormData Error: $e");
      _showServerErrorDialog(500, url);
      rethrow;
    }
  }

  // ----------------------------- DELETE SIMPLE -----------------------------
  @override
  Future getDeleteApiResponse(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _jsonHeaders(),
      );
      return _returnResponse(response,url);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }
  }

  // ----------------------------- DELETE WITH BODY -----------------------------
  @override
  Future getDeleteApiWithBody(String url, data) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _jsonHeaders(),
        body: jsonEncode(data),
      );
      return _returnResponse(response,url);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }
  }

  // ----------------------------- COMMON FILE HANDLER -----------------------------
  Future<void> _addFilesToRequest(
      http.MultipartRequest request, Map<String, dynamic> files) async {
    for (var entry in files.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is File) {
        request.files.add(await http.MultipartFile.fromPath(key, value.path));
      } else if (value is Uint8List) {
        request.files.add(http.MultipartFile.fromBytes(key, value,
            filename: "$key.png"));
      } else if (value is String) {
        // base64
        final bytes = base64Decode(value);
        request.files.add(http.MultipartFile.fromBytes(key, bytes,
            filename: "$key.png"));
      }
    }
  }


  // ---------------- RESPONSE HANDLER ----------------
  // Map<String, dynamic> _returnResponse(http.Response response, String requestUrl) {
  //   final statusCode = response.statusCode;
  //   final body = response.body.isNotEmpty ? response.body : '{}';
  //
  //   if (kDebugMode) {
  //     print('📍📍📍📍 Response Url: $requestUrl');
  //     print('📥 Response Status: $statusCode');
  //     print('📦 Response Body: $body');
  //   }
  //
  //   Map<String, dynamic> jsonBody;
  //   try {
  //     jsonBody = jsonDecode(body);
  //   } catch (_) {
  //     jsonBody = {};
  //   }
  //
  //   switch (statusCode) {
  //     case 200:
  //     case 201:
  //     case 204:
  //       return {
  //         "statusCode": statusCode,
  //         "body": jsonBody,
  //       };
  //
  //     case 400:
  //       throw BadRequestException(jsonBody['message'] ?? 'Bad Request');
  //     case 401:
  //       throw UnauthorisedException(jsonBody['message'] ?? 'Unauthorized');
  //     case 403:
  //       throw UnauthorisedException(jsonBody['message'] ?? 'Forbidden');
  //     case 404:
  //       throw FetchDataException('Endpoint not found (404)');
  //     case 409:
  //       throw FetchDataException('Conflict error (409)');
  //     case 422:
  //       throw FetchDataException(jsonBody['message'] ?? 'Validation error (422)');
  //     case >=500:
  //
  //       throw FetchDataException('Server error ($statusCode): ${jsonBody['message']}');
  //     default:
  //       throw FetchDataException(
  //           'Unexpected error: $statusCode → ${response.reasonPhrase}');
  //   }
  // }

  Map<String, dynamic> _returnResponse(http.Response response, String requestUrl) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? response.body : '{}';

    if (kDebugMode) {
      print('📍📍📍📍 Response Url: $requestUrl');
      print('📥 Response Status: $statusCode');
      print('📦 Response Body: $body');
    }

    Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(body);
    } catch (_) {
      jsonBody = {};
    }

    /// 🔥 🔥 🔥 AUTO LOGOUT HERE
    if (statusCode == 401) {
      _handleAutoLogout();
    }

    // Return ALL responses as structured data, don't throw for client errors
    if (statusCode >= 200 && statusCode < 300) {
      return {
        "statusCode": statusCode,
        "body": jsonBody,
        "success": true,
      };
    } else {
      return {
        "statusCode": statusCode,
        "body": jsonBody,
        "success": false,
        "error": jsonBody['message'] ?? getDefaultErrorMessage(statusCode,requestUrl),
      };
    }
  }

  String getDefaultErrorMessage(int statusCode, String requestUrl) {
    switch (statusCode) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Validation Error';
      case >= 500:
        _showServerErrorDialog(statusCode, requestUrl);
        throw FetchDataException('Server error ($statusCode)');
      default:
        throw FetchDataException(
            'Unexpected error: $statusCode');
    }
  }

  bool _isLoggingOut = false;

  Future<void> _handleAutoLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      final context = navigatorKey.currentContext;

      if (context != null) {
        final userProvider =
        Provider.of<UserViewModel>(context, listen: false);

        await userProvider.clearToken();

        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RoutesName.adminLoginScreen,
              (route) => false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Logout Error: $e");
      }
    }
  }

  /// 🔴 Show Server Error Dialog using global navigator key
  void _showServerErrorDialog(int errorCode, String requestUrl) {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Extract base URL from request URL
        final uri = Uri.parse(requestUrl);
        final baseUrl = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
        // Show smart dialog on next frame to avoid conflicts
        Future.microtask(() {
          showSmartServerErrorDialog(
            context: context,
            errorCode: errorCode.toString(),
            serverUrl: baseUrl, // Pass base URL for health check
          );
        });
      } else {
        if (kDebugMode) {
          print('⚠️ Cannot show server error dialog: Context is null');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error showing server error dialog: $e');
      }
    }
  }


  @override
  Future<dynamic> postFormDataResponse(String url, Map<String, String> fields, Map<String, dynamic> files) {
    // TODO: implement postFormDataResponse
    throw UnimplementedError();
  }


}

