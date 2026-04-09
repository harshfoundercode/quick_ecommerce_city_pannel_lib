import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/providers/stock_provider_new.dart';
import '../widgets/app_header.dart';
import '../widgets/category_tree.dart';
import '../widgets/product_list_panel.dart';

class StockOverviewScreen extends StatefulWidget {
  const StockOverviewScreen({super.key});

  @override
  State<StockOverviewScreen> createState() => _StockOverviewScreenState();
}

class _StockOverviewScreenState extends State<StockOverviewScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stockProvider = Provider.of<StockProvider>(context,listen: false);
      stockProvider.fetchStockData(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    final _stockProvider = Provider.of<StockProvider>(context,listen: false);
    return Column(
      children: [
        AppHeader(
          title: 'Stock Overview',
          subtitle: 'Manage your inventory',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () => _stockProvider.refreshData(context),
              tooltip: 'Refresh',
            ),

          ],
        ),
        const _StatsBar(),
        Expanded(
          child: Consumer<StockProvider>(
            builder: (context, provider, child) {
              // Loading state
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Error state
              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: ColorConst.danger,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        style: TextStyle(
                          color: ColorConst.danger,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => provider.refreshData(context),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConst.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // No data state
              if (provider.mainCategories.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: ColorConst.textGrey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No stock data available',
                        style: TextStyle(
                          color: ColorConst.textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Main content
              return Row(
                children: [
                  // LEFT PANEL — Category tree
                  Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: ColorConst.white,
                      border: Border(
                        right: BorderSide(color: ColorConst.borderColor),
                      ),
                    ),
                    child: const CategoryTree(),
                  ),
                  // RIGHT PANEL — Product list
                  const Expanded(
                    child: ProductListPanel(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        // Don't show stats while loading or if error
        if (provider.isLoading || provider.error != null) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: ColorConst.white,
            border: Border(bottom: BorderSide(color: ColorConst.borderColor)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.category_outlined,
                  label: 'Main Categories',
                  value: '${provider.totalMainCategories}',
                  color: ColorConst.info,
                  bg: ColorConst.criticalBlueLight,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.folder_outlined,
                  label: 'Categories',
                  value: '${provider.totalCategories}',
                  color: ColorConst.info,
                  bg: ColorConst.criticalBlueLight,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.inventory_2_outlined,
                  label: 'Products',
                  value: '${provider.totalProducts}',
                  color: ColorConst.primaryGreen,
                  bg: ColorConst.greenPale,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.layers_outlined,
                  label: 'Total Stock',
                  value: '${provider.totalStock}',
                  color: ColorConst.inkMid,
                  bg: ColorConst.containerGrey,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.warning_amber_outlined,
                  label: 'Low Stock',
                  value: '${provider.lowStockCount}',
                  color: ColorConst.warning,
                  bg: ColorConst.honeyBg,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.remove_shopping_cart_outlined,
                  label: 'Out of Stock',
                  value: '${provider.outOfStockCount}',
                  color: ColorConst.danger,
                  bg: ColorConst.dangerBg,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}