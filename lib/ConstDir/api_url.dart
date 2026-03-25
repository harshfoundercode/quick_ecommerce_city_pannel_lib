class ApiUrl {

  static const String baseurl = "https://payment.codescarts.com/";
  static const String mapKey = "AIzaSyAW2lp2BYRmy8oD3ppvvegrql2MlMa-4tI";

  static const String configUrl1 = "${baseurl}api/";
  static const String configUrl2 = "${baseurl}citymanagerapi/";

  static const String loginUrl = "${configUrl1}citylogin";
  static const String profileUrl = "${configUrl1}cityprofile";
  static const String createZoneUrl = "${configUrl2}hubzone/create";
  static const String cityZoneListUrl = "${configUrl2}cityzone_list";
  static const String hubZoneCreateUrl = "${configUrl1}hubzone/create";
  static const String hubManagerCreateUrl = "${configUrl2}hubmanager/create";
  static String hubProfileUrl(String hubId) => "${configUrl1}hubprofile?id=$hubId";
  static const String hubZoneListUrl = "${configUrl1}hubzone_list";
  static const String orderListUrl = "${configUrl1}orders";
  static const String orderDetailsUrl = "${configUrl1}orderprofile";
  static const String hubListUrl = "${configUrl1}hub_list";
  static String hubListDetailsUrl(String hubId) => "${configUrl1}hub_details/$hubId";
  static String dashboardUrl = "${configUrl1}dashboard";
  static String notificationUrl = "${configUrl1}notifications";
  static String hubZoneEditUrl = "${configUrl1}hubzone/update";
  static String hubManagerEditUrl = "${configUrl1}hubmanager/update";
  static String cityStockListUrl = "${configUrl1}cityStock";
  static String cityTransferToHubUrl = "${configUrl1}citytransfer-to-hub";
  static String cityRequestInventoryUrl = "${configUrl1}cityRequests";   ///city saman lene ke liye reuwst krega uska h yeh
  static String cityHubHistoryUrl = "${configUrl1}cityhub-history";
  static String hubPerformanceUrl = "${configUrl1}performance_hubs";
  static String hubPerformanceOrderListUrl(String hubId) => "${configUrl1}hubs/$hubId/orders";
  static String hubPerformanceViewOrderDetailsUrl(String orderId) => "${configUrl1}orders/$orderId";


}
