import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/RevenueDir/hub_wise_revenue_check.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/RevenueDir/revenue_overview_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/RevenueDir/transaction_history_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/revenue_view_model.dart';

class RevenueView extends StatefulWidget {
  const RevenueView({super.key});

  @override
  State<RevenueView> createState() => _RevenueViewState();
}

class _RevenueViewState extends State<RevenueView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedView = "Overview";
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: ColorConst.cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: ColorConst.borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RevenueViewModel>();
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),

            _buildEnhancedFilterBar(vm, context),
            const SizedBox(height: 20),

            _buildViewTabs(),
            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RevenueOverviewScreen(vm: vm,tabController:_tabController),
                  HubWiseRevenueCheck(vm:vm),
                  TransactionHistoryList(vm:vm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorConst.primaryGreen.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: ColorConst.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Revenue Analytics",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Track your earnings and performance",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderChip(
              icon: Icons.download_rounded,
              label: "Export",
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _buildHeaderChip(
              icon: Icons.refresh_rounded,
              label: "Refresh",
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFilterBar(RevenueViewModel vm, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              // Hub Selector with Icon
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: vm.selectedHub,
                      isExpanded: true,
                      items: ["All Hubs", "Gomti Nagar Hub", "Indira Nagar Hub", "Alambagh Hub", "Charbagh Hub"]
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_rounded,
                              size: 16,
                              color: ColorConst.primaryGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(e),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (v) {},
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Date Range Picker
              Expanded(
                flex: 3,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              primaryColor: ColorConst.primaryGreen,
                              colorScheme: const ColorScheme.light(
                                primary: ColorConst.primaryGreen,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        vm.dateRange = picked;
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: ColorConst.primaryGreen,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              vm.dateRange == null
                                  ? "Select Date Range"
                                  : "${_formatDate(vm.dateRange!.start)} - ${_formatDate(vm.dateRange!.end)}",
                              style: TextStyle(
                                fontSize: 13,
                                color: vm.dateRange == null
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Quick Filters
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    _buildQuickFilterChip("Today", vm),
                    _buildQuickFilterChip("Week", vm),
                    _buildQuickFilterChip("Month", vm),
                  ],
                ),
              ),
            ],
          ),

          // Advanced Filters Toggle
          if (_showFilters) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFilterChip("Payment Method", ["All", "Cash", "Online", "Card"]),
                const SizedBox(width: 10),
                _buildFilterChip("Order Type", ["All", "Delivery", "Pickup"]),
              ],
            ),
          ],

          // Toggle Button
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              icon: Icon(
                _showFilters ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 16,
              ),
              label: Text(_showFilters ? "Show Less Filters" : "More Filters"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, RevenueViewModel vm) {
    final isSelected = _selectedView == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedView = label;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? ColorConst.primaryGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String title, List<String> options) {
    return Expanded(
      child: Row(
        children: [
          Text(
            "$title:",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: options.first,
                  isExpanded: true,
                  items: options.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 12)),
                  )).toList(),
                  onChanged: (v) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTabs() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorConst.primaryGreen.withValues(alpha:0.1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: ColorConst.primaryGreen,
        unselectedLabelColor: Colors.grey.shade600,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart_rounded, size: 18),
                SizedBox(width: 8),
                Text("Overview"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_rounded, size: 18),
                SizedBox(width: 8),
                Text("Hub Wise"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_rounded, size: 18),
                SizedBox(width: 8),
                Text("Transactions"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}