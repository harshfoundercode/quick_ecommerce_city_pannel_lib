import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/orders_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/order_details_screen_new.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/order_view_model.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // status int → label/color mapping
  static const Map<int, _StatusMeta> statusMap = {
    0: _StatusMeta('Placed', Color(0xFF2563EB), Icons.receipt_long_outlined),
    1: _StatusMeta('Confirmed', Color(0xFF7C3AED), Icons.check_circle_outline),
    2: _StatusMeta('Picked', Color(0xFFD97706), Icons.inventory_2_outlined),
    3: _StatusMeta(
      'Out for Delivery',
      Color(0xFF0891B2),
      Icons.delivery_dining_outlined,
    ),
    4: _StatusMeta('Completed', Color(0xFF059669), Icons.done_all_rounded),
    5: _StatusMeta('Cancelled', Color(0xFFDC2626), Icons.cancel_outlined),
    6: _StatusMeta(
      'Returned',
      Color(0xFF9CA3AF),
      Icons.keyboard_return_rounded,
    ),
  };

  final List<_TabFilter> _tabs = const [
    _TabFilter('All', null),
    _TabFilter('Placed', 0),
    _TabFilter('Confirmed', 1),
    _TabFilter('Picked', 2),
    _TabFilter('Out', 3),
    _TabFilter('Done', 4),
    _TabFilter('Cancelled', 5),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderDetailsData = Provider.of<OrderDetailsViewModel>(context,listen: false);
      orderDetailsData.getOrdersListDataApi(context);
    });
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Orders> _filtered(List<Orders> all, int? statusFilter) {
    return all.where((o) {
      final matchStatus = statusFilter == null || o.status == statusFilter;
      final matchSearch =
          _searchQuery.isEmpty ||
          (o.orderNo ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (o.customerName ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchStatus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      appBar: _buildAppBar(),
      body: Consumer<OrderDetailsViewModel>(
        builder: (context, vm, _) {
          if (vm.orderDataModel == null) {
            return const Center(
              child: CircularProgressIndicator(color: ColorConst.primaryGreen),
            );
          }

          final summary = vm.orderDataModel!.data;
          final allOrders = summary?.orders ?? [];

          if (allOrders == null || allOrders.isEmpty) {
            return Padding(
              padding:  EdgeInsets.symmetric(vertical: Sizes.screenHeight*0.4),
              child: Center(child: CustomText.bold("No Orders found")),
            );
          }

          return Column(
            children: [
              // ── Summary cards ──────────────────────────────────────────
              _buildSummaryStrip(summary),

              // ── Search ─────────────────────────────────────────────────
              _buildSearchBar(),

              // ── Status tabs ────────────────────────────────────────────
              _buildTabBar(),

              // ── Order list ─────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    final filtered = _filtered(allOrders, tab.statusCode);
                    if (filtered.isEmpty) return _buildEmptyState(tab.label);
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => orderCard(
                        order: filtered[i],
                        statusMeta:
                            statusMap[filtered[i].status] ?? statusMap[0]!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(
                                orderId: filtered[i].id.toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorConst.primaryGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'City order management',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
      actions: [
        Consumer<OrderDetailsViewModel>(
          builder: (ctx, vm, _) => IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => vm.getOrdersListDataApi(ctx),
            tooltip: 'Refresh',
          ),
        ),
        const SizedBox(width: 4),

      ],
    );
  }

  // ── Summary strip ──────────────────────────────────────────────────────────

  Widget _buildSummaryStrip(OrderData? data) {
    final tiles = [
      _SummaryTile(
        'Total',
        '${data?.total ?? 0}',
        ColorConst.primaryGreen,
        Icons.list_alt_rounded,
      ),
      _SummaryTile(
        'Placed',
        data?.placed ?? '0',
        ColorConst.primaryGreen,
        Icons.receipt_long_outlined,
      ),
      _SummaryTile(
        'Confirmed',
        data?.confirmed ?? '0',
        ColorConst.primaryGreen,
        Icons.check_circle_outline,
      ),
      _SummaryTile(
        'Cancelled',
        data?.cancelled ?? '0',
        ColorConst.primaryGreen,
        Icons.cancel_outlined,
      ),
    ];

    return Container(
      color: ColorConst.primaryExtraLightGreen,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: tiles
            .map(
              (t) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: tiles.indexOf(t) == 0 ? 0 : 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: t.color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(t.icon, color: ColorConst.primaryGreen, size: 16),
                      const SizedBox(height: 4),
                      Text(
                        t.value,
                        style: const TextStyle(
                          color: ColorConst.primaryGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        t.label,
                        style: const TextStyle(
                          color: ColorConst.primaryGreen,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search by order no. or customer name...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: ColorConst.primaryGreen,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: ColorConst.primaryGreen,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        indicatorColor: ColorConst.primaryGreen,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No $label orders',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget statusChip({required final _StatusMeta meta}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: meta.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            meta.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: meta.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget orderCard({
    required final Orders order,
    required final _StatusMeta statusMeta,
    required final VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // ── Top row ──────────────────────────────────────────────
              Row(
                children: [
                  // Order icon
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: statusMeta.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      statusMeta.icon,
                      size: 18,
                      color: statusMeta.color,
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNo ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              order.customerName ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  statusChip(meta: statusMeta),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 10),

              // ── Bottom row ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amount
                  Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee_rounded,
                        size: 14,
                        color: Color(0xFF374151),
                      ),
                      Text(
                        order.totalAmount ?? '0.00',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),

                  // Arrow
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFD1D5DB),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _StatusMeta {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusMeta(this.label, this.color, this.icon);
}

class _TabFilter {
  final String label;
  final int? statusCode;
  const _TabFilter(this.label, this.statusCode);
}

class _SummaryTile {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _SummaryTile(this.label, this.value, this.color, this.icon);
}
