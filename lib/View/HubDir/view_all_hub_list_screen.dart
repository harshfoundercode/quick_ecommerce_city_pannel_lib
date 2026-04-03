
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart' show ColorConst;
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/view_hub_details.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/edit_hub_details.dart';

import '../../ModelDir/hub_list_model.dart';

class AllHubListFullScreen extends StatefulWidget {
  final List<Hubs> hubs;
  const AllHubListFullScreen({super.key, required this.hubs});

  @override
  State<AllHubListFullScreen> createState() =>
      _AllHubListFullScreenState();
}

class _AllHubListFullScreenState extends State<AllHubListFullScreen> {
  String _searchQuery = '';
  int _filterStatus = -1;

  List<Hubs> get _filtered => widget.hubs.where((h) {
    final ms = _searchQuery.isEmpty ||
        (h.hubName ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
        (h.address ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
        (h.managerName ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
    final mf = _filterStatus == -1 || h.status == _filterStatus;
    return ms && mf;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    final active = widget.hubs.where((h) => h.status == 1).length;
    final inactive = widget.hubs.length - active;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF374151)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Hubs',
                style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            Text('${widget.hubs.length} hubs total',
                style: const TextStyle(
                    color: Color(0xFF9CA3AF), fontSize: 11)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF3F4F6)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            // Search + filter
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      onChanged: (v) =>
                          setState(() => _searchQuery = v),
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search hubs…',
                        hintStyle: TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF)),
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 18, color: Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _HubFilterChip(
                        label: 'All',
                        count: widget.hubs.length,
                        selected: _filterStatus == -1,
                        onTap: () =>
                            setState(() => _filterStatus = -1),
                      ),
                      const SizedBox(width: 8),
                      _HubFilterChip(
                        label: 'Active',
                        count: active,
                        color: const Color(0xFF16A34A),
                        selected: _filterStatus == 1,
                        onTap: () =>
                            setState(() => _filterStatus = 1),
                      ),
                      const SizedBox(width: 8),
                      _HubFilterChip(
                        label: 'Inactive',
                        count: inactive,
                        color: const Color(0xFF9CA3AF),
                        selected: _filterStatus == 0,
                        onTap: () =>
                            setState(() => _filterStatus = 0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildTableHeader(),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            // List
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 36, color: Color(0xFFD1D5DB)),
                    const SizedBox(height: 10),
                    const Text('No hubs found',
                        style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => setState(() {
                        _searchQuery = '';
                        _filterStatus = -1;
                      }),
                      child: const Text('Clear filters',
                          style: TextStyle(
                              color: ColorConst.primaryGreen)),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final hub = _filtered[index];
                  return Column(
                    children: [
                      mobile
                          ? _HubMobileCard(
                        hub: hub,
                        onView: () => openRightDrawer(
                            context,
                            ViewHubDetails(
                                hubName: hub.hubName,
                                hubId:
                                hub.hubId.toString())),
                        onEdit: () => openRightDrawer(context, EditCityDrawer(
                                hubId: hub.hubId
                                    .toString())),
                      )
                          : _HubDesktopRow(
                        hub: hub,
                        onView: () => openRightDrawer(
                            context,
                            ViewHubDetails(
                                hubName: hub.hubName,
                                hubId:
                                hub.hubId.toString())),
                        onEdit: () => openRightDrawer(
                            context,
                            EditCityDrawer(
                                hubId: hub.hubId
                                    .toString())),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTableHeader() {
    const style = TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.8);
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
              width: Sizes.screenWidth*0.275,
              child: Text('HUB DETAILS', style: style)),
          SizedBox(
              width: Sizes.screenWidth*0.187,
              child: Text('MANAGER', style: style)),
          SizedBox(
              width: Sizes.screenWidth*0.05,
              child: Text('WORKFORCE', style: style)),
          SizedBox(width: Sizes.screenWidth*0.04),
          SizedBox(
              width: Sizes.screenWidth*0.03,
              child: Text('ORDERS', style: style)),
          SizedBox(width: Sizes.screenWidth*0.058),
          SizedBox(
              width: Sizes.screenWidth*0.03,
              child: Text('STATUS', style: style)),
          Spacer(),
          SizedBox(
              width: Sizes.screenWidth*0.04,
              child: Text('ACTIONS', style: style, textAlign: TextAlign.center)),
          SizedBox(width: Sizes.screenWidth*0.01),
        ],
      ),
    );
  }
}
class _HubFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _HubFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color = const Color(0xFF374151),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.08)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.35)
                  : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? color : const Color(0xFF6B7280))),
            const SizedBox(width: 5),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.15)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: selected ? color : const Color(0xFF9CA3AF))),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubDesktopRow extends StatelessWidget {
  final Hubs hub;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _HubDesktopRow({
    required this.hub,
    required this.onView,
    required this.onEdit,
  });

  bool get _isActive => hub.status == 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: Sizes.screenWidth*0.272,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hub.hubName.toUpperCase() ?? "-",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: ColorConst.textBlack)),
                SizedBox(height: Sizes.screenHeight*0.001),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 10, color: ColorConst.textGrey),
                    SizedBox(width: Sizes.screenWidth*0.002),
                    Text(hub.address ?? '—',
                        style: const TextStyle(
                            fontSize: 11,
                            color: ColorConst.textGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
              width: Sizes.screenWidth*0.17,
              child: _ManagerCell(hub: hub)),
          SizedBox(width: Sizes.screenWidth*0.014),
          SizedBox(
            width: Sizes.screenWidth*0.045,
            child: Center(
              child: Text('${hub.deliveryBoys ?? 0}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
            ),
          ),
          SizedBox(width: Sizes.screenWidth*0.04),
          // Orders
          SizedBox(
            width: Sizes.screenWidth*0.035,
            child: Center(
              child: Text('${hub.activeOrders ?? 0}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
            ),
          ),
          SizedBox(width: Sizes.screenWidth*0.044),
          // Status
          SizedBox(
              width: Sizes.screenWidth*0.06,
              child: _StatusPill(isActive: _isActive)),
          Spacer(),
          // Actions
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconBtn(
                    icon: Icons.visibility_outlined,
                    color: const Color(0xFF2563EB),
                    onTap: onView),
                const SizedBox(width: 8),
                _IconBtn(
                    icon: Icons.edit_outlined,
                    color: const Color(0xFF6B7280),
                    onTap: onEdit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

class _ManagerCell extends StatelessWidget {
  final Hubs hub;
  const _ManagerCell({required this.hub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hub.managerName ?? '—',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        if (hub.managerPhone != null)
          Text(hub.managerPhone!,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isActive;
  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color =
    isActive ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _HubMobileCard extends StatelessWidget {
  final Hubs hub;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _HubMobileCard({
    required this.hub,
    required this.onView,
    required this.onEdit,
  });

  bool get _isActive => hub.status == 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isActive
              ? const Color(0xFF16A34A).withValues(alpha: 0.15)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Accent top bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: _isActive
                  ? const Color(0xFF16A34A).withValues(alpha: 0.5)
                  : const Color(0xFFE5E7EB),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hub info + status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hub avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: _isActive
                            ? const LinearGradient(
                          colors: [
                            Color(0xFF16A34A),
                            Color(0xFF15803D)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        color: _isActive ? null : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.hub_outlined,
                          color:
                          _isActive ? Colors.white : const Color(0xFF9CA3AF),
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hub.hubName ?? '—',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF111827),
                                      letterSpacing: -0.2),
                                ),
                              ),
                              _StatusPill(isActive: _isActive),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 11, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  hub.address ?? '—',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Hub #${hub.hubId}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 12),

                // Manager row
                _ManagerRow(hub: hub),

                const SizedBox(height: 10),

                // Metrics row
                Row(
                  children: [
                    Expanded(
                        child: _MetricTile(
                          icon: Icons.pedal_bike_outlined,
                          value: '${hub.deliveryBoys ?? 0}',
                          label: 'Delivery Boys',
                          iconColor: const Color(0xFFEA580C),
                          iconBg: const Color(0xFFFFF7ED),
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _MetricTile(
                          icon: Icons.receipt_long_outlined,
                          value: '${hub.activeOrders ?? 0}',
                          label: 'Active Orders',
                          iconColor: const Color(0xFF7C3AED),
                          iconBg: const Color(0xFFF5F3FF),
                        )),
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'View Details',
                        icon: Icons.visibility_outlined,
                        onTap: onView,
                        primary: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Edit Hub',
                        icon: Icons.edit_outlined,
                        onTap: onEdit,
                        primary: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBg;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.3)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: primary
              ? ColorConst.primaryGreen
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: primary
              ? null
              : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14,
                color: primary
                    ? Colors.white
                    : const Color(0xFF374151)),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primary
                        ? Colors.white
                        : const Color(0xFF374151))),
          ],
        ),
      ),
    );
  }
}

class _ManagerRow extends StatelessWidget {
  final Hubs hub;
  const _ManagerRow({required this.hub});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.person_outline_rounded,
              size: 15, color: Color(0xFF2563EB)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hub.managerName ?? '—',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              if (hub.managerPhone != null)
                Text(hub.managerPhone!,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ],
    );
  }
}
