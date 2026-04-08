import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';
import '../widgets/app_header.dart';
import '../widgets/category_tree.dart';
import '../widgets/product_list_panel.dart';

class StockOverviewScreen extends StatelessWidget {
  const StockOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(title: 'Stock Overview', subtitle: 'Manage your inventory'),
        Expanded(
          child: Row(
            children: [
              // LEFT PANEL - Category Tree
              Container(
                width: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F22),
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.07),
                      width: 1,
                    ),
                  ),
                ),
                child: const CategoryTree(),
              ),
              // RIGHT PANEL - Product List
              const Expanded(child: ProductListPanel()),
            ],
          ),
        ),
      ],
    );
  }
}
