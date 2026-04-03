import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/demo_data.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/incoming_stock_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/inventory_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/models.dart' show CartItem, ShipmentStatus, RequestStatus;
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/my_requests_screen.dart';


class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  // Shared cart
  final List<CartItem> _cart = [];

  void _onCartUpdated() => setState(() {});

  static const _tabs = [
    _TabMeta(label: 'Inventory', icon: Icons.inventory_2_rounded, activeIcon: Icons.inventory_2_rounded),
    _TabMeta(label: 'Requests', icon: Icons.pending_actions_outlined, activeIcon: Icons.pending_actions_rounded),
    _TabMeta(label: 'Incoming', icon: Icons.move_to_inbox_outlined, activeIcon: Icons.move_to_inbox_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final pendingReqs = demoRequests.where((r) => r.status == RequestStatus.pending).length;
    final arrivedShip = demoShipments.where((s) => s.status == ShipmentStatus.arrived).length;

    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(pendingReqs, arrivedShip),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: IndexedStack(
                  index: _tab,
                  children: [
                    InventoryScreen(cart: _cart, onCartUpdated: _onCartUpdated),
                    const MyRequestsScreen(),
                    const IncomingStockScreen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ──
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ColorConst.cardColor,
          border: const Border(top: BorderSide(color: ColorConst.borderColor)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final meta = _tabs[i];
                final isActive = _tab == i;
                final badge = i == 1 ? pendingReqs : (i == 2 ? arrivedShip : 0);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isActive ? ColorConst.primaryExtraLightGreen : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  isActive ? meta.activeIcon : meta.icon,
                                  size: 22,
                                  color: isActive ? ColorConst.primaryGreen : ColorConst.textSecondary,
                                ),
                              ),
                              if (badge > 0)
                                Positioned(
                                  top: -2, right: -2,
                                  child: Container(
                                    width: 16, height: 16,
                                    decoration: BoxDecoration(
                                      color: i == 1 ? ColorConst.criticalRed : ColorConst.criticalYellowLightText,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text('$badge',
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(meta.label,
                            style: TextStyle(
                              fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive ? ColorConst.primaryGreen : ColorConst.textSecondary,
                            )),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(int pendingReqs, int arrivedShip) {
    final titles = ['Inventory', 'My Requests', 'Incoming Stock'];
    final subs = [
      'Manage stock & raise restock requests',
      'Track all sent requests',
      'Confirm received shipments',
    ];
    final icons = [
      Icons.inventory_2_rounded,
      Icons.pending_actions_rounded,
      Icons.move_to_inbox_rounded,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: ColorConst.cardColor,
        border: Border(bottom: BorderSide(color: ColorConst.borderColor)),
      ),
      child: Row(
        children: [
          // Title block
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: ColorConst.primaryExtraLightGreen,
              borderRadius: BorderRadius.circular(11)),
            child: Icon(icons[_tab], size: 20, color: ColorConst.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titles[_tab],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: ColorConst.kTextHead, letterSpacing: -0.4)),
                Text(subs[_tab],
                  style: const TextStyle(fontSize: 11, color: ColorConst.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_tab == 0 && _cart.isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: ColorConst.primaryGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.shopping_cart_rounded, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text('${_cart.length}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabMeta {
  final String label;
  final IconData icon, activeIcon;
  const _TabMeta({required this.label, required this.icon, required this.activeIcon});
}
