import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';

class ActivityTracker extends StatefulWidget {
  final Widget child;

  const ActivityTracker({super.key, required this.child});

  @override
  State<ActivityTracker> createState() => _ActivityTrackerState();
}

class _ActivityTrackerState extends State<ActivityTracker> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startSessionChecker();
  }

  void startSessionChecker() {
    timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final userVM = Provider.of<UserViewModel>(context, listen: false);

      bool expired = await userVM.isSessionExpired();

      if (expired && mounted) {
        await userVM.clearToken();

        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.adminLoginScreen,
              (route) => false,
        );
      }
    });
  }

  void updateActivity() {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    userVM.updateLastActivity();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => updateActivity(),
      onPointerMove: (_) => updateActivity(),
      child: widget.child,
    );
  }
}