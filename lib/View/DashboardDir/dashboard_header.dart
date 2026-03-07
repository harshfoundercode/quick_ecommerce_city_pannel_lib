import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/notification_screen.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConst.white,
      width: Sizes.screenWidth,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.screenWidth * 0.012,
        vertical: Sizes.screenHeight * 0.02,
      ),
      child: Container(
        height: 44,
        width: 44,
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
    );
  }
}
