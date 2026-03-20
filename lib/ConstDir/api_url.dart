class ApiUrl {

  static const String baseurl = "https://payment.codescarts.com/";

  static const String configUrl1 = "${baseurl}api/";
  static const String configUrl2 = "${baseurl}citymanagerapi/";

  static const String loginUrl = "${configUrl1}citylogin";
  static const String profileUrl = "${configUrl1}cityprofile";
  static const String createZoneUrl = "${configUrl2}hubzone/create";
  static const String cityZoneListUrl = "${configUrl2}cityzone_list";
  static const String hubZoneCreateUrl = "${configUrl1}hubzone/create";
  static const String hubManagerCreateUrl = "${configUrl2}hubmanager/create";
  static const String hubProfileUrl = "${configUrl1}hubprofile";
  static const String hubZoneListUrl = "${configUrl1}hubzone_list";
  static const String orderListUrl = "${configUrl1}orders";
  static const String orderDetailsUrl = "${configUrl1}orderprofile";
  static const String hubListUrl = "${configUrl1}hub_list";
  static String hubListDetailsUrl(String hubId) => "${configUrl1}hub_details/$hubId";
  static String dashboardUrl = "${configUrl1}dashboard";

}
