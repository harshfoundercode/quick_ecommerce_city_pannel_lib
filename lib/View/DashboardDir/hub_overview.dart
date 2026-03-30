// import 'package:flutter/material.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/view_all_hub_list_screen.dart';
//
// class HubManagementTable extends StatefulWidget {
//   final List<Hubs>? dashboardHubData;
//   const HubManagementTable({super.key, required this.dashboardHubData});
//
//   @override
//   State<HubManagementTable> createState() => _HubManagementTableState();
// }
//
// class _HubManagementTableState extends State<HubManagementTable> {
//
//   final searchController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final mobileSize = Responsive.isMobile(context);
//
//     final hubs = widget.dashboardHubData ?? [];
//     final showLimited = hubs.length > 3;
//     final displayList = showLimited ? hubs.take(3).toList() : hubs;
//
//     return CustomWidgets.cardWrapper(
//       height: mobileSize ? Sizes.screenHeight:null,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildTopBar(mobileSize,widget.dashboardHubData),
//           CustomWidgets.verticalSpace(0.02),
//           if (!mobileSize) hubTableHeader(),
//           CustomWidgets.verticalSpace(0.01),
//           SizedBox(
//             height: mobileSize ?Sizes.screenHeight*0.65:Sizes.screenHeight*0.35,
//             child: ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount:displayList.length,
//               itemBuilder: (context, index) {
//                 final hub = displayList[index];
//                 return mobileSize
//                     ? _buildHubMobileCard(hub)
//                     : _buildHubRow(hub, index);
//               },
//             ),
//           ),
//           if (showLimited)
//             Center(
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => ViewAllHubsScreen(hubs: hubs),
//                     ),
//                   );
//                 },
//                 child: const Text(
//                   "View All",
//                   style: TextStyle(
//                     color: ColorConst.primaryGreen,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   void _showHubDetails(Hubs hub) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: ColorConst.primaryGreen.withValues(
//                     alpha: 0.1,
//                   ),
//                   child: Icon(Icons.dashboard, color: ColorConst.primaryGreen),
//                 ),
//                 title: Text(hub.hubName ?? "N/n"),
//                 subtitle: Text(hub.address ?? "N/n"),
//               ),
//               const Divider(),
//               _buildDetailRow("Delivery Boys", hub.deliveryBoys.toString()),
//               _buildDetailRow(
//                 "Orders in Progress",
//                 hub.inProgress.toString(),
//               ),
//               _buildDetailRow("Completed Today", hub.completedToday.toString()),
//               _buildDetailRow("Status", hub.status==1 ? "Active" : "Inactive"),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
//
//
//   // ================= TOP BAR =================
//
//   Widget _buildTopBar(bool isMobile, List<Hubs>? dashboardHubData) {
//     if (isMobile) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CustomWidgets.hubHeader(
//               title: "Hub Management",
//               subtitle: "Monitor and manage all hubs in Lucknow",
//               titleSize: 20,
//               subtitleSize: 15
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(child: CustomWidgets.searchField(controller: searchController,width: double.infinity)),
//               const SizedBox(width: 8),
//               // _buildFilterDropdown(dashboardHubData),
//             ],
//           ),
//         ],
//       );
//     }
//
//     return Row(
//       children: [
//         Expanded(child:  CustomWidgets.hubHeader(
//             title: "Hub Management",
//             subtitle: "Monitor and manage all hubs in Lucknow",
//             titleSize: 18,
//             subtitleSize: 10
//         )),
//         CustomWidgets.searchField(controller: searchController,width: 200),
//         SizedBox(width: Sizes.screenWidth * 0.01),
//         // _buildFilterDropdown(dashboardHubData),
//       ],
//     );
//   }
//
//
//   Widget hubTableHeader() {
//     return CustomWidgets.tableHeader(
//       headers: const ["Hub Information", "Delivery Boys", "In Progress", "Completed", "Status"],
//       flexValues: const [3, 1, 1, 1, 1],
//     );
//   }
//
//   // ================= DESKTOP ROW =================
//
//   Widget _buildHubRow(Hubs hub, int index) {
//     return InkWell(
//       onTap: (){
//         _showHubDetails(hub);
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         decoration: BoxDecoration(
//           color: index.isEven ? Colors.white : Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: ColorConst.borderColor),
//         ),
//         child: Row(
//           children: [
//             SizedBox(
//               width: Sizes.screenWidth*0.34,
//               child: Row(
//                 children: [
//                   hubIcon(icon: Icons.dashboard),
//                   const SizedBox(width: 12),
//                   hubText(name: hub.hubName ?? "N/n", location: hub.address ?? "N/n"),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: metric(
//                 value: hub.deliveryBoys.toString(),
//                 label: "Delivery boys",
//                 color: Colors.blue,
//               ),
//             ),
//             Expanded(
//               child: metric(
//                 value: hub.inProgress.toString(),
//                 label: "Orders in progress",
//                 color: Colors.orange,
//               ),
//             ),
//             Expanded(
//               child: metric(
//                 value: hub.completedToday.toString(),
//                 label: "Completed today",
//                 color: Colors.green,
//               ),
//             ),
//             Expanded(child: CustomWidgets.statusBadge(isActive: hub.status==1?true:false)),
//             _buildArrowButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ================= MOBILE CARD =================
//
//   Widget _buildHubMobileCard(Hubs hub) {
//     return InkWell(
//       onTap: (){
//         _showHubDetails(hub);
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: ColorConst.borderColor),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 hubIcon(icon: Icons.dashboard_customize_sharp),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: hubText(name: hub.hubName ?? "N/n", location: hub.address ?? "N/n"),
//                 ),
//                 CustomWidgets.statusBadge(isActive: hub.status==1?true:false,width: Sizes.screenWidth*0.18)
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Divider(),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _mobileMetric(hub.deliveryBoys.toString(), "Boys", Colors.blue),
//                 _mobileMetric(
//                   hub.inProgress.toString(),
//                   "Progress",
//                   Colors.orange,
//                 ),
//                 _mobileMetric(
//                   hub.completedToday.toString(),
//                   "Done",
//                   Colors.green,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _mobileMetric(String value, String label, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
//         ),
//       ],
//     );
//   }
//
//   // ================= COMMON WIDGETS =================
//
//   Widget _buildArrowButton() => Container(
//     height: 36,
//     width: 36,
//     decoration: BoxDecoration(
//       color: const Color(0xFFF1F5F9),
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: const Icon(Icons.chevron_right, color: ColorConst.primaryGreen),
//   );
//
//   Widget hubIcon({required IconData icon}) => Container(
//     height: 44,
//     width: 44,
//     decoration: BoxDecoration(
//       color: ColorConst.primaryExtraLightGreen,
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Icon(icon, color: ColorConst.primaryGreen),
//   );
//
//   Widget hubText({required String name, required String location}) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         "Hub - $name",
//         maxLines: 1,
//         style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//       ),
//       const SizedBox(height: 2),
//       SizedBox(
//         width: Sizes.screenWidth*0.22,
//         child: Text(
//           location,
//           maxLines: 2,
//           style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//         ),
//       ),
//     ],
//   );
//
//   Widget metric({
//     required String value,
//     required String label,
//     required Color color,
//   }) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         value,
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w700,
//           color: color,
//         ),
//       ),
//       const SizedBox(height: 2),
//       Text(
//         label,
//         style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//       ),
//     ],
//   );
//
// }
//
//
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/view_all_hub_list_screen.dart';

