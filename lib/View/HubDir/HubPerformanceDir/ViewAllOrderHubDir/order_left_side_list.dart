
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_order_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';

class OrdersListPanel extends StatefulWidget {
  final List<HubPerformanceOrderListData> data;

  const OrdersListPanel({super.key, required this.data});

  @override
  State<OrdersListPanel> createState() => _OrdersListPanelState();
}

class _OrdersListPanelState extends State<OrdersListPanel> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HubPerformanceViewModel>(context);

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Panel Header ─────────────────────────────────────────
          _buildPanelHeader(vm),

          // ── Search ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _buildSearchField(vm),
          ),

          // ── Filter Chips ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _buildFilterChips(vm),
          ),

          // ── Column Headers ───────────────────────────────────────
          _buildColumnHeaders(),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Orders List ──────────────────────────────────────────
          Expanded(
            child: vm.orders.isEmpty
                ? _buildNoResultsState(vm)
                : Scrollbar(
              controller: _scrollController,
              radius: const Radius.circular(8),
              thickness: 4,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                itemCount: vm.orders.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final order = vm.orders[index];
                  final isSelected =
                      vm.selectedOrder?.orderNo == order.orderNo;
                  return _OrderListItem(
                    order: order,
                    isSelected: isSelected,
                    onTap: () => vm.selectOrder(context, order),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHeader(HubPerformanceViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: Color(0xFF16A34A), size: 16),
          ),
          const SizedBox(width: 10),
          const Text('Orders',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.2)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${vm.orders.length}',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280))),
          ),
          const Spacer(),
          // Live indicator
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle)),
                const SizedBox(width: 5),
                const Text('LIVE',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                        letterSpacing: 0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(HubPerformanceViewModel vm) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: vm.updateSearch,
        style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: 'Search order ID, customer…',
          hintStyle:
          const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 17, color: Color(0xFF9CA3AF)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 15, color: Color(0xFF9CA3AF)),
            onPressed: () {
              _searchController.clear();
              vm.updateSearch('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildFilterChips(HubPerformanceViewModel vm) {
    final filters = [
      _FilterDef('All', Icons.view_list_rounded, null),
      _FilterDef(
          'Delivered', Icons.check_circle_rounded, const Color(0xFF16A34A)),
      _FilterDef(
          'In Transit', Icons.local_shipping_rounded, const Color(0xFF2563EB)),
      _FilterDef(
          'Pending', Icons.pending_actions_rounded, const Color(0xFFCA8A04)),
      _FilterDef(
          'Cancelled', Icons.cancel_rounded, const Color(0xFFDC2626)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = vm.selectedFilter == f.label;
          final color =
              f.color ?? (isSelected ? ColorConst.primaryGreen : null);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => vm.updateFilter(f.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (color ?? ColorConst.primaryGreen)
                      .withValues(alpha: 0.1)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (color ?? ColorConst.primaryGreen)
                        .withValues(alpha: 0.35)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(f.icon,
                        size: 13,
                        color: isSelected
                            ? (color ?? ColorConst.primaryGreen)
                            : const Color(0xFF6B7280)),
                    const SizedBox(width: 5),
                    Text(f.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? (color ?? ColorConst.primaryGreen)
                                : const Color(0xFF6B7280))),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumnHeaders() {
    const style = TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.7);
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('ORDER ID', style: style)),
          Expanded(child: Text('CUSTOMER', style: style)),
          Expanded(child: Text('AMOUNT', style: style)),
          Expanded(child: Text('STATUS', style: style)),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(HubPerformanceViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 32, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 10),
          const Text('No orders match',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              vm.updateSearch('');
              vm.updateFilter('All');
            },
            child: const Text('Clear filters',
                style: TextStyle(
                    color: ColorConst.primaryGreen, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _FilterDef {
  final String label;
  final IconData icon;
  final Color? color;
  const _FilterDef(this.label, this.icon, this.color);
}

// ── Order List Item ───────────────────────────────────────────────────────────

class _OrderListItem extends StatelessWidget {
  final HubPerformanceOrderListData order;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderListItem({
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF16A34A);
      case 'in transit':
        return const Color(0xFF2563EB);
      case 'pending':
        return const Color(0xFFCA8A04);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  String _formatAmount(dynamic amount) {
    final n = double.tryParse(amount?.toString() ?? '0') ?? 0;
    return n.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText = order.statusText ?? '';
    final sColor = _statusColor(statusText);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF16A34A).withValues(alpha: 0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF16A34A).withValues(alpha: 0.25)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Order ID
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNo?.toString() ?? '—',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isSelected
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF111827)),
                  ),
                ],
              ),
            ),

            // Customer
            Expanded(
              child: Text(
                order.customerName ?? '—',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF374151)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Amount
            Expanded(
              child: Text(
                '₹${_formatAmount(order.finalAmount)}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827)),
              ),
            ),

            // Status
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: sColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: sColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: sColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}