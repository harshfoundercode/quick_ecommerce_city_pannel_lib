import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';


class AppBtn extends StatefulWidget {
  final String? title;
  final Color? titleColor;
  final Color? color;
  final Function()? onTap;
  final double? width;
  final double? height;
  final double? fontSize;
  final bool loading;
  final Gradient? gradient;
  final bool hideBorder;
  final Widget? child;
  final FontWeight? fontWeight;
  final BoxBorder? border;
  final double borderRadius;

  const AppBtn({
    super.key,
    this.title,
    this.titleColor,
    this.color,
    this.onTap,
    this.width,
    this.height,
    this.fontSize,
    this.loading = false,
    this.gradient,
    this.hideBorder = false,
    this.child,
    this.fontWeight,
    this.border,
    this.borderRadius = 1,
  });

  @override
  State<AppBtn> createState() => _AppBtnState();
}

class _AppBtnState extends State<AppBtn> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(microseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1, end: 0.3).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.loading ?null: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.loading == false
                ? Container(
              height: widget.height ?? 56,
              width: widget.width ?? Sizes.screenWidth,
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                color: widget.color ?? ColorConst.primaryGreen,
                border: widget.border,
                borderRadius: BorderRadius.circular(widget.borderRadius),

              ),
              child: SizedBox(
                width:  widget.width ?? MediaQuery.of(context).size.width*0.75,
                child: Center(
                  child: widget.child ??
                      CustomText.semiBold(widget.title!,
                        color: widget.titleColor??ColorConst.white,
                        maxLines: 1,
                        fontSize: widget.fontSize ?? 16,
                      ),
                ),
              ),
            )
                : Center(
              child: Container(
                height: 45,
                width: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                color: ColorConst.primaryGreen,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                padding: const EdgeInsets.all(12),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



class AppBackBtn extends StatefulWidget {
  final Color? color;

  const AppBackBtn({super.key, this.color});

  @override
  State<AppBackBtn> createState() => _AppBackBtnState();
}

class _AppBackBtnState extends State<AppBackBtn> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.fromLTRB(15, 5, 5, 5),
      child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:  Icon(Icons.arrow_back,color: widget.color ?? ColorConst.white,)
        // Image.asset(Assets.iconsArrowBack)
      ),
    );
  }
}
