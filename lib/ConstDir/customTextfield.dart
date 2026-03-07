import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';


class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? icon;
  final Color? iconColor;
  final String? hintText;
  final bool? filled;
  final Color? fillColor;
  final Color? focusColor;
  final Color? hoverColor;
  final void Function(String)? onChanged;
  final double? height;
  final double? width;
  final double? hintSize;
  final double? fontSize;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? contentPadding;
  final double? cursorHeight;
  final Color? cursorColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BorderRadius? fieldRadius;
  final bool? enabled;
  final void Function()? onTap;
  final bool autofocus;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? margin;
  final Color? hintColor;
  final String? errorText;
  final BorderSide? borderSide;
  final Color? textColor;
  final FontWeight? fontWeight;
  final FontWeight? hintWeight;
  final TextInputAction? textInputAction;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization; // New property
  final List<TextInputFormatter>? inputFormatters;// New property
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.controller,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.keyboardType,
    this.icon,
    this.iconColor,
    this.hintText,
    this.filled,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.onChanged,
    this.height,
    this.width,
    this.hintSize,
    this.fontSize,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.contentPadding,
    this.cursorHeight,
    this.cursorColor,
    this.prefixIcon,
    this.suffixIcon,
    this.fieldRadius,
    this.enabled,
    this.maxLines,
    this.onTap,
    this.autofocus = false,
    this.onSaved,
    this.validator,
    this.margin,
    this.hintColor,
    this.errorText,
    this.borderSide,
    this.textColor,
    this.fontWeight,
    this.hintWeight,
    this.textInputAction,
    this.autovalidateMode = AutovalidateMode.onUserInteraction, // Autovalidation mode
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters, this.focusNode, // Default to none
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: margin,
        height: height ?? Sizes.screenHeight * 0.07,
        width: width ?? Sizes.screenWidth * 0.8,
        decoration: BoxDecoration(
          border: border,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
        ),
        child: TextFormField(
          textInputAction: textInputAction ?? TextInputAction.done,
          validator: validator,
          autovalidateMode: autovalidateMode, // Added autovalidateMode
          onSaved: onSaved,
          autofocus: autofocus,
          textAlignVertical: TextAlignVertical.center,
          enabled: enabled,
          controller: controller,
          cursorColor: cursorColor ?? ColorConst.primaryGreen,
          cursorHeight: cursorHeight,
          onChanged: onChanged,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization, // Pass the property
          style: style ?? TextStyle(color: ColorConst.black,fontFamily:"Poppins",fontSize: 16),
          decoration: InputDecoration(
            errorText: errorText,
            counter: const Offstage(),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: filled ?? true,
            fillColor: fillColor ?? ColorConst.containerGrey,
            hintText: hintText,
            hintStyle: TextStyle(color: ColorConst.textDark,fontFamily:"Poppins",fontSize: hintSize ?? 16),
            contentPadding: contentPadding ??
                const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
            border: OutlineInputBorder(
              borderSide: borderSide ??
                  const BorderSide(
                    width: 1,
                    color: ColorConst.textGrey,
                  ),
              borderRadius: fieldRadius ??
                  const BorderRadius.all(
                    Radius.circular(10),
                  ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: borderSide ??
                  BorderSide(
                    width: 1,
                    color: ColorConst.primaryGreen,
                  ),
              borderRadius: fieldRadius ??
                  const BorderRadius.all(
                    Radius.circular(10),
                  ),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: borderSide ??
                  const BorderSide(
                    width: 1,
                    color: ColorConst.textGrey,
                  ),
              borderRadius: fieldRadius ??
                  const BorderRadius.all(
                    Radius.circular(10),
                  ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: borderSide ??
                  BorderSide(
                    width: 1,
                    color: ColorConst.textGrey,
                  ),
              borderRadius: fieldRadius ??
                  const BorderRadius.all(
                    Radius.circular(10),
                  ),
            ),
          ),
          focusNode: focusNode,
        ),
      ),
    );
  }
}
