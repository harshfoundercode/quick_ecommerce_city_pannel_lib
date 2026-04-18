import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/main_catsubcat_all_data_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/providers/stock_provider_new.dart';

class CategoryTree extends StatefulWidget {
  const CategoryTree({super.key});

  @override
  State<CategoryTree> createState() => _CategoryTreeState();
}

class _CategoryTreeState extends State<CategoryTree> {
  final Set<int> _expandedMainCategories = {};
  final Set<int> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Row(
            children: [
              const Icon(
                Icons.category_outlined,
                color: ColorConst.primaryGreen,
                size: 15,
              ),
              const SizedBox(width: 6),
              const Text(
                'Categories',
                style: TextStyle(
                  color: ColorConst.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Clear selection button
              if (provider.selectedMainCategoryIndex != null)
                GestureDetector(
                  onTap: () => provider.resetSelection(),
                  child: const Icon(
                    Icons.close,
                    color: ColorConst.textGrey,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),

        // All Products item
        _buildAllProductsItem(provider),

        const SizedBox(height: 4),

        // Main Categories List
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.mainCategories.isEmpty
              ? const Center(
            child: Text(
              'No categories found',
              style: TextStyle(color: ColorConst.textGrey),
            ),
          )
              : ListView.builder(
            itemCount: provider.mainCategories.length,
            itemBuilder: (context, index) {
              return _buildMainCategoryItem(
                provider.mainCategories[index],
                index,
                provider,
              );
            },
          ),
        ),
      ],
    );
  }

  // All Products Item
  Widget _buildAllProductsItem(StockProvider provider) {
    final isSelected = provider.selectedMainCategoryIndex == null &&
        provider.selectedCategoryIndex == null &&
        provider.selectedSubCategoryIndex == null;

    return _buildTile(
      icon: Icons.inventory_2_outlined,
      label: 'All Products',
      selected: isSelected,
      onTap: () => provider.resetSelection(),
      indent: 0,
      showIcon: true,
      badge: provider.totalProducts.toString(),
    );
  }

  // Main Category Item
  Widget _buildMainCategoryItem(
      CityStocksFullData mainCat,
      int index,
      StockProvider provider,
      ) {
    final isExpanded = _expandedMainCategories.contains(index);
    final isSelected = provider.selectedMainCategoryIndex == index &&
        provider.selectedCategoryIndex == null;

    return Column(
      children: [
        _buildTile(
          imageUrl: mainCat.mainCategoryImg?.toString(),
          label: mainCat.mainCategoryName?.toString() ?? 'Unnamed',
          selected: isSelected,
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedMainCategories.remove(index);
              } else {
                _expandedMainCategories.add(index);
              }
            });
            provider.selectMainCategory(index);
          },
          indent: 0,
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: ColorConst.textGrey,
            size: 16,
          ),
          badge: '${mainCat.categories?.length ?? 0}',
        ),

        // Categories under this Main Category
        if (isExpanded && mainCat.categories != null)
          ...mainCat.categories!.asMap().entries.map((entry) {
            final catIndex = entry.key;
            final category = entry.value;
            return _buildCategoryItem(
              category,
              catIndex,
              index,
              provider,
            );
          }),
      ],
    );
  }

  // Category Item
  Widget _buildCategoryItem(
      Categories category,
      int catIndex,
      int mainCatIndex,
      StockProvider provider,
      ) {
    final isExpanded = _expandedCategories.contains(catIndex);
    final isSelected = provider.selectedMainCategoryIndex == mainCatIndex &&
        provider.selectedCategoryIndex == catIndex &&
        provider.selectedSubCategoryIndex == null;

    return Column(
      children: [
        _buildTile(
          imageUrl: category.categoryImg?.toString(),
          label: category.categoryName?.toString() ?? 'Unnamed',
          selected: isSelected,
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCategories.remove(catIndex);
              } else {
                _expandedCategories.add(catIndex);
              }
            });
            provider.selectCategory(catIndex);
          },
          indent: 20,
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: ColorConst.textGrey,
            size: 14,
          ),
          badge: '${category.subcategories?.length ?? 0}',
        ),

        // Subcategories under this Category
        if (isExpanded && category.subcategories != null)
          ...category.subcategories!.asMap().entries.map((entry) {
            final subCatIndex = entry.key;
            final subCategory = entry.value;
            return _buildSubCategoryItem(
              subCategory,
              subCatIndex,
              mainCatIndex,
              catIndex,
              provider,
            );
          }),
      ],
    );
  }

  // SubCategory Item
  Widget _buildSubCategoryItem(
      Subcategories subCategory,
      int subCatIndex,
      int mainCatIndex,
      int catIndex,
      StockProvider provider,
      ) {
    final isSelected = provider.selectedMainCategoryIndex == mainCatIndex &&
        provider.selectedCategoryIndex == catIndex &&
        provider.selectedSubCategoryIndex == subCatIndex;

    return _buildTile(
      imageUrl: subCategory.subcategoryImg?.toString(),
      label: subCategory.subcategoryName?.toString() ?? 'Unnamed',
      selected: isSelected,
      onTap: () {
        provider.selectMainCategory(mainCatIndex);
        provider.selectCategory(catIndex);
        provider.selectSubCategory(subCatIndex);
      },
      indent: 40,
      showDot: true,
      badge: '${subCategory.products?.length ?? 0}',
    );
  }

  // Reusable Tile Widget
  Widget _buildTile({
    String? imageUrl,
    IconData? icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required double indent,
    Widget? trailing,
    dynamic badge,
    bool showIcon = false,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          left: indent + 8,
          right: 8,
          top: 2,
          bottom: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? ColorConst.greenPale : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: ColorConst.stroke) : null,
        ),
        child: Row(
          children: [
            // Leading icon/image
            if (showIcon && icon != null) ...[
              Icon(
                icon,
                color: selected ? ColorConst.primaryGreen : ColorConst.textGrey,
                size: 18,
              ),
              const SizedBox(width: 8),
            ] else if (imageUrl != null && imageUrl.isNotEmpty) ...[
              Image.network(
                imageUrl,
                width: 20,
                height: 20,
                fit: BoxFit.cover,
                errorBuilder: (_, ii, iii) => Icon(
                  Icons.category,
                  color: selected ? ColorConst.primaryGreen : ColorConst.textGrey,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
            ] else if (showDot) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: selected ? ColorConst.primaryGreen : ColorConst.inkLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ] else ...[
              const SizedBox(width: 8),
            ],

            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? ColorConst.primaryGreen : ColorConst.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Badge (count)
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? ColorConst.primaryGreen.withValues(alpha:0.2) : ColorConst.inkLight.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: selected ? ColorConst.primaryGreen : ColorConst.textGrey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            ?trailing,
          ],
        ),
      ),
    );
  }
}