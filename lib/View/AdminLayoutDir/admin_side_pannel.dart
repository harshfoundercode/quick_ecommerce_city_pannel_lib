// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';
//
//
// class AdminSidebar extends StatefulWidget {
//   const AdminSidebar({super.key});
//
//   @override
//   State<AdminSidebar> createState() => _AdminSidebarState();
// }
//
// class _AdminSidebarState extends State<AdminSidebar> with SingleTickerProviderStateMixin {
//   late AnimationController _hoverController;
//
//   @override
//   void initState() {
//     super.initState();
//     _hoverController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//   }
//
//   @override
//   void dispose() {
//     _hoverController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AdminViewModel>(
//       builder: (context, avm, child) {
//         return Container(
//           width: Sizes.screenWidth * 0.18,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha:0.03),
//                 blurRadius: 20,
//                 offset: const Offset(2, 0),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               _buildHeader(avm),
//               Expanded(
//                 child: _buildMenuList(avm),
//               ),
//               _buildLogoutButton(),
//               _buildFooter(),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildHeader(AdminViewModel avm) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: Sizes.screenWidth * 0.015,
//         vertical: Sizes.screenHeight * 0.025,
//       ),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey.shade200,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 48,
//             width: 48,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   ColorConst.primaryGreen,
//                   ColorConst.primaryGreen.withValues(alpha:0.8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: [
//                 BoxShadow(
//                   color: ColorConst.primaryGreen.withValues(alpha:0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.storefront_rounded,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "City Admin",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1E293B),
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: ColorConst.primaryGreen.withValues(alpha:0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     "Lucknow Control Panel",
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w500,
//                       color: ColorConst.primaryGreen,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMenuList(AdminViewModel avm) {
//     return ListView.builder(
//       padding: EdgeInsets.symmetric(
//         vertical: Sizes.screenHeight * 0.02,
//       ),
//       itemCount: avm.menuItems.length,
//       itemBuilder: (context, index) {
//         return _buildMenuItem(
//           index: index,
//           menuItem: avm.menuItems[index],
//           isSelected: avm.selectedIndex == index,
//           isExpanded: avm.expandedIndex == index,
//           avm: avm,
//         );
//       },
//     );
//   }
//
//   Widget _buildMenuItem({
//     required int index,
//     required MenuItem menuItem,
//     required bool isSelected,
//     required bool isExpanded,
//     required AdminViewModel avm,
//   }) {
//     return Column(
//       children: [
//         // Main Menu Item
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () => avm.onMenuItemTap(index),
//               borderRadius: BorderRadius.circular(14),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: Sizes.screenHeight * 0.014,
//                 ),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? ColorConst.primaryLightGreen.withValues(alpha:0.15)
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(14),
//                   border: isSelected
//                       ? Border.all(
//                     color: ColorConst.primaryGreen.withValues(alpha:0.2),
//                     width: 1,
//                   )
//                       : null,
//                 ),
//                 child: Row(
//                   children: [
//                     // Icon with container for better visual
//                     Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? ColorConst.primaryGreen.withValues(alpha:0.1)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         menuItem.icon,
//                         size: 20,
//                         color: isSelected
//                             ? ColorConst.primaryGreen
//                             : Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//
//                     // Title
//                     Expanded(
//                       child: Text(
//                         menuItem.title,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                           color: isSelected
//                               ? ColorConst.primaryGreen
//                               : Colors.grey.shade700,
//                           letterSpacing: -0.3,
//                         ),
//                       ),
//                     ),
//
//                     // Arrow indicator if has subitems
//                     if (menuItem.subItems.isNotEmpty)
//                       AnimatedRotation(
//                         duration: const Duration(milliseconds: 250),
//                         turns: isExpanded ? 0.5 : 0,
//                         child: Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           size: 20,
//                           color: isSelected
//                               ? ColorConst.primaryGreen
//                               : Colors.grey.shade500,
//                         ),
//                       ),
//
//                     // Active indicator
//                     if (!menuItem.subItems.isNotEmpty && isSelected)
//                       Container(
//                         width: 4,
//                         height: 20,
//                         decoration: BoxDecoration(
//                           color: ColorConst.primaryGreen,
//                           borderRadius: BorderRadius.circular(4),
//                           boxShadow: [
//                             BoxShadow(
//                               color: ColorConst.primaryGreen.withValues(alpha:0.4),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         // Sub Menu Items
//         if (isExpanded && menuItem.subItems.isNotEmpty)
//           Container(
//             margin: const EdgeInsets.only(
//               left: 32,
//               right: 12,
//               top: 4,
//               bottom: 8,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.grey.shade200,
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               children: List.generate(menuItem.subItems.length, (i) {
//                 final subItem = menuItem.subItems[i];
//                 return _buildSubMenuItem(
//                   item: subItem,
//                   isLast: i == menuItem.subItems.length - 1,
//                   provider: avm,
//                 );
//               }),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildSubMenuItem({
//     required SubMenuItem item,
//     required bool isLast,
//     required AdminViewModel provider,
//   }) {
//     return InkWell(
//       onTap: () => provider.onSubItemTap(item),
//       borderRadius: BorderRadius.vertical(
//         top: isLast ? const Radius.circular(12) : Radius.zero,
//         bottom: isLast ? const Radius.circular(12) : Radius.zero,
//       ),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           border: isLast
//               ? null
//               : Border(
//             bottom: BorderSide(
//               color: Colors.grey.shade200,
//               width: 0.5,
//             ),
//           ),
//         ),
//         child: Row(
//           children: [
//             // Custom bullet point
//             Container(
//               width: 4,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade400,
//                 shape: BoxShape.circle,
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Title
//             Expanded(
//               child: Text(
//                 item.title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ),
//             // Subtle arrow
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 12,
//               color: Colors.grey.shade400,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLogoutButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _showClassyLogoutDialog(context),
//           borderRadius: BorderRadius.circular(16),
//           child: Ink(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//                 colors: [
//                   Colors.red.shade50,
//                   Colors.red.shade50.withValues(alpha:0.5),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: Colors.red.shade200,
//                 width: 1,
//               ),
//             ),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.logout_rounded,
//                     size: 18,
//                     color: Colors.red.shade700,
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     "Logout",
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.red.shade700,
//                       letterSpacing: -0.3,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFooter() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.grey.shade200,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Admin Panel",
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "v1.0.0",
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey.shade500,
//                 ),
//               ),
//             ],
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha:0.02),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Icon(
//               Icons.admin_panel_settings_rounded,
//               size: 16,
//               color: ColorConst.primaryGreen,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showClassyLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.black.withValues(alpha:0.5),
//       builder: (BuildContext context) {
//         return Dialog(
//           elevation: 24,
//           backgroundColor: Colors.transparent,
//           child: Container(
//             width: Sizes.screenWidth*0.24,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(28),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha:0.2),
//                   blurRadius: 32,
//                   offset: const Offset(0, 16),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: Sizes.screenWidth,
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.red.shade50,
//                         Colors.red.shade100,
//                       ],
//                     ),
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(28),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       TweenAnimationBuilder(
//                         tween: Tween<double>(begin: 0, end: 1),
//                         duration: const Duration(milliseconds: 400),
//                         curve: Curves.elasticOut,
//                         builder: (context, double value, child) {
//                           return Transform.scale(
//                             scale: value,
//                             child: Container(
//                               height: 70,
//                               width: 70,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.red.withValues(alpha:0.3),
//                                     blurRadius: 20,
//                                     offset: const Offset(0, 8),
//                                   ),
//                                 ],
//                               ),
//                               child: const Icon(
//                                 Icons.power_settings_new_rounded,
//                                 color: Colors.red,
//                                 size: 30,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                        SizedBox(height: 16),
//                        Text(
//                         "Exit Admin Panel?",
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1E293B),
//                           letterSpacing: -0.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Body
//                 Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     children: [
//                       const Text(
//                         "You're about to logout from the admin panel. Any unsaved changes will be lost.",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF64748B),
//                           height: 1.5,
//                         ),
//                       ),
//
//
//
//
//                       const SizedBox(height: 24),
//
//                       // Action Buttons
//                       Row(
//                         children: [
//                           // Cancel Button
//                           Expanded(
//                             child: TextButton(
//                               onPressed: () => Navigator.pop(context),
//                               style: TextButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(vertical: 16),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                   side: BorderSide(
//                                     color: Colors.grey.shade300,
//                                   ),
//                                 ),
//                               ),
//                               child: Text(
//                                 "Stay Signed In",
//                                 style: TextStyle(
//                                   color: Colors.grey.shade700,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(width: 12),
//
//                           // Logout Button
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 Navigator.pop(context); // Close dialog
//                                 _showLogoutProgress(context);
//                                 await _handleLogout(context);
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(vertical: 16),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 elevation: 0,
//                               ),
//                               child: const Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.logout_rounded, size: 18),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     "Logout",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSessionInfo(IconData icon, String label, String value) {
//     return Column(
//       children: [
//         Icon(icon, size: 18, color: Colors.grey.shade600),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey.shade500,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF1E293B),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showLogoutProgress(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.black.withValues(alpha:0.3),
//       builder: (BuildContext context) {
//         return const Dialog(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           child: Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
//               strokeWidth: 3,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _handleLogout(BuildContext context) async {
//     await context.read<AdminViewModel>().performLogout(context);
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     // Keeping the original method for backward compatibility
//     _showClassyLogoutDialog(context);
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';

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
    return Consumer<AdminViewModel>(
      builder: (context, avm, child) {
        /// 🔥 MOBILE → use as drawer content
        if (Responsive.isMobile(context)) {
          return SafeArea(child: _buildSidebarContent(avm));
        }

        /// 🔥 TABLET & DESKTOP → fixed sidebar
        return _buildSidebarContent(avm);
      },
    );
  }

  // ================= SIDEBAR MAIN =================

  Widget _buildSidebarContent(AdminViewModel avm) {
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
          _buildHeader(),
          Expanded(child: _buildMenuList(avm)),
          _buildLogoutButton(),
          _buildFooter(),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
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
      child: Row(
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