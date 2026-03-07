import 'package:flutter/material.dart';

class Responsive {
  static const double mobile = 600;
  static const double tablet = 1100;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) =>
      width(context) < mobile;

  static bool isTablet(BuildContext context) {
    final w = width(context);
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      width(context) >= tablet;

  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return desktop;
  }
}