import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/my_profile_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/profile_view_model.dart';

class AdminSidebar extends StatefulWidget {
  const AdminSidebar({super.key});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AdminViewModel, ProfileViewModel>(
      builder: (context, avm, pvm, child) {
        /// 🔥 MOBILE → use as drawer content
        if (Responsive.isMobile(context)) {
          return SafeArea(child: _buildSidebarContent(avm, pvm));
        }

        /// 🔥 TABLET & DESKTOP → fixed sidebar
        return _buildSidebarContent(avm, pvm);
      },
    );
  }

  // ================= SIDEBAR MAIN =================

  Widget _buildSidebarContent(AdminViewModel avm, ProfileViewModel pvm) {
    return Container(
      width: Responsive.value(
        context: context,
        mobile: Responsive.width(context),
        tablet: Responsive.width(context) * 0.28,
        desktop: Responsive.width(context) * 0.18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(pvm),
          Expanded(child: _buildMenuList(avm)),
          _buildLogoutButton(),
          _buildFooter(),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(ProfileViewModel pvm) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(
          context: context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
        vertical: Responsive.value(
          context: context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorConst.primaryGreen,
                      ColorConst.primaryGreen.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "City Admin",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: Sizes.screenHeight * 0.012),
          CustomText.bold(
            pvm.profileData?.data?.name ?? "",
            color: Colors.black,
          ),
          CustomText.medium(
            pvm.profileData?.data?.phone ?? "",
            color: Colors.black,
          ),
          InkWell(
            onTap: () {
              openRightDrawer(context, ProfileScreen());
            },
            child: Text(
              "View Profile",
              style: TextStyle(color: ColorConst.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU LIST =================

  Widget _buildMenuList(AdminViewModel avm) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: avm.menuItems.length,
      itemBuilder: (context, index) {
        return _buildMenuItem(
          index: index,
          menuItem: avm.menuItems[index],
          isSelected: avm.selectedIndex == index,
          isExpanded: avm.expandedIndex == index,
          avm: avm,
        );
      },
    );
  }

  Widget _buildMenuItem({
    required int index,
    required MenuItem menuItem,
    required bool isSelected,
    required bool isExpanded,
    required AdminViewModel avm,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: InkWell(
            onTap: () {
              avm.onMenuItemTap(index);
              // if (Responsive.isMobile(context)) {
              //   Navigator.pop(context);
              // }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorConst.primaryLightGreen.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    menuItem.icon,
                    size: 20,
                    color: isSelected
                        ? ColorConst.primaryGreen
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      menuItem.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? ColorConst.primaryGreen
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  if (menuItem.subItems.isNotEmpty)
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 250),
                      turns: isExpanded ? 0.5 : 0,
                      child: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                ],
              ),
            ),
          ),
        ),

        /// Sub menu
        if (isExpanded && menuItem.subItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 32, right: 12, bottom: 8),
            child: Column(
              children: menuItem.subItems
                  .map((e) => _buildSubMenuItem(e, avm))
                  .toList(),
            ),
          ),
      ],
    );
  }

  // ================= LOGOUT =================

  Widget _buildSubMenuItem(SubMenuItem item, AdminViewModel avm) {
    bool isSelected = avm.selectedSubMenu == item;

    return InkWell(
      onTap: () {
        avm.onSubItemTap(item);

        if (Responsive.isMobile(context)) {
          Future.delayed(const Duration(milliseconds: 150), () {
            Navigator.pop(context);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConst.primaryLightGreen.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),

          /// 🔥 LEFT BORDER (MAIN HIGHLIGHT)
          border: Border(
            left: BorderSide(
              color: isSelected ? ColorConst.primaryGreen : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorConst.primaryGreen
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? ColorConst.primaryGreen
                      : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: () => _showClassyLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded),
        label: const Text("Logout"),
      ),
    );
  }

  // ================= FOOTER =================

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        "Admin Panel v1.0.0",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  // ================= LOGOUT DIALOG =================

  void _showClassyLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: Responsive.value(
              context: context,
              mobile: Responsive.width(context) * 0.9,
              tablet: Responsive.width(context) * 0.5,
              desktop: Responsive.width(context) * 0.26,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔴 Icon container (premium touch)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 18),

                /// Title
                const Text(
                  "Logout Confirmation",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 8),

                /// Subtitle
                const Text(
                  "Are you sure you want to exit the admin panel?\nYou will need to login again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                /// Buttons
                Row(
                  children: [
                    /// Cancel
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Logout
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);

                          final adminVm =
                          Provider.of<AdminViewModel>(context, listen: false);

                          await adminVm.performLogout(context);
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
