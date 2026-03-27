import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/customTextfield.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/email_validation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/auth_view_model.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {

  bool _isPasswordVisible = false;

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

    return Consumer<LoginViewModel>(
      builder: (context,lvm,child) {
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
                      controller: lvm.emailController,
                      prefixIcon: const Icon(Icons.mail_outline),
                      borderSide: BorderSide.none,
                      hintText: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [
                        SingleAtEmailInputFormatter(),
                      ],
                    ),

                    CustomWidgets.verticalSpace(0.02),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText.medium("Password"),
                    ),

                    CustomWidgets.verticalSpace(0.012),

                    CustomTextField(
                      controller: lvm.passwordController,
                      obscureText: !_isPasswordVisible,
                      prefixIcon: const Icon(Icons.lock_outline),
                      borderSide: BorderSide.none,
                      maxLines: 1,
                      hintText: "Enter your password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    CustomWidgets.verticalSpace(0.02),

                    AppBtn(
                      height: isMobile ? 52 : height * 0.07,
                      title: "Sign in to Dashboard",
                      onTap: (){
                        if (lvm.emailController.text.isEmpty) {
                          CustomSnackBar.show(context,message: "Please enter your email", type: SnackBarType.error);
                        } else if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|co)$'
                        ).hasMatch(lvm.emailController.text.trim())) {
                          CustomSnackBar.show(context,message:
                            "Please enter a valid email address",
                            type: SnackBarType.error,
                          );
                        } else if(lvm.passwordController.text.isEmpty){
                          CustomSnackBar.show(context,message: "Please enter your password", type: SnackBarType.error);
                        } else {
                          lvm.loginApi(context);
                        }

                      },
                      loading: lvm.loginLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}