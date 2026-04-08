import 'package:flutter/material.dart';
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
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    StockOverviewScreen(),
    BulkRequestScreen(),
    HistoryScreen(),
    IncomingStockScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.inventory_2_outlined, Icons.inventory_2, 'Stock'),
              _navItem(1, Icons.add_circle_outline, Icons.add_circle, 'Bulk Update'),
              _navItem(2, Icons.history_outlined, Icons.history, 'History'),
              _navItem(3, Icons.local_shipping_outlined, Icons.local_shipping, 'Incoming'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3D5AFE).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF3D5AFE) : Colors.white38,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF3D5AFE) : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
