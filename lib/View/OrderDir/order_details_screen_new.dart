import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/order_view_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/InvoiceDir/invoice_generate.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/order_view_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  static const Map<int, _TrackMeta> trackMap = {
    0: _TrackMeta('Order Placed', Icons.receipt_long_outlined, Color(0xFF2563EB)),
    1: _TrackMeta('Confirmed', Icons.verified_outlined, Color(0xFF7C3AED)),
    2: _TrackMeta('Picked Up', Icons.inventory_2_outlined, Color(0xFFD97706)),
    3: _TrackMeta('Out for Delivery', Icons.delivery_dining_outlined, Color(0xFF0891B2)),
    4: _TrackMeta('Delivered', Icons.done_all_rounded, Color(0xFF059669)),
    5: _TrackMeta('Cancelled', Icons.cancel_outlined, Color(0xFFDC2626)),
  };

  static const Map<int, _StatusMeta> statusMap = {
    0: _StatusMeta('Placed', Color(0xFF2563EB)),
    1: _StatusMeta('Confirmed', Color(0xFF7C3AED)),
    2: _StatusMeta('Picked', Color(0xFFD97706)),
    3: _StatusMeta('Out for Delivery', Color(0xFF0891B2)),
    4: _StatusMeta('Completed', Color(0xFF059669)),
    5: _StatusMeta('Cancelled', Color(0xFFDC2626)),
    6: _StatusMeta('Returned', Color(0xFF9CA3AF)),
  };

  static const Map<int, _PayMeta> paymentStatusMap = {
    0: _PayMeta('Pending', Color(0xFFD97706)),
    1: _PayMeta('Paid', Color(0xFF059669)),
    2: _PayMeta('Failed', Color(0xFFDC2626)),
    3: _PayMeta('Refunded', Color(0xFF7C3AED)),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderDetails = Provider.of<OrderDetailsViewModel>(context,listen: false);
      orderDetails.orderDetailsApi(
        context,
        widget.orderId,
        showLoader: true,
      );
    });
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      appBar: _buildAppBar(),
      body: Consumer<OrderDetailsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading || vm.orderViewDataModel == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A5F)),
            );
          }

          final d = vm.orderViewDataModel!.data;
          final order = d?.order;
          final items = d?.items ?? [];
          final payment = d?.payment;
          final tracking = d?.tracking ?? [];
          final orderStatus = statusMap[order?.status] ?? statusMap[0]!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Order header card ──────────────────────────────────
                _buildOrderHeaderCard(order, orderStatus),
                const SizedBox(height: 14),

                // ── Tracking timeline ──────────────────────────────────
                if (tracking.isNotEmpty) ...[
                  _sectionTitle('Order Tracking', Icons.timeline_rounded),
                  const SizedBox(height: 8),
                  _buildTrackingTimeline(tracking),
                  const SizedBox(height: 14),
                ],

                // ── Items ──────────────────────────────────────────────
                _sectionTitle('Items Ordered', Icons.shopping_bag_outlined),
                const SizedBox(height: 8),
                _buildItemsList(items),
                const SizedBox(height: 14),

                // ── Price summary ──────────────────────────────────────
                _sectionTitle('Price Summary', Icons.receipt_outlined),
                const SizedBox(height: 8),
                _buildPriceSummary(order),
                const SizedBox(height: 14),

                // ── Payment info ───────────────────────────────────────
                if (payment != null) ...[
                  _sectionTitle('Payment Details', Icons.payment_rounded),
                  const SizedBox(height: 8),
                  _buildPaymentCard(payment),
                  const SizedBox(height: 14),
                ],

                // ── Delivery info ──────────────────────────────────────
                _sectionTitle('Delivery Info', Icons.local_shipping_outlined),
                const SizedBox(height: 8),
                _buildDeliveryCard(order),
                const SizedBox(height: 14),

                // ── Customer info ──────────────────────────────────────
                _sectionTitle('Customer Info', Icons.person_outline_rounded),
                const SizedBox(height: 8),
                _buildCustomerCard(order), const SizedBox(height: 8),

                InvoiceDownloadButton(model: vm.orderViewDataModel!),
              ],
            ),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Order Details',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700)),
      actions: [
        Consumer<OrderDetailsViewModel>(
          builder: (ctx, vm, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 20),
            onPressed: () => vm.orderDetailsApi(ctx, widget.orderId,
                showLoader: true),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Order header ───────────────────────────────────────────────────────────

  Widget _buildOrderHeaderCard(Order? order, _StatusMeta statusMeta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusMeta.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long_outlined,
                    size: 22, color: statusMeta.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order?.orderNo ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: Color(0xFF111827))),
                    const SizedBox(height: 3),
                    Text(_formatDate(order?.createdAt),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              _buildStatusBadge(statusMeta),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(Icons.store_outlined,
                  order?.hubName ?? '—', const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              _infoChip(Icons.payment_outlined,
                  (order?.paymentMethod ?? '—').toUpperCase(),
                  const Color(0xFF7C3AED)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(_StatusMeta meta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.color.withValues(alpha: 0.3)),
      ),
      child: Text(meta.label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: meta.color)),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  // ── Tracking Timeline ──────────────────────────────────────────────────────

  Widget _buildTrackingTimeline(List<Tracking> tracking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: List.generate(tracking.length, (i) {
          final t = tracking[i];
          final meta =
              trackMap[t.status] ?? trackMap[0]!;
          final isLast = i == tracking.length - 1;
          final isLatest = i == tracking.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isLatest
                            ? meta.color
                            : meta.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: meta.color,
                            width: isLatest ? 0 : 1.5),
                      ),
                      child: Icon(meta.icon,
                          size: 15,
                          color: isLatest
                              ? Colors.white
                              : meta.color),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: const Color(0xFFE5E7EB),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Text column
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meta.label,
                          style: TextStyle(
                              fontWeight: isLatest
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 13,
                              color: isLatest
                                  ? meta.color
                                  : const Color(0xFF374151))),
                      const SizedBox(height: 2),
                      Text(_formatDate(t.createdAt),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Items list ─────────────────────────────────────────────────────────────

  Widget _buildItemsList(List<Items> items) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Product image placeholder
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 22,
                          color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(item.productName ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF111827))),
                          const SizedBox(height: 3),
                          Text(
                            '₹${item.price} × ${item.qty}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.totalPrice}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF111827)),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: Color(0xFFF3F4F6)),
            ],
          );
        }),
      ),
    );
  }

  // ── Price summary ──────────────────────────────────────────────────────────

  Widget _buildPriceSummary(Order? order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _priceRow('Subtotal', '₹${order?.totalAmount ?? "0.00"}',
              false),
          const SizedBox(height: 8),
          _priceRow('Delivery Charge',
              '₹${order?.deliveryCharge ?? "0.00"}', false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          _priceRow('Total Amount',
              '₹${order?.finalAmount ?? "0.00"}', true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isBold ? 14 : 13,
                fontWeight:
                isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold
                    ? const Color(0xFF111827)
                    : const Color(0xFF6B7280))),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 16 : 13,
                fontWeight:
                isBold ? FontWeight.w800 : FontWeight.w500,
                color: isBold
                    ? const Color(0xFF059669)
                    : const Color(0xFF374151))),
      ],
    );
  }

  // ── Payment card ───────────────────────────────────────────────────────────

  Widget _buildPaymentCard(Payment payment) {
    final payMeta = paymentStatusMap[payment.status] ??
        paymentStatusMap[0]!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _detailRow('Transaction ID',
              payment.transactionId ?? '—',
              Icons.confirmation_number_outlined),
          const SizedBox(height: 10),
          _detailRow('Method',
              (payment.paymentMethod ?? '—').toUpperCase(),
              Icons.payment_rounded),
          const SizedBox(height: 10),
          _detailRow(
              'Amount', '₹${payment.amount ?? "0.00"}',
              Icons.currency_rupee_rounded),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.circle_outlined,
                  size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              const Text('Status',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: payMeta.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: payMeta.color.withValues(alpha: 0.3)),
                ),
                child: Text(payMeta.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: payMeta.color)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Delivery card ──────────────────────────────────────────────────────────

  Widget _buildDeliveryCard(Order? order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _detailRow('Delivery Partner',
              order?.deliveryName ?? 'Not Assigned',
              Icons.delivery_dining_outlined),
          const SizedBox(height: 10),
          _detailRow('Partner Phone',
              order?.deliveryPhone ?? '—', Icons.phone_outlined),
          const SizedBox(height: 10),
          _detailRow('Hub', order?.hubName ?? '—',
              Icons.store_outlined),
          const SizedBox(height: 10),
          _detailRow(
              'Address',
              [
                order?.address,
                order?.landmark,
                order?.city,
                order?.pincode
              ]
                  .where((e) => e != null && e.toString().isNotEmpty)
                  .join(', '),
              Icons.location_on_outlined),
        ],
      ),
    );
  }

  // ── Customer card ──────────────────────────────────────────────────────────

  Widget _buildCustomerCard(Order? order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _detailRow('Name', order?.customerName ?? '—',
              Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _detailRow('Phone', order?.customerPhone ?? '—',
              Icons.phone_outlined),
        ],
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1E3A5F)),
        const SizedBox(width: 7),
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A5F))),
      ],
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF6B7280))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827))),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade100),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2)),
    ],
  );
}

// ─── Meta helpers ─────────────────────────────────────────────────────────────

class _TrackMeta {
  final String label;
  final IconData icon;
  final Color color;
  const _TrackMeta(this.label, this.icon, this.color);
}

class _StatusMeta {
  final String label;
  final Color color;
  const _StatusMeta(this.label, this.color);
}

class _PayMeta {
  final String label;
  final Color color;
  const _PayMeta(this.label, this.color);
}