import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/notification_veiw_model.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<NotificationViewModel>(context);

    return Material(
      color: Colors.white,
      child: SizedBox(
        width: Sizes.screenWidth*0.32,
        child: Column(
          children: [
            SizedBox(height: Sizes.screenHeight*0.024),
            _header(vm),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Expanded(child: _notificationList(vm)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(NotificationViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AppBackBtn(color: Colors.black,),
        SizedBox(width: Sizes.screenWidth*0.01,),
        Text("Notifications",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _notificationList(NotificationViewModel vm) {
    final items = [
      if (vm.todayList.isNotEmpty) "TODAY",
      ...vm.todayList,
      if (vm.yesterdayList.isNotEmpty) "YESTERDAY",
      ...vm.yesterdayList,
    ];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is String) {
          return _sectionTitle(item);
        }

        return _notificationTile(item as NotificationItem);
      },
    );
  }

  Widget _notificationTile(NotificationItem item) {
    Color iconColor;
    IconData icon;

    switch (item.type) {
      case NotificationType.finance:
        icon = Icons.error_outline;
        iconColor = Colors.red;
        break;
      case NotificationType.onboarding:
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.trending_up;
        iconColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withValues(alpha: .1),
            child: Icon(icon, color: iconColor,size: 18,),
          ),
           SizedBox(width: Sizes.screenWidth*0.012),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                const SizedBox(height: 4),
                Text(item.message,
                    style: const TextStyle(color: Colors.grey,fontSize: 12)),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Text(item.time,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}