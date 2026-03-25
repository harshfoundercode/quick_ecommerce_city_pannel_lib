import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/customTextfield.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/search_hub_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';

class SearchFilterSection extends StatefulWidget {
  const SearchFilterSection({super.key});

  @override
  State<SearchFilterSection> createState() => _SearchFilterSectionState();
}

class _SearchFilterSectionState extends State<SearchFilterSection> {
  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);

    final viewModel = Provider.of<AllHubViewModel>(context, listen: false);
    return mobile?SizedBox(
      height: Sizes.screenHeight*0.12,
      child: Column(
        children: [
          CustomTextField(
            width: Sizes.screenWidth,
            controller:  viewModel.searchController,
            hintText: "Search your hub",
            filled: true,
            fillColor: Colors.white,
          ),
          const Spacer(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     CustomWidgets.ghostButton(
          //       text: "Filter",
          //       icon: Icons.filter_alt_outlined,
          //       onPressed: viewModel.onFilterPressed,
          //     ),
          //     SizedBox(width: Sizes.screenWidth * 0.01),
          //     CustomWidgets.ghostButton(
          //       text: "Sort",
          //       icon: Icons.swap_vert,
          //       onPressed: viewModel.onSortPressed,
          //     ),
          //   ],
          // )

        ],
      ),
    ): Row(
      children: [
        Expanded(
          flex: 2,
          child: SearchField(
              controller: viewModel.searchController
          ),
        ),
        const Spacer(),
        // CustomWidgets.ghostButton(
        //   text: "Filter",
        //   icon: Icons.filter_alt_outlined,
        //   onPressed: viewModel.onFilterPressed,
        // ),
        //
        // SizedBox(width: Sizes.screenWidth * 0.01),
        // CustomWidgets.ghostButton(
        //   text: "Sort",
        //   icon: Icons.swap_vert,
        //   onPressed: viewModel.onSortPressed,
        // ),
      ],
    );
  }
}
