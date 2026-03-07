import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/revenue_view_model.dart';

class RevenueOverviewScreen extends StatefulWidget {
  final RevenueViewModel vm;
  final TabController tabController;
  const RevenueOverviewScreen({super.key, required this.vm, required this.tabController});

  @override
  State<RevenueOverviewScreen> createState() => _RevenueOverviewScreenState();
}

class _RevenueOverviewScreenState extends State<RevenueOverviewScreen> {

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: ColorConst.cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: ColorConst.borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        // Summary Cards
        _buildEnhancedSummaryCards(widget.vm),
        const SizedBox(height: 20),

        // Charts Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Chart
            Expanded(
              flex: 3,
              child: _buildEnhancedRevenueChart(widget.vm),
            ),
            const SizedBox(width: 20),

            // Distribution Chart
            Expanded(
              flex: 2,
              child: _buildDistributionChart(widget.vm),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Performance Metrics
        _buildPerformanceMetrics(widget.vm),
        const SizedBox(height: 20),

        // Top Hubs
        _buildTopHubs(widget.vm),
      ],
    );
  }
  Widget _buildEnhancedSummaryCards(RevenueViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Financial Overview",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedSummaryCard(
                  title: "Total Revenue",
                  value: vm.totalRevenue,
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF3B82F6),
                  trend: "+12.5%",
                  trendUp: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedSummaryCard(
                  title: "Today's Revenue",
                  value: vm.todayRevenue,
                  icon: Icons.today_rounded,
                  color: const Color(0xFF10B981),
                  trend: "+5.2%",
                  trendUp: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedSummaryCard(
                  title: "Weekly Revenue",
                  value: vm.weekRevenue,
                  icon: Icons.date_range_rounded,
                  color: const Color(0xFFF59E0B),
                  trend: "-2.1%",
                  trendUp: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedSummaryCard(
                  title: "Monthly Revenue",
                  value: vm.monthRevenue,
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFF8B5CF6),
                  trend: "+18.3%",
                  trendUp: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRevenueChart(RevenueViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Revenue Trend",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConst.primaryGreen.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Last 7 Days",
                  style: TextStyle(
                    fontSize: 11,
                    color: ColorConst.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value >= 0 && value < 7) {
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${value.toInt()}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: ColorConst.primaryGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: ColorConst.primaryGreen.withValues(alpha:0.1),
                    ),
                    spots: vm.weeklyTrend
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha:0.1),
            color.withValues(alpha:0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendUp ? Colors.green.withValues(alpha:0.1) : Colors.red.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 12,
                      color: trendUp ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10,
                        color: trendUp ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "₹${value.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(RevenueViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Revenue Distribution",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: 45,
                    title: '45%',
                    color: const Color(0xFF3B82F6),
                    radius: 25,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 30,
                    title: '30%',
                    color: const Color(0xFF10B981),
                    radius: 25,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 15,
                    title: '15%',
                    color: const Color(0xFFF59E0B),
                    radius: 25,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 10,
                    title: '10%',
                    color: const Color(0xFF8B5CF6),
                    radius: 25,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegendItem("Gomti Nagar Hub", const Color(0xFF3B82F6), "45%"),
          _buildLegendItem("Indira Nagar Hub", const Color(0xFF10B981), "30%"),
          _buildLegendItem("Alambagh Hub", const Color(0xFFF59E0B), "15%"),
          _buildLegendItem("Charbagh Hub", const Color(0xFF8B5CF6), "10%"),
        ],
      ),
    );
  }
  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            percentage,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPerformanceMetrics(RevenueViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Performance Metrics",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: "Average Order Value",
                  value: "₹1,250",
                  icon: Icons.shopping_cart_rounded,
                  change: "+8.2%",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  label: "Total Orders",
                  value: "1,245",
                  icon: Icons.receipt_rounded,
                  change: "+15.3%",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  label: "Conversion Rate",
                  value: "68%",
                  icon: Icons.trending_up_rounded,
                  change: "+5.1%",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  label: "Customer Satisfaction",
                  value: "4.8 ★",
                  icon: Icons.star_rounded,
                  change: "+0.3",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: ColorConst.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              change,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTopHubs(RevenueViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Top Performing Hubs",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.tabController.animateTo(1);
                },
                child: const Text("View All"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) {
            final hubs = [
              {"name": "Gomti Nagar Hub", "revenue": 45000, "orders": 320, "growth": "+12%"},
              {"name": "Indira Nagar Hub", "revenue": 38000, "orders": 280, "growth": "+8%"},
              {"name": "Alambagh Hub", "revenue": 25000, "orders": 190, "growth": "+5%"},
            ];
            final hub = hubs[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorConst.primaryGreen.withValues(alpha:0.1),
                          ColorConst.primaryGreen.withValues(alpha:0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "H${index + 1}",
                        style: TextStyle(
                          color: ColorConst.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hub["name"]!.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${hub["orders"]} orders",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${hub["revenue"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ColorConst.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hub["growth"]!.toString(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

}
