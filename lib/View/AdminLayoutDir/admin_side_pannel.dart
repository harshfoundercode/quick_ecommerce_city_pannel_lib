import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_){
      final profileData = Provider.of<ProfileViewModel>(context,listen: false);
      profileData.getProfileDataApi(context);
    });
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
    return Consumer2<AdminViewModel,ProfileViewModel>(
      builder: (context, avm,pvm, child) {
        /// 🔥 MOBILE → use as drawer content
        if (Responsive.isMobile(context)) {
          return SafeArea(child: _buildSidebarContent(avm,pvm));
        }

        /// 🔥 TABLET & DESKTOP → fixed sidebar
        return _buildSidebarContent(avm,pvm);
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
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
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
                      ColorConst.primaryGreen.withValues(alpha:0.8),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Sizes.screenHeight*0.012,),
          CustomText.bold(pvm.profileData?.data?.name ?? "",color: Colors.black,),
          CustomText.medium(pvm.profileData?.data?.phone ?? "",color: Colors.black,)
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
            onTap: () => avm.onMenuItemTap(index),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorConst.primaryLightGreen.withValues(alpha:0.15)
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
            margin: const EdgeInsets.only(
              left: 32,
              right: 12,
              bottom: 8,
            ),
            child: Column(
              children: menuItem.subItems
                  .map((e) => _buildSubMenuItem(e, avm))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubMenuItem(SubMenuItem item, AdminViewModel avm) {
    return InkWell(
      onTap: () => avm.onSubItemTap(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOGOUT =================

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
      builder: (_) {
        return Dialog(
          child: Container(
            width: Responsive.value(
              context: context,
              mobile: Responsive.width(context) * 0.9,
              tablet: Responsive.width(context) * 0.5,
              desktop: Responsive.width(context) * 0.24,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Exit Admin Panel?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "You're about to logout.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await context
                              .read<AdminViewModel>()
                              .performLogout(context);
                        },
                        child: const Text("Logout"),
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