
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_view_order_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';

class OrderDetailsPanel extends StatelessWidget {
  const OrderDetailsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HubPerformanceViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return _buildLoadingState();
        }

        final details = vm.hubPerformanceViewOrderDetailsModel;
        if (details == null ||
            details.data == null ||
            (details.data!.items?.isEmpty ?? true)) {
          return _buildEmptyState();
        }

        final order = details.data!;
        return _OrderDetailView(order: order);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: ColorConst.primaryGreen,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  size: 30, color: Color(0xFFD1D5DB)),
            ),
            const SizedBox(height: 16),
            const Text('No Order Selected',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
            const SizedBox(height: 6),
            const Text(
              'Select an order from the list\nto view its details',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF16A34A)
                        .withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back_rounded,
                      size: 14, color: Color(0xFF16A34A)),
                  SizedBox(width: 6),
                  Text('Select from list',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Detail View
// ─────────────────────────────────────────────────────────────────────────────

class _OrderDetailView extends StatelessWidget {
  final HubPerformanceViewOrderDetailsData order;

  const _OrderDetailView({required this.order});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case '1':
        return const Color(0xFF16A34A);
      case '2':
        return const Color(0xFF2563EB);
      case '3':
        return const Color(0xFFCA8A04);
      case '4':
        return const Color(0xFFDC2626);
      default:
        return Colors.deepOrange;
    }
  }

  String _formatDate(String? t) {
    try {
      final dt = DateTime.tryParse(t ?? '') ?? DateTime.now();
      return DateFormat('dd MMM yyyy · hh:mm a').format(dt);
    } catch (_) {
      return DateFormat('dd MMM yyyy · hh:mm a').format(DateTime.now());
    }
  }

  String _addMinutes(String? t, int mins) {
    try {
      final dt =
      (DateTime.tryParse(t ?? '') ?? DateTime.now()).add(Duration(minutes: mins));
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return DateFormat('hh:mm a')
          .format(DateTime.now().add(Duration(minutes: mins)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusStr = order.order?.status?.toString() ?? '';
    final statusColor = _statusColor(statusStr);

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────
            _buildHeader(statusStr, statusColor),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Timeline ──────────────────────────────────────
                  _buildSection(
                    title: 'Order Timeline',
                    icon: Icons.timeline_rounded,
                    iconColor: const Color(0xFF2563EB),
                    child: _buildTimeline(statusStr),
                  ),
                  const SizedBox(height: 20),

                  // ── Info grid ─────────────────────────────────────
                  _buildSection(
                    title: 'Order Information',
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    child: _buildInfoGrid(),
                  ),
                  const SizedBox(height: 20),

                  // ── Order items ───────────────────────────────────
                  _buildSection(
                    title: 'Order Items',
                    icon: Icons.shopping_bag_outlined,
                    iconColor: ColorConst.primaryGreen,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                          '${order.items?.length ?? 0} items',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280))),
                    ),
                    child: _buildItemsList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Payment summary ───────────────────────────────
                  _buildPaymentSummary(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader(String statusStr, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(16)),
        border: const Border(
            bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded,
                      size: 18, color: Color(0xFF16A34A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order ID',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 2),
                      Text(
                        order.order?.orderNo?.toString() ?? '—',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: -0.3),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _StatusPill(
                              label: statusStr, color: statusColor),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 11, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 3),
                              Text(
                                _formatDate(order.order?.createdAt
                                    ?.toString()),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action chips
          Row(
            children: [
              _ActionChip(
                  icon: Icons.print_rounded,
                  label: 'Print',
                  onTap: () {}),
              const SizedBox(width: 8),
              _ActionChip(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Wrapper ─────────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 14, color: iconColor),
                ),
                const SizedBox(width: 9),
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  // ── Timeline ────────────────────────────────────────────────────────────

  Widget _buildTimeline(String statusStr) {
    final events = [
      _TEvent('Order Placed',
          _formatDate(order.order?.createdAt?.toString()),
          'Order placed successfully', Icons.shopping_cart_rounded,
          'completed'),
      _TEvent('Order Confirmed',
          _addMinutes(order.order?.createdAt?.toString(), 5),
          'Order confirmed', Icons.check_circle_rounded,
          statusStr == 'cancelled' ? 'cancelled' : 'completed'),
      _TEvent('Picked Up',
          _addMinutes(order.order?.createdAt?.toString(), 15),
          order.order?.deliveryBoy?.toString() ?? 'Delivery boy',
          Icons.pedal_bike_rounded,
          statusStr == 'pending' ? 'pending' :
          statusStr == 'cancelled' ? 'cancelled' : 'completed'),
      _TEvent('Out for Delivery',
          _addMinutes(order.order?.createdAt?.toString(), 25),
          'Order is on the way', Icons.local_shipping_rounded,
          statusStr == 'in transit' ? 'active' :
          statusStr == 'delivered' ? 'completed' :
          statusStr == 'cancelled' ? 'cancelled' : 'pending'),
      _TEvent('Delivered',
          _addMinutes(order.order?.createdAt?.toString(), 45),
          'Order delivered', Icons.check_box_rounded,
          statusStr == 'delivered' ? 'completed' : 'pending'),
    ];

    return Column(
      children: List.generate(events.length, (i) {
        return _TimelineItem(
            event: events[i], isLast: i == events.length - 1);
      }),
    );
  }

  // ── Info Grid ────────────────────────────────────────────────────────────

  Widget _buildInfoGrid() {
    final o = order.order;
    final payStatusLabel = o?.paymentStatus == 0
        ? 'Pending'
        : o?.paymentStatus == 1
        ? 'Success'
        : 'Failed';
    final payStatusColor = o?.paymentStatus == 1
        ? const Color(0xFF16A34A)
        : o?.paymentStatus == 0
        ? const Color(0xFFCA8A04)
        : const Color(0xFFDC2626);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                title: 'Customer',
                icon: Icons.person_rounded,
                iconColor: const Color(0xFF2563EB),
                rows: [
                  _InfoRow('Name', o?.customerName?.toString() ?? '—'),
                  _InfoRow('Phone', o?.phone?.toString() ?? '—'),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoCard(
                title: 'Delivery Address',
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFF16A34A),
                rows: [
                  _InfoRow('Address', o?.address?.toString() ?? '—'),
                  _InfoRow('Pincode', o?.pincode?.toString() ?? '—'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                title: 'Delivery Partner',
                icon: Icons.delivery_dining_rounded,
                iconColor: const Color(0xFFEA580C),
                rows: [
                  _InfoRow('Name', o?.deliveryBoy?.toString() ?? 'Not Assigned'),
                  _InfoRow('Phone', o?.phone?.toString() ?? '—'),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoCard(
                title: 'Payment',
                icon: Icons.payment_rounded,
                iconColor: const Color(0xFF7C3AED),
                rows: [
                  _InfoRow('Method', o?.paymentMethod?.toString() ?? '—'),
                ],
                badge: _InfoBadge(
                    label: payStatusLabel, color: payStatusColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Items List ───────────────────────────────────────────────────────────

  Widget _buildItemsList() {
    final items = order.items ?? [];
    if (items.isEmpty) {
      return const Text('No items',
          style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)));
    }
    return Column(
      children: [
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border:
                  Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 20, color: Color(0xFFD1D5DB)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName?.toString() ?? '—',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF111827))),
                    const SizedBox(height: 3),
                    Text('Qty: ${item.qty} × ₹${item.price}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Text('₹${item.totalPrice}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF16A34A))),
            ],
          ),
        )),

        // Special instructions note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.note_alt_rounded,
                  size: 15, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Special Instructions',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade800)),
                    const SizedBox(height: 3),
                    Text(
                        'Please deliver to the back entrance. Call upon arrival.',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Payment Summary ─────────────────────────────────────────────────────

  Widget _buildPaymentSummary() {
    final o = order.order;
    final subtotal = o?.totalAmount?.toString() ?? '0';
    final delivery = o?.deliveryCharge?.toString() ?? '0';
    final total = o?.totalAmount?.toString() ?? '0';
    final method = o?.paymentMethod?.toString() ?? '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF16A34A).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.receipt_rounded,
                    size: 14, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 9),
              const Text('Payment Summary',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 14),
          _summaryRow('Subtotal', '₹$subtotal'),
          const SizedBox(height: 8),
          _summaryRow('Delivery Fee', '₹$delivery'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E7EB)),
          ),
          _summaryRow('Total Amount', '₹$total', isTotal: true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.payment_rounded,
                    size: 13, color: Color(0xFF6B7280)),
                const SizedBox(width: 7),
                const Text('Payment Method:',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(width: 5),
                Text(method,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 14 : 12,
                fontWeight:
                isTotal ? FontWeight.w600 : FontWeight.normal,
                color: isTotal
                    ? const Color(0xFF111827)
                    : const Color(0xFF6B7280))),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 17 : 13,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                color: isTotal
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF374151),
                letterSpacing: isTotal ? -0.3 : 0)),
      ],
    );
  }
}

