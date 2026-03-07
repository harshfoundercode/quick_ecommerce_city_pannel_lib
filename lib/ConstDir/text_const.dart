import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/font_family_constant.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight fontWeight;
  final FontStyle? fontStyle;
  final double? fontSize;
  final double? height;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool showLineThrough;
  final bool showUnderline;
  final Color? underlineOrLineColor;
  final double? letterSpacing;
  final TextOverflow? overflow;
  final bool firstUpperCaseWidget;

  const CustomText._internal(
      this.text, {
        required this.fontWeight,
        this.color,
        this.fontSize,
        this.fontStyle,
        this.height,
        this.textAlign,
        this.maxLines,
        this.showLineThrough = false,
        this.showUnderline = false,
        this.underlineOrLineColor,
        this.letterSpacing,
        this.overflow,
        this.firstUpperCaseWidget = false,
      });

  // ================= REGULAR =================

  factory CustomText.regular(
      String text, {
        Color? color,
        double? fontSize,
        TextAlign? textAlign,
        int? maxLines,
        double? height,
        double? letterSpacing,
        TextOverflow? overflow,
        bool firstUpperCaseWidget = false,
        bool showUnderline = false,
        bool showLineThrough = false,
        Color? underlineOrLineColor,
      }) {
    return CustomText._internal(
      text,
      fontWeight: FontConst.regular,
      color: color,
      fontSize: fontSize,
      textAlign: textAlign,
      maxLines: maxLines,
      height: height,
      letterSpacing: letterSpacing,
      overflow: overflow,
      firstUpperCaseWidget: firstUpperCaseWidget,
      showUnderline: showUnderline,
      showLineThrough: showLineThrough,
      underlineOrLineColor: underlineOrLineColor,
    );
  }

  // ================= MEDIUM =================

  factory CustomText.medium(
      String text, {
        Color? color,
        double? fontSize,
        TextAlign? textAlign,
        int? maxLines,
        double? height,
        double? letterSpacing,
        TextOverflow? overflow,
        bool firstUpperCaseWidget = false,
        bool showUnderline = false,
        bool showLineThrough = false,
        Color? underlineOrLineColor,
      }) {
    return CustomText._internal(
      text,
      fontWeight: FontConst.medium,
      color: color,
      fontSize: fontSize,
      textAlign: textAlign,
      maxLines: maxLines,
      height: height,
      letterSpacing: letterSpacing,
      overflow: overflow,
      firstUpperCaseWidget: firstUpperCaseWidget,
      showUnderline: showUnderline,
      showLineThrough: showLineThrough,
      underlineOrLineColor: underlineOrLineColor,
    );
  }

  // ================= SEMIBOLD =================

  factory CustomText.semiBold(
      String text, {
        Color? color,
        double? fontSize,
        TextAlign? textAlign,
        int? maxLines,
        double? height,
        double? letterSpacing,
        TextOverflow? overflow,
        bool firstUpperCaseWidget = false,
        bool showUnderline = false,
        bool showLineThrough = false,
        Color? underlineOrLineColor,
      }) {
    return CustomText._internal(
      text,
      fontWeight: FontConst.semiBold,
      color: color,
      fontSize: fontSize,
      textAlign: textAlign,
      maxLines: maxLines,
      height: height,
      letterSpacing: letterSpacing,
      overflow: overflow,
      firstUpperCaseWidget: firstUpperCaseWidget,
      showUnderline: showUnderline,
      showLineThrough: showLineThrough,
      underlineOrLineColor: underlineOrLineColor,
    );
  }

  // ================= BOLD =================

  factory CustomText.bold(
      String text, {
        Color? color,
        double? fontSize,
        TextAlign? textAlign,
        int? maxLines,
        double? height,
        double? letterSpacing,
        TextOverflow? overflow,
        bool firstUpperCaseWidget = false,
        bool showUnderline = false,
        bool showLineThrough = false,
        Color? underlineOrLineColor,
      }) {
    return CustomText._internal(
      text,
      fontWeight: FontConst.bold,
      color: color,
      fontSize: fontSize,
      textAlign: textAlign,
      maxLines: maxLines,
      height: height,
      letterSpacing: letterSpacing,
      overflow: overflow,
      firstUpperCaseWidget: firstUpperCaseWidget,
      showUnderline: showUnderline,
      showLineThrough: showLineThrough,
      underlineOrLineColor: underlineOrLineColor,
    );
  }

  // ================= STYLE =================

  TextStyle _style() {
    return TextStyle(
      fontFamily: FontConst.family,
      fontWeight: fontWeight,
      color: color ?? ColorConst.black,
      fontSize: fontSize,
      height: height,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      decoration: showLineThrough
          ? TextDecoration.lineThrough
          : (showUnderline ? TextDecoration.underline : null),
      decorationColor: underlineOrLineColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      firstUpperCaseWidget ? text.toUpperCase() : text,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : overflow,
      textAlign: textAlign,
      style: _style(),
      softWrap: true,
      textScaler: TextScaler.noScaling,
    );
  }
}