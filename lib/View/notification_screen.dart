import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/notification_veiw_model.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<NotificationViewModel>(context, listen: false).getNotificationDataApi(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: SizedBox(
        width: mobileSize?Sizes.screenWidth:Sizes.screenWidth,
        child: Consumer<NotificationViewModel>(
          builder: (context, nvm, child) {

            // 🔹 Loading
            if (nvm.notificationModel == null) {
              return const Center(child: CircularProgressIndicator(
                color: ColorConst.primaryGreen,
                strokeWidth: 2,
              ));
            }

            final data = nvm.notificationModel!.data;
            final notifications = data?.notifications;

            // 🔹 No Data
            if (notifications == null ||
                (notifications.today!.isEmpty &&
                    notifications.yesterday!.isEmpty &&
                    notifications.earlier!.isEmpty)) {
              return Padding(
                padding:  EdgeInsets.symmetric(vertical: Sizes.screenHeight*0.4),
                child: Center(child: CustomText.bold("No Notifications")),
              );
            }

            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              children: [
                if (notifications.today!.isNotEmpty)
                  _buildSection("Today", notifications.today!),
                if (notifications.yesterday!.isNotEmpty)
                  _buildSection("Yesterday", notifications.yesterday!),
                if (notifications.earlier!.isNotEmpty)
                  _buildSection("Earlier", notifications.earlier!),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorConst.primaryGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Check your notification here',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
      actions: [
        Consumer<NotificationViewModel>(
          builder: (ctx, vm, _) => IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => vm.getNotificationDataApi(ctx),
            tooltip: 'Refresh',
          ),
        ),
        const SizedBox(width: 4),

      ],
    );
  }


  Widget _buildSection(String title, List list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        ...list.map((item) => _notificationTile(item)),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _notificationTile(item) {
    final isRead = item.isRead == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey.shade100 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey.shade300 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔵 Indicator
          Container(
            height: 10,
            width: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: isRead ? Colors.grey : Colors.blue,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 10),

          // 🔹 Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  item.title ?? "",
                  style: TextStyle(
                    fontWeight:
                    isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  item.message ?? "",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _formatDate(item.datetime),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return "";
    final dt = DateTime.tryParse(dateTime);
    if (dt == null) return "";

    return "${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute}";
  }
}
