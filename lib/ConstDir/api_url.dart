class ApiUrl {
  static const String baseurl = "https://payment.codescarts.com/";

  static const String configUrl1 = "${baseurl}api/";

  static const String loginUrl = "${configUrl1}citylogin";
  static const String profileUrl = "${configUrl1}cityprofile";
  static const String cityZoneListUrl = "${configUrl1}cityzone_list";
  static const String hubZoneCreateUrl = "${configUrl1}hubzone/create";
  static const String hubManagerCreateUrl = "${configUrl1}hubmanager/create";
  static String hubProfileUrl(String hubId) =>
      "${configUrl1}hubprofile?id=$hubId";
  static const String hubZoneListUrl = "${configUrl1}hubzone_list";
  static const String orderListUrl = "${configUrl1}orders";
  static const String orderDetailsUrl = "${configUrl1}orderprofile";
  static const String hubListUrl = "${configUrl1}hub_list";
  static String hubListDetailsUrl(String hubId) =>
      "${configUrl1}hub_details/$hubId";
  static String dashboardUrl = "${configUrl1}dashboard";
  static String notificationUrl = "${configUrl1}notifications";
  static String hubZoneEditUrl = "${configUrl1}hubzone/update";
  static String hubManagerEditUrl = "${configUrl1}hubmanager/update";
  static String cityStockListUrl = "${configUrl1}cityStock";
  static String cityTransferToHubUrl = "${configUrl1}citytransfer-to-hub";  /// stock send to hub
  static String cityRequestInventoryUrl = "${configUrl1}cityRequests"; /// stock request to admin
  static String adminTransferHistoryUrl = "${configUrl1}admintransfer_history"; /// admin ke beje hue incoming stock history check
  static String acceptTransferUrl = "${configUrl1}accept_transfer"; /// admin ke beje hue incoming stock accept

  ///city saman lene ke liye reuwst krega uska h yeh
  static String cityHubHistoryUrl = "${configUrl1}cityhub-history";
  static String hubPerformanceUrl = "${configUrl1}performance_hubs";
  static String hubPerformanceOrderListUrl(String hubId) =>
      "${configUrl1}hubs/$hubId/orders";
  static String hubPerformanceViewOrderDetailsUrl(String orderId) =>
      "${configUrl1}orders/$orderId";

  ///============================= MAP APIS ==================================
  static String mapPlaceAutoCompleteUrl(String query) =>
      "${configUrl1}place_autocomplete?query=$query";
  static String mapPlaceDetailsUrl(String placeId) =>
      "${configUrl1}place_details?place_id=$placeId";

}
