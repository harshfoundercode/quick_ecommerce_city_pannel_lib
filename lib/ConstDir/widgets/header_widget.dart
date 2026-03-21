import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';

class CustomWidgets {
  CustomWidgets._();

  static Widget hubHeader({
    String title = "Hub Management",
    String subtitle = "Manage and monitor all delivery hubs across the city",
    double titleSize = 24,
    double subtitleSize = 14,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.bold(
          title,
          fontSize: titleSize,
        ),
        SizedBox(height: Sizes.screenHeight * 0.01),
        CustomText.medium(
          subtitle,
          color: ColorConst.textGrey,
          fontSize: subtitleSize,
        ),
      ],
    );
  }

  static Widget pageHeader({
    required String title,
    String? subtitle,
    double titleSize = 24,
    double subtitleSize = 14,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.bold(
          title,
          fontSize: titleSize,
        ),
        if (subtitle != null) ...[
          SizedBox(height: Sizes.screenHeight * 0.01),
          CustomText.medium(
            subtitle,
            color: ColorConst.textGrey,
            fontSize: subtitleSize,
          ),
        ],
      ],
    );
  }

  // ==================== BUTTON WIDGETS ====================

  static Widget addButton({
    required VoidCallback onPressed,
    String label = "New Hub",
    Color backgroundColor = ColorConst.primaryGreen,
    Color textColor = Colors.white,
    double horizontalPadding = 0.01,
    double verticalPadding = 0.02,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Sizes.screenWidth * horizontalPadding,
          vertical: Sizes.screenHeight * verticalPadding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: Sizes.screenWidth * 0.01),
            CustomText.bold(
              label,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }

  static Widget ghostButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color borderColor = ColorConst.borderColor,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    double horizontalPadding = 14,
    double verticalPadding = 10,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            SizedBox(width: Sizes.screenWidth * 0.005),
            CustomText.medium(text, color: textColor),
          ],
        ),
      ),
    );
  }

  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = ColorConst.containerGrey,
    double size = 36,
    double iconSize = 18,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: iconSize),
      ),
    );
  }

  // ==================== STATS CARD WIDGETS ====================

  // static Widget statCard({
  //   required String title,
  //   required String value,
  //   required IconData icon,
  //   Color iconBgColor = ColorConst.primaryExtraLightGreen,
  //   Color iconColor = ColorConst.primaryGreen,
  //   Color borderColor = ColorConst.borderColor,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(18),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: borderColor),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           height: 42,
  //           width: 42,
  //           decoration: BoxDecoration(
  //             color: iconBgColor,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: Icon(icon, color: iconColor),
  //         ),
  //         SizedBox(width: Sizes.screenWidth * 0.012),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             CustomText.bold(title, fontSize: 16),
  //             CustomText.medium(
  //               value,
  //               fontSize: 20,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  static Widget statsRow({
    required List<Map<String, dynamic>> stats,
    required bool isMobile,
    double spacing = 12,
  }) {
    if (isMobile) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: stats.map((stat) {
          return SizedBox(
            width: (Sizes.screenWidth - (spacing * 4)) / 2,
            child: statCard(
              title: stat['title'] as String,
              value: stat['value'] as String,
              icon: stat['icon'] as IconData,

            ),
          );
        }).toList(),
      );
    }

    /// 🖥 Desktop → single row
    return Row(
      children: stats.asMap().entries.map((entry) {
        final isLast = entry.key == stats.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : spacing),
            child: statCard(
              title: entry.value['title']?.toString() ?? '',
              value: entry.value['value']?.toString() ?? '',
              icon: entry.value['icon'] as IconData,
            ),
          ),
        );
      }).toList(),
    );
  }
  static Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    Color iconBgColor = ColorConst.primaryExtraLightGreen,
    Color iconColor = ColorConst.primaryGreen,
    Color borderColor = ColorConst.borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),

          /// Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText.bold(
                  title,
                  fontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                CustomText.medium(
                  value,
                  fontSize: 20,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // static Widget statsRow({
  //   required List<Map<String, dynamic>> stats,
  //   double spacing = 12, required bool isMobile,
  // }) {
  //   return Row(
  //     children: stats.asMap().entries.map((entry) {
  //       final isLast = entry.key == stats.length - 1;
  //       return Expanded(
  //         child: Padding(
  //           padding: EdgeInsets.only(right: isLast ? 0 : spacing),
  //           child: statCard(
  //             title: entry.value['title'] as String,
  //             value: entry.value['value'] as String,
  //             icon: entry.value['icon'] as IconData,
  //           ),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  // ==================== SEARCH FIELD WIDGETS ====================

  static Widget searchField({
    required TextEditingController controller,
    String hintText = "Search...",
    double? width,
    double? height,
    Color borderColor = ColorConst.borderColor,
    Color textColor = ColorConst.textGrey,
    double fontSize = 14,
    IconData prefixIcon = Icons.search,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor, fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textColor, fontSize: fontSize),
          prefixIcon: Icon(prefixIcon, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ==================== TABLE WIDGETS ====================

  static Widget tableHeader({
    required List<String> headers,
    List<int> flexValues = const [],
    Color textColor = ColorConst.textGrey1,
    double fontSize = 14,
    double padding = 16,
  }) {
    final flexes = flexValues.isEmpty
        ? List.generate(headers.length, (_) => 1)
        : flexValues;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: headers.asMap().entries.map((entry) {
          return Expanded(
            flex: flexes[entry.key],
            child: CustomText.medium(
              entry.value,
              color: textColor,
              fontSize: fontSize,
            ),
          );
        }).toList(),
      ),
    );
  }

  static Widget statusBadge({
    required bool isActive,
    double? width,
    double? height,
    double fontSize = 12,
  }) {
    final color = isActive ? ColorConst.primaryGreen : ColorConst.textGrey;

    return Center(
      child: Container(
        width: width ?? Sizes.screenWidth * 0.06,
        height: height ?? Sizes.screenHeight * 0.04,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CustomText.semiBold(
            isActive ? "Active" : "Inactive",
            color: color,
            fontSize: fontSize,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }


  static Widget hubCell({
    required String name,
    required String location,
    double spacing = 0.012,
    double iconSize = 44,
  }) {
    return Row(
      children: [
        Container(
          height: iconSize,
          width: iconSize,
          decoration: BoxDecoration(
            color: ColorConst.primaryExtraLightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.hub_outlined,
            color: ColorConst.primaryGreen,
          ),
        ),
        SizedBox(width: Sizes.screenWidth * spacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText.semiBold(
              name,
              fontSize: 14,
            ),
            SizedBox(height: Sizes.screenHeight * 0.007),
            CustomText.medium(
              location,
              color: ColorConst.textGrey,
              fontSize: 12,
              maxLines: 2,
            ),
          ],
        ),
      ],
    );
  }

  static Widget managerCell({
    required String name,
    required String phone,
    double nameSize = 13,
    double phoneSize = 12,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.semiBold(
          name,
          fontSize: nameSize,
        ),
        SizedBox(height: Sizes.screenHeight * 0.007),
        CustomText.medium(
          phone,
          color: ColorConst.textGrey,
          fontSize: phoneSize,
          maxLines: 2,
        ),
      ],
    );
  }

  static Widget borderedContainer({
    required Widget child,
    Color backgroundColor = Colors.white,
    Color borderColor = ColorConst.borderColor,
    double borderRadius = 16,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  static Widget sectionDivider({
    double thickness = 1,
    Color color = ColorConst.borderColor,
    double? indent,
    double? endIndent,
  }) {
    return Divider(
      thickness: thickness,
      color: color,
      indent: indent,
      endIndent: endIndent,
    );
  }


  static Widget verticalSpace(double factor) {
    return SizedBox(height: Sizes.screenHeight * factor);
  }

  static Widget horizontalSpace(double factor) {
    return SizedBox(width: Sizes.screenWidth * factor);
  }

 static  Widget cardWrapper({required Widget child, double? height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConst.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget cardWrapperWithOptional({
    required String title,
    required Widget child,
    String? actionText,
    required void Function()? onTap
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText.bold(title, fontSize: 15),
              const Spacer(),
              if (actionText != null)
                InkWell(
                  onTap: onTap,
                  child: CustomText.medium(
                    actionText,
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  static Widget cardWrapperWithActionWidget({
    required String title,
    required Widget child,
    Widget? actionWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText.bold(title, fontSize: 15),
              const Spacer(),
              ?actionWidget,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
