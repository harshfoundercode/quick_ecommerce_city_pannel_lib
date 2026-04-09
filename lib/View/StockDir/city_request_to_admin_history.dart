//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_request_history_model.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';
//
// class CityRequestHistoryScreen extends StatefulWidget {
//   const CityRequestHistoryScreen({super.key});
//
//   @override
//   State<CityRequestHistoryScreen> createState() =>
//       _CityRequestHistoryScreenState();
// }
//
// class _CityRequestHistoryScreenState extends State<CityRequestHistoryScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _fadeCtrl;
//   late final Animation<double> _fadeAnim;
//
//   // Filter: -1 = all, 0 = pending, 1 = approved, 2 = rejected
//   int _filterStatus = -1;
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 400));
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final vm = Provider.of<CityStockViewModel>(context, listen: false);
//       vm.cityRequestHistoryApi(context).then((_) => _fadeCtrl.forward());
//     });
//   }
//
//   @override
//   void dispose() {
//     _fadeCtrl.dispose();
//     super.dispose();
//   }
//
//   List<_RequestGroup> _buildGroups(List<CityRequestHistoryData> raw) {
//     final Map<int, _RequestGroup> map = {};
//     for (final item in raw) {
//       final id = item.id ?? 0;
//       if (!map.containsKey(id)) {
//         map[id] = _RequestGroup(
//           id: id,
//           status: item.status ?? 0,
//           remarks: item.remarks,
//           createdAt: item.createdAt,
//           items: [],
//         );
//       }
//       map[id]!.items.add(_RequestItem(
//         name: item.name ?? '—',
//         quantity: item.quantity ?? 0,
//       ));
//     }
//     return map.values.toList()..sort((a, b) => b.id.compareTo(a.id));
//   }
//
//   String _formatDate(String? iso) {
//     if (iso == null) return '—';
//     try {
//       final dt = DateTime.parse(iso).toLocal();
//       return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
//     } catch (_) {
//       return iso;
//     }
//   }
//
//   String _relativeDate(String? iso) {
//     if (iso == null) return '';
//     try {
//       final dt = DateTime.parse(iso).toLocal();
//       final diff = DateTime.now().difference(dt);
//       if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
//       if (diff.inHours < 24) return '${diff.inHours}h ago';
//       if (diff.inDays < 7) return '${diff.inDays}d ago';
//       return DateFormat('dd MMM').format(dt);
//     } catch (_) {
//       return '';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F9),
//       appBar: _buildAppBar(context),
//       body: Consumer<CityStockViewModel>(
//         builder: (context, vm, _) {
//           if (vm.adminHistoryLoading) return _buildShimmerLoader();
//
//           final raw = vm.cityRequestHistoryModel?.data ?? [];
//           if (raw.isEmpty) return _buildEmptyState(context, vm);
//
//           final allGroups = _buildGroups(raw);
//
//           // Stats
//           final totalRequests = allGroups.length;
//           final pending = allGroups.where((g) => g.status == 0).length;
//           final approved = allGroups.where((g) => g.status == 1).length;
//           final rejected = allGroups.where((g) => g.status == 2).length;
//
//           final totalUnits = raw.fold<int>(
//             0,
//                 (s, i) => s + (int.tryParse(i.quantity?.toString() ?? '0') ?? 0),
//           );
//
//           // Filtered list
//           final groups = _filterStatus == -1
//               ? allGroups
//               : allGroups.where((g) => g.status == _filterStatus).toList();
//
//           return FadeTransition(
//             opacity: _fadeAnim,
//             child: Column(
//               children: [
//                 _buildSummarySection(
//                     totalRequests, pending, approved, rejected, totalUnits),
//                 _buildFilterBar(pending, approved, rejected),
//                 _buildListMeta(groups.length),
//                 Expanded(
//                   child: groups.isEmpty
//                       ? _buildFilterEmptyState()
//                       : ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
//                     itemCount: groups.length,
//                     itemBuilder: (_, i) => _RequestCard(
//                       group: groups[i],
//                       formatDate: _formatDate,
//                       relativeDate: _relativeDate,
//                       index: i,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ── AppBar ─────────────────────────────────────────────────────────────────
//
//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       surfaceTintColor: Colors.transparent,
//       automaticallyImplyLeading: false,
//       titleSpacing: 16,
//       title: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF16A34A), Color(0xFF15803D)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.receipt_long_rounded,
//                 color: Colors.white, size: 18),
//           ),
//           const SizedBox(width: 12),
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Stock Requests',
//                   style: TextStyle(
//                       color: Color(0xFF111827),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: -0.3)),
//               Text('Requests sent to admin',
//                   style: TextStyle(
//                       color: Color(0xFF6B7280),
//                       fontSize: 11,
//                       fontWeight: FontWeight.w400)),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         Consumer<CityStockViewModel>(
//           builder: (ctx, vm, _) => GestureDetector(
//             onTap: () {
//               _fadeCtrl.reset();
//               vm.cityRequestHistoryApi(ctx).then((_) => _fadeCtrl.forward());
//             },
//             child: Container(
//               width: 36,
//               height: 36,
//               margin: const EdgeInsets.only(right: 12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF3F4F6),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.refresh_rounded,
//                   size: 18, color: Color(0xFF374151)),
//             ),
//           ),
//         ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(height: 1, color: const Color(0xFFF3F4F6)),
//       ),
//     );
//   }
//
//   // ── Summary Section ────────────────────────────────────────────────────────
//
//   Widget _buildSummarySection(int total, int pending, int approved,
//       int rejected, int totalUnits) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                   child: _SummaryCard(
//                     label: 'Total Requests',
//                     value: '$total',
//                     icon: Icons.list_alt_rounded,
//                     iconBg: const Color(0xFFEFF6FF),
//                     iconColor: const Color(0xFF2563EB),
//                     valueColor: const Color(0xFF111827),
//                   )),
//               const SizedBox(width: 10),
//               Expanded(
//                   child: _SummaryCard(
//                     label: 'Total Units',
//                     value: '$totalUnits',
//                     icon: Icons.inventory_2_outlined,
//                     iconBg: const Color(0xFFF5F3FF),
//                     iconColor: const Color(0xFF7C3AED),
//                     valueColor: const Color(0xFF111827),
//                   )),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(
//                   child: _SummaryCard(
//                     label: 'Pending',
//                     value: '$pending',
//                     icon: Icons.hourglass_top_rounded,
//                     iconBg: const Color(0xFFFFFBEB),
//                     iconColor: const Color(0xFFD97706),
//                     valueColor: const Color(0xFFD97706),
//                   )),
//               const SizedBox(width: 10),
//               Expanded(
//                   child: _SummaryCard(
//                     label: 'Approved',
//                     value: '$approved',
//                     icon: Icons.check_circle_outline_rounded,
//                     iconBg: const Color(0xFFF0FDF4),
//                     iconColor: const Color(0xFF16A34A),
//                     valueColor: const Color(0xFF16A34A),
//                   )),
//               const SizedBox(width: 10),
//               Expanded(
//                   child: _SummaryCard(
//                     label: 'Rejected',
//                     value: '$rejected',
//                     icon: Icons.cancel_outlined,
//                     iconBg: const Color(0xFFFEF2F2),
//                     iconColor: const Color(0xFFDC2626),
//                     valueColor: const Color(0xFFDC2626),
//                   )),
//             ],
//           ),
//           // Approval rate bar
//           if (total > 0) ...[
//             const SizedBox(height: 14),
//             _ApprovalRateBar(
//                 approved: approved, rejected: rejected, pending: pending),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ── Filter Bar ─────────────────────────────────────────────────────────────
//
//   Widget _buildFilterBar(int pending, int approved, int rejected) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             _FilterPill(
//                 label: 'All',
//                 selected: _filterStatus == -1,
//                 onTap: () => setState(() => _filterStatus = -1)),
//             const SizedBox(width: 8),
//             _FilterPill(
//                 label: 'Pending',
//                 count: pending,
//                 color: const Color(0xFFD97706),
//                 selected: _filterStatus == 0,
//                 onTap: () => setState(() => _filterStatus = 0)),
//             const SizedBox(width: 8),
//             _FilterPill(
//                 label: 'Approved',
//                 count: approved,
//                 color: const Color(0xFF16A34A),
//                 selected: _filterStatus == 1,
//                 onTap: () => setState(() => _filterStatus = 1)),
//             const SizedBox(width: 8),
//             _FilterPill(
//                 label: 'Rejected',
//                 count: rejected,
//                 color: const Color(0xFFDC2626),
//                 selected: _filterStatus == 2,
//                 onTap: () => setState(() => _filterStatus = 2)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildListMeta(int count) {
//     final label = _filterStatus == -1
//         ? 'All requests'
//         : _filterStatus == 0
//         ? 'Pending'
//         : _filterStatus == 1
//         ? 'Approved'
//         : 'Rejected';
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           Text('$count $label',
//               style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF6B7280))),
//           const Spacer(),
//           const Icon(Icons.sort_rounded, size: 14, color: Color(0xFF9CA3AF)),
//           const SizedBox(width: 4),
//           const Text('Latest first',
//               style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
//         ],
//       ),
//     );
//   }
//
//   // ── Shimmer ────────────────────────────────────────────────────────────────
//
//   Widget _buildShimmerLoader() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 4,
//       itemBuilder: (_, __) => _ShimmerCard(),
//     );
//   }
//
//   // ── Empty States ───────────────────────────────────────────────────────────
//
//   Widget _buildEmptyState(BuildContext context, CityStockViewModel vm) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF9FAFB),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: const Color(0xFFE5E7EB)),
//             ),
//             child: const Icon(Icons.inbox_rounded,
//                 size: 36, color: Color(0xFFD1D5DB)),
//           ),
//           const SizedBox(height: 16),
//           const Text('No requests yet',
//               style: TextStyle(
//                   color: Color(0xFF111827),
//                   fontSize: 17,
//                   fontWeight: FontWeight.w700)),
//           const SizedBox(height: 6),
//           const Text('No stock requests have been sent to admin yet.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ColorConst.primaryGreen,
//               foregroundColor: Colors.white,
//               padding:
//               const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//               elevation: 0,
//             ),
//             onPressed: () => vm.cityRequestHistoryApi(context),
//             icon: const Icon(Icons.refresh_rounded, size: 16),
//             label: const Text('Refresh',
//                 style: TextStyle(fontWeight: FontWeight.w600)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.filter_list_off_rounded,
//               size: 40, color: Color(0xFFD1D5DB)),
//           const SizedBox(height: 12),
//           const Text('No matching requests',
//               style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
//           const SizedBox(height: 10),
//           TextButton(
//             onPressed: () => setState(() => _filterStatus = -1),
//             child: const Text('Clear filter',
//                 style: TextStyle(color: ColorConst.primaryGreen)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Approval Rate Bar ─────────────────────────────────────────────────────────
//
// class _ApprovalRateBar extends StatelessWidget {
//   final int approved;
//   final int rejected;
//   final int pending;
//
//   const _ApprovalRateBar(
//       {required this.approved,
//         required this.rejected,
//         required this.pending});
//
//   @override
//   Widget build(BuildContext context) {
//     final total = approved + rejected + pending;
//     if (total == 0) return const SizedBox.shrink();
//     final aRatio = approved / total;
//     final rRatio = rejected / total;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text('Request outcomes',
//                 style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
//             Text(
//                 '${(aRatio * 100).toStringAsFixed(0)}% approval rate',
//                 style: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF16A34A))),
//           ],
//         ),
//         const SizedBox(height: 6),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Row(
//             children: [
//               if (aRatio > 0)
//                 Expanded(
//                   flex: (aRatio * 100).round(),
//                   child: Container(height: 6, color: const Color(0xFF16A34A)),
//                 ),
//               if (rRatio > 0)
//                 Expanded(
//                   flex: (rRatio * 100).round(),
//                   child: Container(height: 6, color: const Color(0xFFDC2626)),
//                 ),
//               Expanded(
//                 flex:
//                 ((pending / total) * 100).round().clamp(0, 100),
//                 child: Container(height: 6, color: const Color(0xFFFDE68A)),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 6),
//         Row(
//           children: [
//             _legend(const Color(0xFF16A34A), 'Approved'),
//             const SizedBox(width: 12),
//             _legend(const Color(0xFFDC2626), 'Rejected'),
//             const SizedBox(width: 12),
//             _legend(const Color(0xFFFDE68A), 'Pending'),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _legend(Color color, String label) => Row(
//     children: [
//       Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(
//               color: color, borderRadius: BorderRadius.circular(2))),
//       const SizedBox(width: 4),
//       Text(label,
//           style: const TextStyle(
//               fontSize: 10, color: Color(0xFF9CA3AF))),
//     ],
//   );
// }
//
// // ── Summary Card ──────────────────────────────────────────────────────────────
//
// class _SummaryCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final Color valueColor;
//
//   const _SummaryCard({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.iconBg,
//     required this.iconColor,
//     required this.valueColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF9FAFB),
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: iconBg,
//               borderRadius: BorderRadius.circular(9),
//             ),
//             child: Icon(icon, color: iconColor, size: 17),
//           ),
//           const SizedBox(width: 9),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: const TextStyle(
//                         fontSize: 9,
//                         color: Color(0xFF9CA3AF),
//                         fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 2),
//                 Text(value,
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w800,
//                         color: valueColor,
//                         letterSpacing: -0.5)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Filter Pill ───────────────────────────────────────────────────────────────
//
// class _FilterPill extends StatelessWidget {
//   final String label;
//   final int? count;
//   final bool selected;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _FilterPill({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//     this.count,
//     this.color = const Color(0xFF374151),
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//         decoration: BoxDecoration(
//           color: selected ? color.withValues(alpha: 0.08) : const Color(0xFFF3F4F6),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//               color: selected
//                   ? color.withValues(alpha: 0.35)
//                   : const Color(0xFFE5E7EB)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(label,
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight:
//                     selected ? FontWeight.w600 : FontWeight.w500,
//                     color: selected ? color : const Color(0xFF6B7280))),
//             if (count != null) ...[
//               const SizedBox(width: 5),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? color.withValues(alpha: 0.15)
//                       : const Color(0xFFE5E7EB),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text('$count',
//                     style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                         color: selected ? color : const Color(0xFF9CA3AF))),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ── Shimmer Card ──────────────────────────────────────────────────────────────
//
// class _ShimmerCard extends StatefulWidget {
//   @override
//   State<_ShimmerCard> createState() => _ShimmerCardState();
// }
//
// class _ShimmerCardState extends State<_ShimmerCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1100))
//       ..repeat();
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) {
//         final g = LinearGradient(
//           colors: const [Color(0xFFE5E7EB), Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
//           stops: [
//             (_anim.value - 0.3).clamp(0.0, 1.0),
//             _anim.value.clamp(0.0, 1.0),
//             (_anim.value + 0.3).clamp(0.0, 1.0),
//           ],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         );
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.04),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2))
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   _box(44, 44, g, radius: 12),
//                   const SizedBox(width: 12),
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     _box(130, 13, g),
//                     const SizedBox(height: 8),
//                     _box(90, 10, g),
//                     const SizedBox(height: 6),
//                     _box(110, 9, g),
//                   ]),
//                 ],
//               ),
//               const SizedBox(height: 14),
//               _box(double.infinity, 55, g, radius: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _box(double w, double h, LinearGradient g, {double radius = 5}) =>
//       Container(
//         width: w,
//         height: h,
//         decoration: BoxDecoration(
//           gradient: g,
//           borderRadius: BorderRadius.circular(radius),
//         ),
//       );
// }
//
// // ─── Request Card ─────────────────────────────────────────────────────────────
//
// class _RequestCard extends StatefulWidget {
//   final _RequestGroup group;
//   final String Function(String?) formatDate;
//   final String Function(String?) relativeDate;
//   final int index;
//
//   const _RequestCard({
//     required this.group,
//     required this.formatDate,
//     required this.relativeDate,
//     required this.index,
//   });
//
//   @override
//   State<_RequestCard> createState() => _RequestCardState();
// }
//
// class _RequestCardState extends State<_RequestCard> {
//   bool _expanded = true;
//
//   _StatusMeta get _meta => _statusMeta(widget.group.status);
//
//   int get _totalQty =>
//       widget.group.items.fold<int>(0, (s, i) => s + i.quantity);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _meta.color.withValues(alpha: 0.15),
//         ),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withValues(alpha: 0.04),
//               blurRadius: 10,
//               offset: const Offset(0, 3)),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Status accent line on top
//           Container(
//             height: 3,
//             decoration: BoxDecoration(
//               color: _meta.color.withValues(alpha: 0.6),
//               borderRadius:
//               const BorderRadius.vertical(top: Radius.circular(16)),
//             ),
//           ),
//
//           // ── Header ─────────────────────────────────────────────────
//           InkWell(
//             onTap: () => setState(() => _expanded = !_expanded),
//             borderRadius: _expanded
//                 ? const BorderRadius.only(
//                 topLeft: Radius.circular(0),
//                 topRight: Radius.circular(0))
//                 : const BorderRadius.vertical(bottom: Radius.circular(16)),
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Request ID avatar
//                   Container(
//                     width: 46,
//                     height: 46,
//                     decoration: BoxDecoration(
//                       color: _meta.color.withValues(alpha: 0.08),
//                       borderRadius: BorderRadius.circular(13),
//                       border: Border.all(
//                           color: _meta.color.withValues(alpha: 0.2)),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(_meta.icon, size: 16, color: _meta.color),
//                         const SizedBox(height: 2),
//                         Text('#${widget.group.id}',
//                             style: TextStyle(
//                                 color: _meta.color,
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 10)),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//
//                   // Info block
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 'Request #${widget.group.id}',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 14,
//                                     color: Color(0xFF111827),
//                                     letterSpacing: -0.2),
//                               ),
//                             ),
//                             _StatusBadge(meta: _meta),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         Row(
//                           children: [
//                             _InfoPill(
//                                 icon: Icons.shopping_bag_outlined,
//                                 label:
//                                 '${widget.group.items.length} item${widget.group.items.length != 1 ? 's' : ''}'),
//                             const SizedBox(width: 8),
//                             _InfoPill(
//                                 icon: Icons.inventory_2_outlined,
//                                 label: '$_totalQty units'),
//                           ],
//                         ),
//                         const SizedBox(height: 5),
//                         Row(
//                           children: [
//                             const Icon(Icons.access_time_rounded,
//                                 size: 11, color: Color(0xFF9CA3AF)),
//                             const SizedBox(width: 3),
//                             Text(
//                               widget.formatDate(widget.group.createdAt),
//                               style: const TextStyle(
//                                   fontSize: 11, color: Color(0xFF9CA3AF)),
//                             ),
//                             const Spacer(),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFF3F4F6),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 widget.relativeDate(
//                                     widget.group.createdAt),
//                                 style: const TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w500,
//                                     color: Color(0xFF6B7280)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   AnimatedRotation(
//                     turns: _expanded ? 0.5 : 0,
//                     duration: const Duration(milliseconds: 200),
//                     child: const Icon(Icons.keyboard_arrow_down_rounded,
//                         color: Color(0xFFD1D5DB), size: 22),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // ── Expandable Body ────────────────────────────────────────
//           AnimatedCrossFade(
//             firstChild: const SizedBox.shrink(),
//             secondChild: _buildExpandedBody(),
//             crossFadeState: _expanded
//                 ? CrossFadeState.showSecond
//                 : CrossFadeState.showFirst,
//             duration: const Duration(milliseconds: 220),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildExpandedBody() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Divider(
//               height: 1,
//               color: _meta.color.withValues(alpha: 0.1),
//               thickness: 1),
//           const SizedBox(height: 12),
//
//           // ── Remarks ─────────────────────────────────────────────
//           if (widget.group.remarks != null &&
//               widget.group.remarks!.isNotEmpty) ...[
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFFBEB),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: const Color(0xFFFDE68A)),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.sticky_note_2_outlined,
//                       size: 15, color: Color(0xFFD97706)),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Admin Remarks',
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFFD97706))),
//                         const SizedBox(height: 3),
//                         Text(
//                           widget.group.remarks!,
//                           style: const TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF92400E),
//                               fontStyle: FontStyle.italic),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//           ],
//
//           // ── Items table header ───────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
//             child: Row(
//               children: const [
//                 Expanded(
//                     child: Text('PRODUCT',
//                         style: _colHeader)),
//                 SizedBox(
//                     width: 70,
//                     child: Text('QTY',
//                         style: _colHeader,
//                         textAlign: TextAlign.center)),
//                 SizedBox(
//                     width: 70,
//                     child: Text('SHARE',
//                         style: _colHeader,
//                         textAlign: TextAlign.center)),
//               ],
//             ),
//           ),
//
//           // ── Product list ─────────────────────────────────────────
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF9FAFB),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFFE5E7EB)),
//             ),
//             child: Column(
//               children: List.generate(widget.group.items.length, (i) {
//                 final item = widget.group.items[i];
//                 final isLast = i == widget.group.items.length - 1;
//                 final share = _totalQty > 0
//                     ? (item.quantity / _totalQty * 100).round()
//                     : 0;
//
//                 return Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 11),
//                       child: Row(
//                         children: [
//                           // Icon
//                           Container(
//                             padding: const EdgeInsets.all(7),
//                             decoration: BoxDecoration(
//                               color: ColorConst.primaryExtraLightGreen,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(Icons.shopping_bag_outlined,
//                                 size: 14,
//                                 color: ColorConst.primaryGreen),
//                           ),
//                           const SizedBox(width: 10),
//                           // Product name
//                           Expanded(
//                             child: Text(
//                               item.name,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 13,
//                                   color: Color(0xFF111827)),
//                             ),
//                           ),
//                           // Qty badge
//                           SizedBox(
//                             width: 70,
//                             child: Center(
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 10, vertical: 5),
//                                 decoration: BoxDecoration(
//                                   color: ColorConst.primaryExtraLightGreen,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   '${item.quantity}',
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w800,
//                                       color: ColorConst.primaryGreen),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // Share bar
//                           SizedBox(
//                             width: 70,
//                             child: Column(
//                               children: [
//                                 Text('$share%',
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w600,
//                                         color: Color(0xFF6B7280))),
//                                 const SizedBox(height: 3),
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(3),
//                                   child: LinearProgressIndicator(
//                                     value: share / 100,
//                                     minHeight: 4,
//                                     backgroundColor:
//                                     const Color(0xFFE5E7EB),
//                                     valueColor:
//                                     const AlwaysStoppedAnimation(
//                                         ColorConst.primaryGreen),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (!isLast)
//                       const Divider(
//                           height: 1,
//                           indent: 14,
//                           endIndent: 14,
//                           color: Color(0xFFE5E7EB)),
//                   ],
//                 );
//               }),
//             ),
//           ),
//
//           // ── Request ID footer ────────────────────────────────────
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF3F4F6),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   'REQ-${widget.group.id.toString().padLeft(4, '0')}',
//                   style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF9CA3AF),
//                       letterSpacing: 0.5),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// const _colHeader = TextStyle(
//     fontSize: 9,
//     fontWeight: FontWeight.w700,
//     color: Color(0xFF9CA3AF),
//     letterSpacing: 0.8);
//
// // ── Info Pill ─────────────────────────────────────────────────────────────────
//
// class _InfoPill extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   const _InfoPill({required this.icon, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 11, color: const Color(0xFF9CA3AF)),
//         const SizedBox(width: 3),
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 11,
//                 color: Color(0xFF6B7280),
//                 fontWeight: FontWeight.w500)),
//       ],
//     );
//   }
// }
//
// // ── Status Badge ──────────────────────────────────────────────────────────────
//
// class _StatusBadge extends StatelessWidget {
//   final _StatusMeta meta;
//   const _StatusBadge({required this.meta});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: meta.color.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: meta.color.withValues(alpha: 0.25)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(meta.icon, size: 11, color: meta.color),
//           const SizedBox(width: 4),
//           Text(meta.label,
//               style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                   color: meta.color)),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Status helpers ────────────────────────────────────────────────────────────
//
// _StatusMeta _statusMeta(int status) {
//   switch (status) {
//     case 0:
//       return const _StatusMeta(
//           'Pending', Color(0xFFD97706), Icons.hourglass_top_rounded);
//     case 1:
//       return const _StatusMeta(
//           'Approved', Color(0xFF059669), Icons.check_circle_outline_rounded);
//     case 2:
//       return const _StatusMeta(
//           'Rejected', Color(0xFFDC2626), Icons.cancel_outlined);
//     default:
//       return const _StatusMeta(
//           'Unknown', Color(0xFF9CA3AF), Icons.help_outline_rounded);
//   }
// }
//
// class _StatusMeta {
//   final String label;
//   final Color color;
//   final IconData icon;
//   const _StatusMeta(this.label, this.color, this.icon);
// }
//
// // ─── Local models (UI only) ───────────────────────────────────────────────────
//
// class _RequestGroup {
//   final int id;
//   final int status;
//   final String? remarks;
//   final String? createdAt;
//   final List<_RequestItem> items;
//
//   _RequestGroup({
//     required this.id,
//     required this.status,
//     this.remarks,
//     this.createdAt,
//     required this.items,
//   });
// }
//
// class _RequestItem {
//   final String name;
//   final int quantity;
//   const _RequestItem({required this.name, required this.quantity});
// }