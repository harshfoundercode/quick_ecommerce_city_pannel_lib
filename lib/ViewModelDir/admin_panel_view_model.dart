import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/dashboard_content.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/dispute_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubZoneDir/hub_zone_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/add_hub_form.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/all_hub_list_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/all_hub_performance.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/order_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/RevenueDir/revenue_dashboard_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StockDir/stock_history_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StockDir/stock_screen.dart';

class AdminViewModel extends ChangeNotifier {
  Widget _currentScreen = const DashboardContent();

  int _selectedIndex = 0;
  int? _expandedIndex;

  Widget get currentScreen => _currentScreen;
  int get selectedIndex => _selectedIndex;
  int? get expandedIndex => _expandedIndex;

  void changeScreen(Widget screen, int index) {
    _currentScreen = screen;
    _selectedIndex = index;
    _expandedIndex = null;
    notifyListeners();
  }

  void toggleMenu(int index) {
    _selectedIndex = index;
    _expandedIndex = _expandedIndex == index ? null : index;
    notifyListeners();
  }

  void openSubMenu(Widget screen) {
    _currentScreen = screen;
    notifyListeners();
  }


  void onMenuItemTap(int index) {
    final item = menuItems[index];

    if (item.subItems.isNotEmpty) {
      toggleMenu(index);
      return;
    }

    if (item.screen != null) {
      changeScreen(item.screen!, index);
    }
  }

  void onSubItemTap(SubMenuItem item) {
    openSubMenu(item.screen);
  }

  final List<MenuItem> menuItems = [
    MenuItem(
      icon: Icons.dashboard,
      title: "Dashboard",
      screen: const DashboardContent(),
    ),
    MenuItem(
      icon: Icons.hub,
      title: "Hubs",
      subItems: [
        SubMenuItem(title: "All Hubs", screen: AllHubScreen()),
        SubMenuItem(title: "Add Hub", screen:  AddHubForm()),
        SubMenuItem(title: "Hub Performance", screen:  AllHubsPerformanceScreen()),
        SubMenuItem(title: "Hub Zone", screen:  HubZoneListScreen()),
      ],
    ),
    MenuItem(
      icon: Icons.shopping_bag,
      title: "Orders",
      screen: OrderScreen(),
      // subItems: [
      //   SubMenuItem(title: "All Orders", screen: AllHubScreen()),
      //   SubMenuItem(title: "Pending Orders", screen: const AllHubScreen()),
      //   SubMenuItem(title: "Completed Orders", screen: const AllHubScreen()),
      // ],
    ),
    MenuItem(
      icon: Icons.analytics,
      title: "City Stocks",
      subItems: [
        SubMenuItem(title: "City Stocks", screen: CityStockScreen()),
        SubMenuItem(title: "City Stocks History", screen: CityHubHistoryScreen()),
      ],
    ),
    // MenuItem(
    //   icon: Icons.attach_money,
    //   title: "Revenue",
    //   subItems: [
    //     SubMenuItem(title: "Revenue", screen: RevenueView()),
    //     SubMenuItem(title: "Dispute", screen: DisputeScreen()),
    //   ],
    // ),
  ];

  Future<void> performLogout(BuildContext context) async {
    _currentScreen = const DashboardContent();
    _selectedIndex = 0;
    _expandedIndex = null;
    notifyListeners();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
       RoutesName.adminLoginScreen,
            (route) => false,
      );
    }
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final Widget? screen;
  final List<SubMenuItem> subItems;

  MenuItem({
    required this.icon,
    required this.title,
    this.screen,
    this.subItems = const [],
  });
}

class SubMenuItem {
  final String title;
  final Widget screen;

  SubMenuItem({required this.title, required this.screen});
}