class HubManagementTable extends StatefulWidget {
  final List<Hubs>? dashboardHubData;
  const HubManagementTable({super.key, required this.dashboardHubData});

  @override
  State<HubManagementTable> createState() => _HubManagementTableState();
}

class _HubManagementTableState extends State<HubManagementTable>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  late AnimationController _listCtrl;


  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _listCtrl.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  List<Hubs> get _filtered {
    final all = widget.dashboardHubData ?? [];
    if (_searchQuery.isEmpty) return all;
    return all
        .where((h) =>
    (h.hubName ?? '').toLowerCase().contains(
        _searchQuery.toLowerCase()) ||
        (h.address ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final filtered = _filtered;
    final displayList =
    filtered.length > 4 ? filtered.take(4).toList() : filtered;
    final hasMore = filtered.length > 4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          _buildHeader(isMobile),
          const SizedBox(height: 16),

          // ── Table header (desktop only) ──────────────────────────
          if (!isMobile) _buildTableHeader(),
          if (!isMobile) const SizedBox(height: 8),

          // ── List ────────────────────────────────────────────────
          ...List.generate(displayList.length, (i) {
            final hub = displayList[i];
            final delay = i * 0.1;
            return AnimatedBuilder(
              animation: _listCtrl,
              builder: (context, child) {
                final p = Curves.easeOut.transform(
                    ((_listCtrl.value - delay).clamp(0.0, 1.0)));
                return Opacity(
                  opacity: p,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - p)),
                    child: child,
                  ),
                );
              },
              child: isMobile
                  ? _buildMobileCard(hub)
                  : _buildDesktopRow(hub, i),
            );
          }),

          // ── View all ─────────────────────────────────────────────
          if (hasMore) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewAllHubsScreen(
                        hubs: widget.dashboardHubData ?? []),
                  ),
                ),
                icon: const Icon(Icons.expand_more_rounded,
                    size: 16, color: ColorConst.primaryGreen),
                label: Text(
                  'View All ${widget.dashboardHubData?.length ?? 0} Hubs',
                  style: const TextStyle(
                    color: ColorConst.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isMobile) {
    return isMobile
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleRow(),
        const SizedBox(height: 12),
        _searchField(),
      ],
    )
        : Row(
      children: [
        Expanded(child: _titleRow()),
        _searchField(width: 200),
      ],
    );
  }

  Widget _titleRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorConst.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.account_tree_outlined,
              color: ColorConst.primaryGreen, size: 18),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hub Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              'Monitor and manage all hubs',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _searchField({double? width}) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search_rounded,
              size: 16, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
              decoration: const InputDecoration(
                hintText: 'Search hubs…',
                hintStyle:
                TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() {
                _searchCtrl.clear();
                _searchQuery = '';
              }),
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.close_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
              ),
            ),
        ],
      ),
    );
  }

  // ── Desktop table header ──────────────────────────────────────────────────

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text('Hub',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5)),
          ),
          ..._tableHeaderLabel('Riders'),
          ..._tableHeaderLabel('In Progress'),
          ..._tableHeaderLabel('Completed'),
          ..._tableHeaderLabel('Status'),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  List<Widget> _tableHeaderLabel(String label) => [
    Expanded(
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5),
      ),
    ),
  ];

  // ── Desktop row ───────────────────────────────────────────────────────────

  Widget _buildDesktopRow(Hubs hub, int index) {
    return InkWell(
      onTap: () => _showDetails(hub),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: index.isEven ? Colors.white : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _hubAvatar(hub.hubName ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hub.hubName ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hub.address ?? 'N/A',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _metricCell(
                  hub.deliveryBoys.toString(), const Color(0xFF2563EB)),
            ),
            Expanded(
              child: _metricCell(
                  hub.inProgress.toString(), const Color(0xFFF59E0B)),
            ),
            Expanded(
              child: _metricCell(
                  hub.completedToday.toString(), const Color(0xFF10B981)),
            ),
            Expanded(
              child: _statusBadge(hub.status == 1),
            ),
            _arrowBtn(),
          ],
        ),
      ),
    );
  }

  // ── Mobile card ───────────────────────────────────────────────────────────

  Widget _buildMobileCard(Hubs hub) {
    return InkWell(
      onTap: () => _showDetails(hub),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hub name + status
            Row(
              children: [
                _hubAvatar(hub.hubName ?? ''),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hub.hubName ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 11, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              hub.address ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF9CA3AF)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusBadge(hub.status == 1),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 10),

            // Metrics row
            Row(
              children: [
                _mobileStat(
                    hub.deliveryBoys.toString(),
                    'Riders',
                    Icons.pedal_bike_outlined,
                    const Color(0xFF2563EB)),
                _vDivider(),
                _mobileStat(
                    hub.inProgress.toString(),
                    'In Progress',
                    Icons.sync_rounded,
                    const Color(0xFFF59E0B)),
                _vDivider(),
                _mobileStat(
                    hub.completedToday.toString(),
                    'Completed',
                    Icons.check_circle_outline_rounded,
                    const Color(0xFF10B981)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Details bottom sheet ──────────────────────────────────────────────────

  void _showDetails(Hubs hub) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Hub name + avatar
              Row(
                children: [
                  _hubAvatar(hub.hubName ?? '', size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hub.hubName ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hub.address ?? 'N/A',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(hub.status == 1),
                ],
              ),

              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade100),
              const SizedBox(height: 14),

              // Stats grid
              Row(
                children: [
                  _detailStat(
                    hub.deliveryBoys.toString(),
                    'Delivery Boys',
                    Icons.pedal_bike_outlined,
                    const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  _detailStat(
                    hub.inProgress.toString(),
                    'In Progress',
                    Icons.sync_rounded,
                    const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 10),
                  _detailStat(
                    hub.completedToday.toString(),
                    'Completed',
                    Icons.check_circle_outline_rounded,
                    const Color(0xFF10B981),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Shared sub-widgets ────────────────────────────────────────────────────

  Widget _hubAvatar(String name, {double size = 42}) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'H';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: ColorConst.primaryGreen,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }

  Widget _metricCell(String value, Color color) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget _mobileStat(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                fontSize: 10, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _detailStat(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowBtn() => Container(
    width: 32,
    height: 32,
    margin: const EdgeInsets.only(left: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.chevron_right_rounded,
        color: ColorConst.primaryGreen, size: 18),
  );

  Widget _vDivider() => Container(
    width: 1,
    height: 36,
    color: const Color(0xFFF1F5F9),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}