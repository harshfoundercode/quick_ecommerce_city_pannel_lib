import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/animated_bg.dart';
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
    // ✅ Breakpoints
    bool isMobile =  Sizes.screenWidth < 600;
    bool isTablet = Sizes.screenWidth >= 600 && Sizes.screenWidth < 1100;

    // ✅ Responsive card width
    double cardWidth;
    if (isMobile) {
      cardWidth = Sizes.screenWidth * 0.92;
    } else if (isTablet) {
      cardWidth = Sizes.screenWidth * 0.55;
    } else {
      cardWidth = Sizes.screenWidth * 0.32;
    }
    return Scaffold(
      body: Stack(
        children: [
          const PremiumBg(),

          Center(
            child: SingleChildScrollView(
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: ColorConst.primaryExtraLightGreen.withValues(alpha: 0.9), // readable
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorConst.primaryExtraLightGreen.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30,
                      color: Colors.black.withValues(alpha: 0.15),
                    )
                  ],
                ),
                child: Consumer<LoginViewModel>(
                  builder: (context,lvm,child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// 🔹 Logo
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: ColorConst.primaryGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset("Assets/app_logo.png",width: 55,
                              height: 55,
                              cacheWidth: 55,
                              cacheHeight: 55,),
                          ),
                        ),

                         SizedBox(height: Sizes.screenHeight*0.03),

                        /// 🔹 Title
                        Text(
                          "City Admin",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ColorConst.textBlack,
                          ),
                        ),

                        SizedBox(height: Sizes.screenHeight*0.01),

                        Text(
                          "Login to manage your inventory",
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorConst.textGrey1,
                          ),
                        ),

                         SizedBox(height: Sizes.screenHeight*0.032),

                        /// 🔹 Email
                        _inputField(
                          controller: lvm.emailController,
                          hint: "Email address",
                          icon: Icons.mail_outline,
                        ),

                        SizedBox(height: Sizes.screenHeight*0.032),

                        /// 🔹 Password
                        _inputField(
                          controller: lvm.passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isVisible: _isPasswordVisible,
                          onToggle: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        /// 🔹 Button
                        GestureDetector(
                          onTap: () {
                            if (lvm.emailController.text.isEmpty) {
                              CustomSnackBar.show(context,
                                  message: "Enter email",
                                  type: SnackBarType.error);
                            } else if (lvm.passwordController.text.isEmpty) {
                              CustomSnackBar.show(context,
                                  message: "Enter password",
                                  type: SnackBarType.error);
                            } else {
                              lvm.loginApi(context);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                             color: ColorConst.primaryGreen
                            ),
                            alignment: Alignment.center,
                            child: lvm.loginLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
    // return Consumer<LoginViewModel>(
    //   builder: (context,lvm,child) {
    //     return Scaffold(
    //       backgroundColor: ColorConst.bgColor,
    //       body: Center(
    //         child: SingleChildScrollView(
    //           padding: EdgeInsets.symmetric(
    //             horizontal: isMobile ? 16 : 24,
    //             vertical: 24,
    //           ),
    //           child: Container(
    //             width: cardWidth,
    //             padding: EdgeInsets.all(isMobile ? 20 : 28),
    //             decoration: BoxDecoration(
    //               color: ColorConst.white,
    //               borderRadius: BorderRadius.circular(16),
    //               boxShadow: const [
    //                 BoxShadow(
    //                   blurRadius: 25,
    //                   color: Colors.black12,
    //                 )
    //               ],
    //             ),
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 Container(
    //                   height: isMobile ? 56 : 64,
    //                   width: isMobile ? 56 : 64,
    //                   decoration: BoxDecoration(
    //                     color: ColorConst.primaryGreen,
    //                     borderRadius: BorderRadius.circular(12),
    //                   ),
    //                   child: Image.asset("Assets/app_logo.png")
    //                 ),
    //
    //                 CustomWidgets.verticalSpace(0.03),
    //
    //                 CustomText.semiBold(
    //                   "City Admin Login",
    //                   fontSize: isMobile ? 20 : 22,
    //                 ),
    //
    //                 CustomWidgets.verticalSpace(0.008),
    //
    //
    //                 CustomWidgets.verticalSpace(0.025),
    //
    //                 Align(
    //                   alignment: Alignment.centerLeft,
    //                   child: CustomText.medium("Email address"),
    //                 ),
    //
    //                 CustomWidgets.verticalSpace(0.012),
    //
    //                 CustomTextField(
    //                   controller: lvm.emailController,
    //                   prefixIcon: const Icon(Icons.mail_outline),
    //                   borderSide: BorderSide.none,
    //                   hintText: "Enter your email",
    //                   keyboardType: TextInputType.emailAddress,
    //                   inputFormatters: [
    //                     SingleAtEmailInputFormatter(),
    //                   ],
    //                 ),
    //
    //                 CustomWidgets.verticalSpace(0.02),
    //
    //                 Align(
    //                   alignment: Alignment.centerLeft,
    //                   child: CustomText.medium("Password"),
    //                 ),
    //
    //                 CustomWidgets.verticalSpace(0.012),
    //
    //                 CustomTextField(
    //                   controller: lvm.passwordController,
    //                   obscureText: !_isPasswordVisible,
    //                   prefixIcon: const Icon(Icons.lock_outline),
    //                   borderSide: BorderSide.none,
    //                   maxLines: 1,
    //                   hintText: "Enter your password",
    //                   suffixIcon: IconButton(
    //                     icon: Icon(
    //                       _isPasswordVisible
    //                           ? Icons.visibility
    //                           : Icons.visibility_off,
    //                     ),
    //                     onPressed: () {
    //                       setState(() {
    //                         _isPasswordVisible = !_isPasswordVisible;
    //                       });
    //                     },
    //                   ),
    //                 ),
    //
    //                 CustomWidgets.verticalSpace(0.02),
    //
    //                 AppBtn(
    //                   height: isMobile ? 52 : height * 0.07,
    //                   title: "Sign in to Dashboard",
    //                   onTap: (){
    //                     if (lvm.emailController.text.isEmpty) {
    //                       CustomSnackBar.show(context,message: "Please enter your email", type: SnackBarType.error);
    //                     } else if (!RegExp(
    //                         r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|co)$'
    //                     ).hasMatch(lvm.emailController.text.trim())) {
    //                       CustomSnackBar.show(context,message:
    //                         "Please enter a valid email address",
    //                         type: SnackBarType.error,
    //                       );
    //                     } else if(lvm.passwordController.text.isEmpty){
    //                       CustomSnackBar.show(context,message: "Please enter your password", type: SnackBarType.error);
    //                     } else {
    //                       lvm.loginApi(context);
    //                     }
    //
    //                   },
    //                   loading: lvm.loginLoading,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     );
    //   }
    // );
  }
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !isVisible : false,
      cursorColor: ColorConst.primaryGreen,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: ColorConst.containerGrey2,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: onToggle,
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}



