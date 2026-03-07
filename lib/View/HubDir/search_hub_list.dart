import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  const SearchField({super.key, required this.controller});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sizes.screenHeight * 0.065,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: TextField(
        controller: widget.controller,
        style: const TextStyle(color: ColorConst.textGrey, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search hubs, orders or delivery boys",
          hintStyle: TextStyle(color: ColorConst.textGrey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