// ── Timeline Item ─────────────────────────────────────────────────────────────

class _TEvent {
  final String title;
  final String time;
  final String description;
  final IconData icon;
  final String status; // completed | active | pending | cancelled

  const _TEvent(this.title, this.time, this.description, this.icon,
      this.status);
}

class _TimelineItem extends StatelessWidget {
  final _TEvent event;
  final bool isLast;

  const _TimelineItem({required this.event, required this.isLast});

  Color get _color {
    switch (event.status) {
      case 'completed':
        return const Color(0xFF16A34A);
      case 'active':
        return const Color(0xFF2563EB);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD1D5DB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: _color.withValues(alpha: 0.3), width: 1.5),
              ),
              child:
              Icon(event.icon, size: 15, color: _color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _color.withValues(alpha: 0.4),
                      _color.withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(event.title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: event.status == 'active'
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: event.status == 'pending'
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF111827))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(event.time,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280))),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(event.description,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}

class _InfoBadge {
  final String label;
  final Color color;
  const _InfoBadge({required this.label, required this.color});
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_InfoRow> rows;
  final _InfoBadge? badge;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.rows,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 13, color: iconColor),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151))),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badge!.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: badge!.color.withValues(alpha: 0.2)),
                  ),
                  child: Text(badge!.label,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: badge!.color)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 52,
                  child: Text(r.label,
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF))),
                ),
                Expanded(
                  child: Text(r.value,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF6B7280)),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}