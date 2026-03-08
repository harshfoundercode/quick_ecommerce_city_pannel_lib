abstract class BaseApiServices {
  Future<dynamic> getGetApiResponse(String url);

  Future<dynamic> getPostApiResponse(String url, dynamic data);
  Future<dynamic> postFormDataResponse(String url, Map<String, String> fields, Map<String, dynamic> files);

  Future<dynamic> getPutApiResponse(String url, dynamic data);
  Future<dynamic> getPutApiFormData(String url, Map<String, String> fields, Map<String, dynamic> files);

  Future<dynamic> getPatchApiResponse(String url, dynamic data);
  Future<dynamic> getPatchApiFormData(String url, Map<String, String> fields, Map<String, dynamic> files);

  Future<dynamic> getDeleteApiResponse(String url);
  Future<dynamic> getDeleteApiWithBody(String url, dynamic data);
}
