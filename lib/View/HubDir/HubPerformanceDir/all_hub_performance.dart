// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/utils.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_model.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/view_all_order_specific_hub.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/view_all_hub_performance_screen.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';
//
// class AllHubsPerformanceScreen extends StatefulWidget {
//   const AllHubsPerformanceScreen({super.key});
//
//   @override
//   State<AllHubsPerformanceScreen> createState() =>
//       _AllHubsPerformanceScreenState();
// }
//
// class _AllHubsPerformanceScreenState extends State<AllHubsPerformanceScreen> {
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final hubPerformance = Provider.of<HubPerformanceViewModel>(
//         context,
//         listen: false,
//       );
//       hubPerformance.getHubPerformanceDataApi(context);
//     });
//     // TODO: implement initState
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HubPerformanceViewModel>(
//       builder: (context, hvm, child) {
//         final hubData = hvm.hubPerformanceModel?.data?.hubs;
//         final summaryData = hvm.hubPerformanceModel?.data?.summary;
//
//         if (hubData == null || hubData.isEmpty) {
//           return Text("No data found");
//         }
//
//         return SingleChildScrollView(
//           padding: EdgeInsets.all(Sizes.screenWidth * 0.015),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CustomWidgets.pageHeader(
//                 title: "All Hubs Performance",
//                 subtitle: "City Overview",
//               ),
//               CustomWidgets.verticalSpace(0.025),
//               statsSection(summaryData: summaryData),
//               CustomWidgets.verticalSpace(0.025),
//               performanceTableCard(context, hubData),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget statsSection({Summary? summaryData}) {
//     final stats = [
//       {
//         'title': "Total Deliveries",
//         'value': summaryData?.totalDeliveries.toString() ?? "-",
//         'icon': Icons.check_circle_outline,
//       },
//       {
//         'title': "Avg Success Rate",
//         'value': "${summaryData?.avgSuccessRate.toString() ?? "-"} %",
//         'icon': Icons.analytics_outlined,
//       },
//       {
//         'title': "Active Delivery Boys",
//         'value': summaryData?.activeDeliveryBoys.toString() ?? "-",
//         'icon': Icons.timer_outlined,
//       },
//       {
//         'title': "Total Hubs",
//         'value': summaryData?.totalHubs.toString() ?? "-",
//         'icon': Icons.cancel_outlined,
//       },
//     ];
//
//     return CustomWidgets.statsRow(stats: stats, isMobile: false);
//   }
//
//   Widget performanceTableCard(BuildContext context, List<Hubs> hubData) {
//     final hubs = hubData;
//     final showLimited = hubs.length > 4;
//     final displayList = showLimited ? hubs.take(4).toList() : hubs;
//     return CustomWidgets.cardWrapperWithActionWidget(
//       title: "Hub Performance Details",
//       actionWidget: _buildRefreshButton(context),
//       child: Column(
//         children: [
//           _buildEnhancedTableHeader(),
//           const Divider(height: 24, thickness: 1, color: Color(0xFFE5E7EB)),
//           ListView.builder(
//             itemCount: displayList.length,
//             shrinkWrap: true,
//             itemBuilder: (BuildContext context, int i) {
//               return _buildEnhancedHubRow(
//                 context,
//                 name: displayList[i].hubName,
//                 orders: displayList[i].totalOrders.toString(),
//                 rate: "${displayList[i].successRate.toString()} %",
//                 time: "${displayList[i].avgDeliveryTime.toString()} Min",
//                 boys: displayList[i].activeBoys.toString(),
//                 hubId:displayList[i].hubId.toString()
//               );
//             },
//           ),
//           SizedBox(height: Sizes.screenHeight*0.02),
//           if(displayList.length>4)
//           AppBtn(
//             title: "View All Hubs Performance",
//             onTap: () {
//               openRightDrawer(context,ViewAllHubPerformanceScreen(hub:hubs));
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEnhancedTableHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: _buildHeaderCell("Hub Details", Icons.location_city),
//           ),
//           Expanded(
//             child: _buildHeaderCell("Total Orders", Icons.shopping_cart),
//           ),
//           Expanded(child: _buildHeaderCell("Success Rate", Icons.percent)),
//           Expanded(child: _buildHeaderCell("Avg. Delivery", Icons.timer)),
//           Expanded(child: _buildHeaderCell("Active Boys", Icons.pedal_bike)),
//           Expanded(child: _buildHeaderCell("Status", Icons.circle)),
//           Container(width: 40),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeaderCell(String label, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, size: 14, color: Colors.grey.shade600),
//         const SizedBox(width: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade700,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Enhanced Hub Row
//   Widget _buildEnhancedHubRow(
//     BuildContext context, {
//     required String name,
//     required String orders,
//     required String rate,
//     required String time,
//     required String boys,
//         required String hubId,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           SizedBox(
//             width: Sizes.screenWidth*0.235,
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: ColorConst.primaryGreen.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.account_tree_outlined,
//                     size: 16,
//                     color: ColorConst.primaryGreen,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CustomText.medium(name, fontSize: 14),
//                       const SizedBox(height: 2),
//                       CustomText.regular(
//                         "ID: HUB${name.hashCode.abs() % 1000}",
//                         fontSize: 10,
//                         color: Colors.grey.shade500,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           CustomText.bold(orders, fontSize: 16),
//
//           SizedBox(width: Sizes.screenWidth*0.055),
//           SizedBox(
//             width: Sizes.screenWidth*0.1,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomText.bold(rate, fontSize: 16, color: ColorConst.primaryGreen),
//                 const SizedBox(height: 2),
//                 LinearProgressIndicator(
//                   value: double.parse(rate.replaceAll('%', '')) / 100,
//                   backgroundColor: ColorConst.primaryGreen.withValues(alpha: 0.2),
//                   valueColor: AlwaysStoppedAnimation<Color>(ColorConst.primaryGreen),
//                   minHeight: 4,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(width: Sizes.screenWidth * 0.028),
//           SizedBox(
//             width: Sizes.screenWidth*0.048,
//             child: Row(
//               children: [
//                 Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
//                  SizedBox(width: Sizes.screenWidth*0.007),
//                 CustomText.medium(time, fontSize: 13),
//               ],
//             ),
//           ),
//           SizedBox(width: Sizes.screenWidth * 0.058),
//           SizedBox(
//             width: Sizes.screenWidth*0.023,
//             child: Row(
//               children: [
//                 Icon(Icons.person, size: 12, color: Colors.grey.shade500),
//                 const SizedBox(width: 4),
//                 CustomText.medium(boys, fontSize: 13),
//               ],
//             ),
//           ),
//           SizedBox(width: Sizes.screenWidth*0.08,),
//           _buildViewOrdersButton(context, name,hubId),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildViewOrdersButton(BuildContext context, String hubName, String hubId) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//
//           openRightDrawer(context, ViewAllOrderSpecificHub(hubName: hubName,hubId:hubId));
//         },
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: ColorConst.primaryGreen.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             Icons.visibility_outlined,
//             size: 18,
//             color: ColorConst.primaryGreen,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRefreshButton(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           Utils.show("Refreshing data...", context);
//         },
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Icon(Icons.refresh, size: 16, color: Colors.grey.shade700),
//         ),
//       ),
//     );
//   }
//
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/utils.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/view_all_order_specific_hub.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/view_all_hub_performance_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';

class AllHubsPerformanceScreen extends StatefulWidget {
  const AllHubsPerformanceScreen({super.key});

  @override
  State<AllHubsPerformanceScreen> createState() =>
      _AllHubsPerformanceScreenState();
}

class _AllHubsPerformanceScreenState extends State<AllHubsPerformanceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<HubPerformanceViewModel>(context, listen: false);
      vm.getHubPerformanceDataApi(context).then((_) => _fadeCtrl.forward());
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
      builder: (context, hvm, child) {
        final hubData = hvm.hubPerformanceModel?.data?.hubs;
        final summaryData = hvm.hubPerformanceModel?.data?.summary;

        if (hubData == null || hubData.isEmpty) {
          return _buildEmptyState();
        }

        final showLimited = hubData.length > 4;
        final displayList =
        showLimited ? hubData.take(4).toList() : hubData;

        return FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Sizes.screenWidth * 0.015),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page header ─────────────────────────────────────
                _buildPageHeader(context, hvm),
                const SizedBox(height: 24),

                // ── Stats ────────────────────────────────────────────
                _buildStatsSection(summaryData),
                const SizedBox(height: 24),

                // ── Performance table ────────────────────────────────
                _buildPerformanceCard(context, hubData, displayList),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Page Header ─────────────────────────────────────────────────────────

  Widget _buildPageHeader(
      BuildContext context, HubPerformanceViewModel hvm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.analytics_outlined,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('All Hubs Performance',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: -0.3)),
                      Text('City Overview · Live Data',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Refresh button
        GestureDetector(
          onTap: () {
            _fadeCtrl.reset();
            hvm.getHubPerformanceDataApi(context)
                .then((_) => _fadeCtrl.forward());
            Utils.show("Refreshing data...", context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.refresh_rounded,
                    size: 15, color: Color(0xFF374151)),
                SizedBox(width: 6),
                Text('Refresh',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Stats Section ────────────────────────────────────────────────────────

  Widget _buildStatsSection(Summary? s) {
    final stats = [
      _PerfStat(
        title: 'Total Deliveries',
        value: s?.totalDeliveries?.toString() ?? '—',
        icon: Icons.local_shipping_outlined,
        iconBg: const Color(0xFFF0FDF4),
        iconColor: const Color(0xFF16A34A),
        valueColor: const Color(0xFF16A34A),
      ),
      _PerfStat(
        title: 'Avg Success Rate',
        value: '${s?.avgSuccessRate?.toString() ?? '—'}%',
        icon: Icons.analytics_outlined,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
        valueColor: const Color(0xFF111827),
      ),
      _PerfStat(
        title: 'Active Delivery Boys',
        value: s?.activeDeliveryBoys?.toString() ?? '—',
        icon: Icons.pedal_bike_outlined,
        iconBg: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFEA580C),
        valueColor: const Color(0xFF111827),
      ),
      _PerfStat(
        title: 'Total Hubs',
        value: s?.totalHubs?.toString() ?? '—',
        icon: Icons.hub_outlined,
        iconBg: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFF7C3AED),
        valueColor: const Color(0xFF111827),
      ),
    ];

    return Row(
      children: stats
          .map((stat) => Expanded(
        child: Padding(
          padding:
          EdgeInsets.only(right: stat == stats.last ? 0 : 10),
          child: _PerfStatCard(stat: stat),
        ),
      ))
          .toList(),
    );
  }

  // ── Performance Card ─────────────────────────────────────────────────────

  Widget _buildPerformanceCard(
      BuildContext context, List<Hubs> allHubs, List<Hubs> displayList) {
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
      child: Column(
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                const Text('Hub Performance Details',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.2)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${allHubs.length} hubs',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280))),
                ),
                const Spacer(),
                // Live badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF16A34A)
                            .withValues(alpha: 0.25)),
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
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Table header
          _buildTableHeader(),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, i) =>
                _HubPerformanceRow(hub: displayList[i], context: context),
          ),

          // View all footer
          if (allHubs.length > 4) ...[
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'Showing ${displayList.length} of ${allHubs.length}  ·  ',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF))),
                  GestureDetector(
                    onTap: () => openRightDrawer(
                        context,
                        ViewAllHubPerformanceScreen(hub: allHubs)),
                    child: const Text('View All →',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColorConst.primaryGreen)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    const style = TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.8);
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('HUB', style: style)),
          Expanded(flex: 2, child: Text('ORDERS', style: style)),
          Expanded(flex: 2, child: Text('SUCCESS RATE', style: style)),
          Expanded(flex: 2, child: Text('AVG DELIVERY', style: style)),
          Expanded(flex: 1, child: Text('BOYS', style: style)),
          SizedBox(width: 44, child: Text('VIEW', style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            child: const Icon(Icons.analytics_outlined,
                size: 32, color: Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 16),
          const Text('No performance data',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const SizedBox(height: 6),
          const Text('Hub data will appear here once available.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

// ── Hub Performance Row ────────────────────────────────────────────────────────

class _HubPerformanceRow extends StatelessWidget {
  final Hubs hub;
  final BuildContext context;
  const _HubPerformanceRow({required this.hub, required this.context});

  double get _rate =>
      (double.tryParse(hub.successRate?.toString() ?? '0') ?? 0) / 100;

  Color get _rateColor {
    if (_rate >= 0.85) return const Color(0xFF16A34A);
    if (_rate >= 0.65) return const Color(0xFFCA8A04);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Hub info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_tree_outlined,
                      size: 16, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hub.hubName ?? '—',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          'ID: ${hub.hubId?.toString() ?? '—'}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Orders
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 13, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 5),
                Text(hub.totalOrders?.toString() ?? '—',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
              ],
            ),
          ),

          // Success Rate
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${hub.successRate?.toString() ?? '—'}%',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _rateColor)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _rate.clamp(0.0, 1.0),
                    backgroundColor:
                    _rateColor.withValues(alpha: 0.12),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(_rateColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),

          // Avg delivery time
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 13, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 5),
                Text('${hub.avgDeliveryTime?.toString() ?? '—'} min',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
              ],
            ),
          ),

          // Active boys
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(Icons.pedal_bike_outlined,
                    size: 13, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(hub.activeBoys?.toString() ?? '—',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
              ],
            ),
          ),

          // View orders button
          SizedBox(
            width: 44,
            child: Center(
              child: GestureDetector(
                onTap: () => openRightDrawer(
                    context,
                    ViewAllOrderSpecificHub(
                        hubName: hub.hubName ?? '',
                        hubId: hub.hubId?.toString() ?? '')),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                        color: const Color(0xFF16A34A)
                            .withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.visibility_outlined,
                      size: 15, color: Color(0xFF16A34A)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _PerfStat {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color valueColor;

  const _PerfStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.valueColor,
  });
}

class _PerfStatCard extends StatelessWidget {
  final _PerfStat stat;
  const _PerfStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: stat.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: stat.iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.title,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(stat.value,
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: stat.valueColor,
                        letterSpacing: -0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}