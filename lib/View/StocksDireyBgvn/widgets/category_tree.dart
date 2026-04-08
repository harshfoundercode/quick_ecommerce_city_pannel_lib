import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';

class CategoryTree extends StatefulWidget {
  const CategoryTree({super.key});

  @override
  State<CategoryTree> createState() => _CategoryTreeState();
}

class _CategoryTreeState extends State<CategoryTree> {
  final Set<String> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.category_outlined, color: Color(0xFF3D5AFE), size: 16),
              const SizedBox(width: 8),
              const Text('Categories',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const Spacer(),
              if (provider.selectedCategoryId != null)
                GestureDetector(
                  onTap: () => provider.selectCategory(null),
                  child: const Icon(Icons.close, color: Colors.white38, size: 14),
                ),
            ],
          ),
        ),
        // All option
        _allCategoriesItem(provider),
        const SizedBox(height: 4),
        // Category list
        Expanded(
          child: ListView(
            children: provider.categories
                .map((cat) => _buildCategoryItem(cat, provider))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _allCategoriesItem(StockProvider provider) {
    final isSelected = provider.selectedCategoryId == null;
    return GestureDetector(
      onTap: () => provider.selectCategory(null),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3D5AFE).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.all_inclusive,
                color: isSelected ? const Color(0xFF3D5AFE) : Colors.white38, size: 18),
            const SizedBox(width: 10),
            Text('All Products',
                style: TextStyle(
                    color: isSelected ? const Color(0xFF3D5AFE) : Colors.white54,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Category cat, StockProvider provider) {
    final isExpanded = _expandedCategories.contains(cat.id);
    final isSelected = provider.selectedCategoryId == cat.id &&
        provider.selectedSubCategoryId == null;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCategories.remove(cat.id);
              } else {
                _expandedCategories.add(cat.id);
              }
            });
            provider.selectCategory(cat.id);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3D5AFE).withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(cat.icon,
                    color: isSelected ? const Color(0xFF3D5AFE) : Colors.white54, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(cat.name,
                      style: TextStyle(
                          color: isSelected ? const Color(0xFF3D5AFE) : Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white38,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        // Subcategories
        if (isExpanded)
          ...cat.subCategories.map((sub) => _buildSubCategoryItem(sub, provider)),
      ],
    );
  }

  Widget _buildSubCategoryItem(SubCategory sub, StockProvider provider) {
    final isSelected = provider.selectedSubCategoryId == sub.id;

    return GestureDetector(
      onTap: () {
        provider.selectCategory(sub.categoryId);
        provider.selectSubCategory(sub.id);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 30, right: 10, top: 2, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3D5AFE).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF3D5AFE).withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3D5AFE) : Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                sub.name,
                style: TextStyle(
                    color: isSelected ? const Color(0xFF3D5AFE) : Colors.white38,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
