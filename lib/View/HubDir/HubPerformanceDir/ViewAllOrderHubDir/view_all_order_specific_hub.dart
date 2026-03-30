
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/order_left_side_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/order_right_side_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';

class ViewAllOrderSpecificHub extends StatefulWidget {
  final String hubName;
  final String hubId;

  const ViewAllOrderSpecificHub(
      {super.key, required this.hubName, required this.hubId});

  @override
  State<ViewAllOrderSpecificHub> createState() =>
      _ViewAllOrderSpecificHubState();
}

class _ViewAllOrderSpecificHubState extends State<ViewAllOrderSpecificHub>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<HubPerformanceViewModel>(context, listen: false);
      vm.getHubPerformanceOrderListDataApi(context, widget.hubId)
          .then((_) => _fadeCtrl.forward());
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HubPerformanceViewModel>(
      builder: (context, hpvm, child) {
        final data = hpvm.hubPerformanceOrderListModel?.data;

        return Material(
          color: const Color(0xFFF4F6F9),
          child: Container(
            width: Sizes.screenWidth,
            height: Sizes.screenHeight,
            child: Column(
              children: [
                // ── Top Bar ────────────────────────────────────────
                _buildTopBar(context, hpvm),

                // ── Body ───────────────────────────────────────────
                Expanded(
                  child: data == null || data.isEmpty
                      ? _buildEmptyState(hpvm)
                      : FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        Sizes.screenWidth * 0.012,
                        Sizes.screenHeight * 0.012,
                        Sizes.screenWidth * 0.012,
                        Sizes.screenHeight * 0.012,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: OrdersListPanel(data: data),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 6,
                            child: OrderDetailsPanel(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, HubPerformanceViewModel hpvm) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          Sizes.screenWidth * 0.012, 14, Sizes.screenWidth * 0.012, 14),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 18, color: Color(0xFF374151)),
            ),
          ),
          const SizedBox(width: 14),

          // Hub icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
             color: ColorConst.primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_tree_outlined,
                color: Colors.white, size: 17),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orders · ${widget.hubName}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: -0.2),
                ),
                const Text(
                  "Today's orders from this hub",
                  style:
                  TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),

          // Order count badge
          Consumer<HubPerformanceViewModel>(
            builder: (_, vm, __) {
              final total =
                  vm.hubPerformanceOrderListModel?.data?.length ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF16A34A)
                          .withValues(alpha: 0.25)),
                ),
                child: Text('$total orders',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A))),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(HubPerformanceViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 34, color: Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 18),
          const Text('No Orders Found',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const SizedBox(height: 6),
          const Text(
              'No orders are available for this hub right now.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              vm.getHubPerformanceOrderListDataApi(context, widget.hubId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConst.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh',
                style:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}