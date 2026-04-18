import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnViewModel/urgent_add_on_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubRequestGetDir/hub_get_req_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/providers/admin_incomming_stock_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/providers/stock_provider_new.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/add_hub_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_city_stocks_list_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/auth_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_zone_list_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/dashboard_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_manager_edit_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_edit_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/notification_veiw_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/order_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/profile_view_model.dart';


class ProvidersHome {
  List<SingleChildWidget> get providers => [

    /// 🔐 AUTH & USER (load early)
    ChangeNotifierProvider(create: (_) => LoginViewModel(), lazy: false),
    ChangeNotifierProvider(create: (_) => UserViewModel()..init(), lazy: false),
    ChangeNotifierProvider(create: (_) => DashboardViewModel(), lazy: false,),
    ChangeNotifierProvider(create: (_) => AdminViewModel(),),

    /// HUB MANAGEMENT
    ChangeNotifierProvider(create: (_) => AllHubViewModel()),
    ChangeNotifierProvider(create: (_) => AddHubViewModel()),
    ChangeNotifierProvider(create: (_) => HubZoneViewModel()),
    ChangeNotifierProvider(create: (_) => HubZoneEditViewModel()),
    ChangeNotifierProvider(create: (_) => HubManagerEditViewModel()),
    ChangeNotifierProvider(create: (_) => HubPerformanceViewModel()),
    ChangeNotifierProvider(create: (_) => HubReqGetViewModel()),

    ///  STOCK MANAGEMENT
    ChangeNotifierProvider(create: (_) => CityStockViewModel()),
    ChangeNotifierProvider(create: (_) => AdminStockListRecieveViewModel()),
    ChangeNotifierProvider(create: (_) => AdminIncomingStockNewViewModel()),
    ChangeNotifierProvider(create: (_) => StockProvider()),

    ///  ORDERS & ADD-ONS
    ChangeNotifierProvider(create: (_) => OrderDetailsViewModel()),
    ChangeNotifierProvider(create: (_) => UrgentAddOnViewModel()),

    /// NOTIFICATIONS & PROFILE
    ChangeNotifierProvider(create: (_) => NotificationViewModel()),
    ChangeNotifierProvider(create: (_) => ProfileViewModel()),

    ///  LOCATION / ZONE
    ChangeNotifierProvider(create: (_) => CityZoneListViewModel()),
  ];
}