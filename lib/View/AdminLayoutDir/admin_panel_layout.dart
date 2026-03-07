import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AdminLayoutDir/admin_side_pannel.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/notification_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Responsive.isMobile(context)
          ? AppBar(
              title: CustomText.semiBold("City Admin"),
              backgroundColor: ColorConst.bgColor,
              actions: [
                Container(
                  height: 44,
                  width: 44,
                  margin: EdgeInsets.symmetric(horizontal: Sizes.screenWidth*0.012),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorConst.borderColor),
                  ),
                  child: IconButton(
                      onPressed: (){
                        openRightDrawer(context, NotificationView());
                      },
                      icon: Icon(Icons.notifications_none,size: 20, )
                  ),
                ),
              ],
            )
          : null,
      drawer: Responsive.isMobile(context)
          ? const Drawer(
              backgroundColor: ColorConst.bgColor,
              child: AdminSidebar(),
            )
          : null,
      body: Consumer<AdminViewModel>(
        builder: (context, avm, child) {
          return Row(
            children: [
              if (!Responsive.isMobile(context)) AdminSidebar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: avm.currentScreen,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
