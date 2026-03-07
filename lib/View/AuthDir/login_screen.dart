import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/customTextfield.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {

  final emailController = TextEditingController(text: "city.admin@lucknow");
  final passwordController = TextEditingController();

  bool obscure = true;
  bool rememberMe = true;
  bool isLoading = false;

  void _login() async {

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.adminSliderLayoutScreen,
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // ✅ Breakpoints
    bool isMobile = width < 600;
    bool isTablet = width >= 600 && width < 1100;

    // ✅ Responsive card width
    double cardWidth;
    if (isMobile) {
      cardWidth = width * 0.92;
    } else if (isTablet) {
      cardWidth = width * 0.55;
    } else {
      cardWidth = width * 0.32;
    }

    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 24,
          ),
          child: Container(
            width: cardWidth,
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              color: ColorConst.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 25,
                  color: Colors.black12,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: isMobile ? 56 : 64,
                  width: isMobile ? 56 : 64,
                  decoration: BoxDecoration(
                    color: ColorConst.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.apartment,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                CustomWidgets.verticalSpace(0.03),

                CustomText.semiBold(
                  "City Admin Login",
                  fontSize: isMobile ? 20 : 22,
                ),

                CustomWidgets.verticalSpace(0.008),

                CustomText.medium(
                  "Lucknow Control Panel",
                  fontSize: 13,
                  color: ColorConst.textGrey1,
                ),

                CustomWidgets.verticalSpace(0.025),

                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText.medium("Email address"),
                ),

                CustomWidgets.verticalSpace(0.012),

                CustomTextField(
                  controller: emailController,
                  prefixIcon: const Icon(Icons.mail_outline),
                  borderSide: BorderSide.none,
                ),

                CustomWidgets.verticalSpace(0.02),

                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText.medium("Password"),
                ),

                CustomWidgets.verticalSpace(0.012),

                CustomTextField(
                  controller: passwordController,
                  obscureText: obscure,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => obscure = !obscure),
                  ),
                  borderSide: BorderSide.none,
                  maxLines: 1,
                ),

                CustomWidgets.verticalSpace(0.015),

                // ✅ Remember me
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      activeColor: ColorConst.primaryGreen,
                      onChanged: (v) =>
                          setState(() => rememberMe = v ?? false),
                    ),
                    Expanded(
                      child: CustomText.medium(
                        "Remember me for 30 days",
                      ),
                    ),
                  ],
                ),

                CustomWidgets.verticalSpace(0.02),

                AppBtn(
                  height: isMobile ? 52 : height * 0.07,
                  title: "Sign in to Dashboard",
                  onTap: isLoading ? null : _login,
                  loading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}