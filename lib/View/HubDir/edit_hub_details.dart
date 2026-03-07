import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/customTextfield.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/edit_hub_details_view_model.dart';

class EditCityDrawer extends StatefulWidget {
  const EditCityDrawer({super.key});

  @override
  State<EditCityDrawer> createState() => _EditCityDrawerState();
}

class _EditCityDrawerState extends State<EditCityDrawer> {

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Consumer<EditCityViewModel>(
      builder: (context, viewModel, child) {
        return Material(
          color: ColorConst.white,
          child: SizedBox(
            width: mobile ? Sizes.screenWidth : Sizes.screenWidth * 0.32,
            child: Column(
              children: [
                _buildHeader(viewModel),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric( horizontal: mobile ? 16 : 24, vertical: 16,),

                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(
                        bottom: mobile ? 24 : 0,
                      ),
                      children: [
                        _buildSectionHeader("General Information", Icons.info_outline),
                        CustomWidgets.verticalSpace(0.015),
                        buildField(
                          label: "Hub Name",
                          controller: viewModel.hubNameController,
                          icon: Icons.hub,
                          hint: "Enter hub name",
                        ),
                        CustomWidgets.verticalSpace(0.018),

                        buildField(
                          label: "Location / Area",
                          controller: viewModel.locationController,
                          icon: Icons.location_on_outlined,
                          hint: "Enter location",
                        ),
                        CustomWidgets.verticalSpace(0.018),

                        _buildDropdownField(viewModel),

                        CustomWidgets.verticalSpace(0.05),

                        // Manager Details Section
                        _buildSectionHeader("Manager Details", Icons.person_outline),
                        CustomWidgets.verticalSpace(0.015),

                        buildField(
                          label: "Manager Name",
                          controller: viewModel.managerNameController,
                          icon: Icons.person,
                          hint: "Enter manager name",
                        ),
                        CustomWidgets.verticalSpace(0.018),

                        buildField(
                          label: "Manager Contact",
                          controller: viewModel.managerContactController,
                          icon: Icons.phone_outlined,
                          hint: "Enter contact number",
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                        ),
                        CustomWidgets.verticalSpace(0.018),

                        buildField(
                          label: "Maximum Delivery Boys Capacity",
                          controller: viewModel.maxDeliveryBoysController,
                          icon: Icons.group_outlined,
                          hint: "Enter capacity",
                          keyboardType: TextInputType.number,
                        ),

                        CustomWidgets.verticalSpace(0.035),

                        _buildActionButtons(viewModel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(EditCityViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: ColorConst.primaryExtraLightGreen,

        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_note,
              color: ColorConst.primaryGreen,
              size: 24,
            ),
          ),
          CustomWidgets.horizontalSpace(0.015),
          CustomText.bold("Edit Hub Details", fontSize: 18),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => viewModel.closeDrawer(context),
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ColorConst.primaryGreen.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: ColorConst.primaryGreen),
        ),
        CustomWidgets.horizontalSpace(0.01),
        CustomText.semiBold(title, fontSize: 16),
      ],
    );
  }



  Widget _buildDropdownField(EditCityViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10,top: 10),
          child: Row(
            children: [
              Icon(Icons.engineering_outlined, size: 14, color: ColorConst.textGrey),
              CustomWidgets.horizontalSpace(0.005),
              CustomText.medium("Operating Status", fontSize: 13),
            ],
          ),
        ),
        Container(
          height: Sizes.screenHeight*0.05,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorConst.borderColor),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: ColorConst.white,
              value: viewModel.selectedStatus,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: viewModel.statusOptions.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: viewModel.getStatusColor(item),
                        ),
                      ),
                      CustomWidgets.horizontalSpace(0.01),
                      CustomText.medium(item,fontSize: 14,),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => viewModel.updateSelectedStatus(value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(EditCityViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: AppBtn(
            height: Sizes.screenHeight*0.053 ,
            title: "Cancel",
            onTap: () => viewModel.cancel(context),
            color: ColorConst.containerGrey,
            titleColor: ColorConst.textGrey,
          ),
        ),
        CustomWidgets.horizontalSpace(0.015),
        Expanded(
          child: AppBtn(
            height: Sizes.screenHeight*0.053 ,
            title: "Save Changes",
            onTap: () => viewModel.saveChanges(context),
          ),
        ),
      ],
    );
  }

}
Widget buildField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  String? hint,
  TextInputType? keyboardType,
  int? maxLength,
}) {

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only( bottom: 10,top: 10),
        child: Row(
          children: [
            Icon(icon, size: 14, color: ColorConst.textGrey),
            CustomWidgets.horizontalSpace(0.005),
            CustomText.medium(label, fontSize: 13),
          ],
        ),
      ),
      CustomTextField(
        controller: controller,
        hintText: hint ?? label,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: TextStyle(fontSize: 13),
        borderSide: BorderSide(color: ColorConst.borderColor),
        height: Sizes.screenHeight * 0.05,
        width: Sizes.screenWidth,
      ),
    ],
  );
}