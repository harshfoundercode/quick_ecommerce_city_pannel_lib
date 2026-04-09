import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
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

class ProvidersHome{
  List<SingleChildWidget> providers= [
    ChangeNotifierProvider(create: (context) => AdminViewModel()),
    ChangeNotifierProvider(create: (context) => AllHubViewModel()),
    ChangeNotifierProvider(create: (context) => AddHubViewModel()),
    ChangeNotifierProvider(create: (context) => OrderDetailsViewModel()),
    ChangeNotifierProvider(create: (context) => NotificationViewModel()),
    ChangeNotifierProvider(create: (context) => LoginViewModel()),
    ChangeNotifierProvider(create: (context) => ProfileViewModel()),
    ChangeNotifierProvider(create: (context) => CityZoneListViewModel()),
    ChangeNotifierProvider(create: (context) => UserViewModel()),
    ChangeNotifierProvider(create: (context) => HubZoneViewModel()),
    ChangeNotifierProvider(create: (context) => DashboardViewModel()),
    ChangeNotifierProvider(create: (context) => HubZoneEditViewModel()),
    ChangeNotifierProvider(create: (context) => HubManagerEditViewModel()),
    ChangeNotifierProvider(create: (context) => CityStockViewModel()),
    ChangeNotifierProvider(create: (context) => HubPerformanceViewModel()),
    ChangeNotifierProvider(create: (context) => AdminStockListRecieveViewModel()),
    ChangeNotifierProvider(create: (context) => StockProvider()),
    ChangeNotifierProvider(create: (context) => AdminIncomingStockNewViewModel()),
  ];
}