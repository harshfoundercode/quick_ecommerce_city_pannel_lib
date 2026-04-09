import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'stock_overview_screen.dart';
import 'bulk_request_screen.dart';
import 'history_screen.dart';
import 'incoming_stock_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  final List<Widget> _screens = const [
    StockOverviewScreen(),
    BulkRequestScreen(),
    HistoryScreen(),
    IncomingStockScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: _screens[_idx],
      bottomNavigationBar: _nav(),
    );
  }

  Widget _nav() {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.white,
        border: Border(top: BorderSide(color: ColorConst.borderColor)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(0, Icons.inventory_2_outlined, Icons.inventory_2, 'Stock'),
              _item(1, Icons.swap_horiz_outlined, Icons.swap_horiz, 'Transfer'),
              _item(2, Icons.history_outlined, Icons.history, 'History'),
              _item(3, Icons.local_shipping_outlined, Icons.local_shipping, 'Incoming'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, IconData activeIcon, String label) {
    final active = _idx == index;
    return GestureDetector(
      onTap: () => setState(() => _idx = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? ColorConst.greenPale : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, color: active ? ColorConst.primaryGreen : ColorConst.textGrey, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? ColorConst.primaryGreen : ColorConst.textGrey)),
          ],
        ),
      ),
    );
  }
}
