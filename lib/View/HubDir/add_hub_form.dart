import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/customTextfield.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/MapDir/map_picker.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/add_hub_view_model.dart';

class AddHubForm extends StatefulWidget {
  const AddHubForm({super.key});

  @override
  State<AddHubForm> createState() => _AddHubFormState();
}


class _AddHubFormState extends State<AddHubForm> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AddHubViewModel>(
      builder: (context, ahvm, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.screenWidth * 0.02,
            vertical: Sizes.screenHeight * 0.02,
          ),
          width: Sizes.screenWidth,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  CustomWidgets.pageHeader(
                    title: "Add New Hub",
                    subtitle:
                    "Configure a new delivery hub and set its operational area in the city",
                  ),

                  CustomWidgets.verticalSpace(0.03),
                  /// STEP 1 : ZONE SETUP
                  if (!ahvm.isZoneCreated) _buildZoneSetup(ahvm),

                  /// STEP 2 : HUB FORM
                  if (ahvm.isZoneCreated) ...[
                    _buildBasicInformationCard(ahvm),
                    CustomWidgets.verticalSpace(0.02),
                    _buildLocationCard(ahvm),
                    CustomWidgets.verticalSpace(0.03),
                    _buildActionButtons(ahvm),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoneSetup(AddHubViewModel ahvm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          CustomText.bold("Create Delivery Zone", fontSize: 18),

          CustomWidgets.verticalSpace(0.02),

          _buildField(
            label: "Hub Name",
            controller: ahvm.hubNameController,
            icon: Icons.hub,
            hint: "Enter hub name",
          ),

          CustomWidgets.verticalSpace(0.02),

          _buildField(
            label: "Radius (KM)",
            controller: ahvm.coverageRadiusController,
            icon: Icons.radar,
            hint: "Enter radius",
            readOnly: true,
            keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            maxLength: 3
          ),

          CustomWidgets.verticalSpace(0.02),

          /// MAP PICKER BUTTON
          GestureDetector(
            onTap: () async {

              final result = await showDialog(
                context: context,
                builder: (_) => const MapPickerPopup(),
              );

              if (result != null) {
                ahvm.locationController.text = result["address"];
                ahvm.latitudeController.text = result["lat"].toString();
                ahvm.longitudeController.text = result["lng"].toString();
                ahvm.coverageRadiusController.text = result['radius'].toString();
              }
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorConst.borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.map),
                  SizedBox(width: 10),
                  Text("Select Address From Map"),
                ],
              ),
            ),
          ),

          CustomWidgets.verticalSpace(0.02),

          _buildField(
            label: "Latitude",
            controller: ahvm.latitudeController,
            icon: Icons.location_on,
            readOnly: true
          ),

          CustomWidgets.verticalSpace(0.02),

          _buildField(
            label: "Longitude",
            controller: ahvm.longitudeController,
            icon: Icons.location_on,
              readOnly: true

          ),

          CustomWidgets.verticalSpace(0.03),

          Align(
            alignment: Alignment.centerRight,
            child: AppBtn(
              width: Sizes.screenWidth * 0.1,
              height: Sizes.screenHeight * 0.05,
              title: "Next",
              onTap: () {
                if(ahvm.hubNameController.text.isEmpty){
                  CustomSnackBar.show(context, message: "Enter Hub Name", type: SnackBarType.error);
                } else if(ahvm.coverageRadiusController.text.isEmpty){
                  CustomSnackBar.show(context, message: "Enter hub coverage radius", type: SnackBarType.error);
                } else if(ahvm.latitudeController.text.isEmpty){
                  CustomSnackBar.show(context, message: "Enter latitude coordinates", type: SnackBarType.error);
                } else if(ahvm.longitudeController.text.isEmpty){
                  CustomSnackBar.show(context, message: "Enter longitude coordinates", type: SnackBarType.error);
                } else {
                ahvm.hubZoneCreateApi(context);
              }}
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformationCard(AddHubViewModel ahvm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorConst.primaryExtraLightGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorConst.primaryGreen.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: ColorConst.primaryGreen,
                    size: 24,
                  ),
                ),
                CustomWidgets.horizontalSpace(0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText.bold(
                        "Basic Information",
                        fontSize: 18,
                      ),
                      CustomText.medium(
                        "Essentials details to identify and manage this hub",
                        color: ColorConst.textGrey,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form Fields
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildField(
                  label: "Hub Name",
                  controller: ahvm.hubNameController,
                  icon: Icons.hub,

                  hint: "Enter hub name (e.g., Hub - Gomti Nagar)",

                ),

                CustomWidgets.verticalSpace(0.03),

                _buildField(
                  label: "Hub Manager Name",
                  controller: ahvm.managerNameController,
                  icon: Icons.manage_accounts,
                  hint: "Enter full name of hub manager",),

                CustomWidgets.verticalSpace(0.03),

                _buildField(
                  label: "Contact Number",
                  controller: ahvm.managerContactController,
                  icon: Icons.phone_outlined,
                  hint: "Enter 10-digit contact number",
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),

                CustomWidgets.verticalSpace(0.03),

                _buildField(
                  label: "Aadhaar Number",
                  controller: ahvm.managerAdharNumber,
                  icon: Icons.post_add_sharp,
                  hint: "Enter manager aadhaar number",
                  keyboardType: TextInputType.phone,
                  maxLength: 15,
                ),

                CustomWidgets.verticalSpace(0.03),
                _buildField(
                  label: "PanCard Number",
                  controller: ahvm.managerPanNumber,
                  icon: Icons.post_add_sharp,
                  hint: "Enter manager pancard number",
                  maxLength: 15,
                ),

                CustomWidgets.verticalSpace(0.03),
                _buildField(
                  label: "Manager Email",
                  controller: ahvm.managerEmailController,
                  icon: Icons.post_add_sharp,
                  hint: "Enter manager email credential",
                ),

                CustomWidgets.verticalSpace(0.03),

                _buildField(
                  label: "Manager Email Password",
                  controller: ahvm.managerPasswordController,
                  icon: Icons.post_add_sharp,
                  hint: "Enter manager email password credential",
                ),

                CustomWidgets.verticalSpace(0.03),

                _buildManagerImagePicker(ahvm),

                CustomWidgets.verticalSpace(0.03),
                // _buildDropdownField(ahvm),
                //
                // CustomWidgets.verticalSpace(0.03),

              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildManagerImagePicker(AddHubViewModel ahvm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            Icon(Icons.image, size: 16, color: ColorConst.primaryGreen),
            CustomWidgets.horizontalSpace(0.005),
            CustomText.medium("Manager Image", fontSize: 14),
          ],
        ),

        CustomWidgets.verticalSpace(0.01),

        Row(
          children: [

            /// IMAGE PREVIEW
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorConst.borderColor),
              ),
              child: ahvm.managerImageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  ahvm.managerImageFile!,
                  fit: BoxFit.cover,
                ),
              )
                  : const Icon(Icons.person,size:30),
            ),

            CustomWidgets.horizontalSpace(0.02),

            /// PICK IMAGE BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text("Upload Image"),
              onPressed: () {
                _showImagePicker(context, ahvm);
              },
            ),
          ],
        ),
      ],
    );
  }
  void _showImagePicker(BuildContext context, AddHubViewModel ahvm) {

    showModalBottomSheet(
      context: context,
      builder: (_) {

        return SafeArea(
          child: Wrap(
            children: [

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  ahvm.pickManagerImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  ahvm.pickManagerImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationCard(AddHubViewModel ahvm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorConst.primaryExtraLightGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorConst.primaryGreen.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: ColorConst.primaryGreen,
                    size: 24,
                  ),
                ),
                CustomWidgets.horizontalSpace(0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText.bold(
                        "Location & Coverage Area",
                        fontSize: 18,
                      ),
                      CustomText.medium(
                        "Physical address of the hub and the area it serves",
                        color: ColorConst.textGrey,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form Fields
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildField(
                  label: "Street Address",
                  controller: ahvm.locationController,
                  icon: Icons.home_outlined,
                  hint: "Enter complete street address",
                ),

                CustomWidgets.verticalSpace(0.03),

                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: "City",
                        controller: ahvm.cityController,
                        icon: Icons.location_city,
                        hint: "Enter city",
                      ),
                    ),
                    CustomWidgets.horizontalSpace(0.02),
                    Expanded(
                      child: _buildField(
                        label: "State",
                        controller: ahvm.stateController,
                        icon: Icons.map_outlined,
                        hint: "Enter state",
                      ),
                    ),
                  ],
                ),

                CustomWidgets.verticalSpace(0.03),

                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: "Pincode",
                        controller: ahvm.pincodeController,
                        icon: Icons.numbers,
                        hint: "Enter 6-digit pincode",
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                    ),
                    CustomWidgets.horizontalSpace(0.02),
                    Expanded(
                      child: _buildField(
                        label: "Coverage Radius (km)",
                        controller: ahvm.coverageRadiusController,
                        icon: Icons.radar_outlined,
                        hint: "Enter coverage radius",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                CustomWidgets.verticalSpace(0.03),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: ColorConst.primaryGreen),
              CustomWidgets.horizontalSpace(0.005),
              CustomText.medium(label, fontSize: 14),
              const Text(" *", style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ),
        ),
        CustomTextField(
          controller: controller,
          hintText: hint ?? label,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          borderSide: BorderSide(color: ColorConst.borderColor),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          style: TextStyle(color: ColorConst.textDark, fontSize: 14),
          hintSize: 14,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }

  Widget _buildActionButtons(AddHubViewModel ahvm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppBtn(
          width: Sizes.screenWidth*0.1,
          height: Sizes.screenHeight*0.05,
          onTap: () {
            _formKey.currentState?.reset();
            ahvm.clearForm();
          },
          title:"Clear All",
          titleColor: ColorConst.white,
          color: ColorConst.textGrey,
        ),
        CustomWidgets.horizontalSpace(0.01),
        AppBtn(
          width: Sizes.screenWidth*0.1,
          height: Sizes.screenHeight*0.05,

          onTap: () {
            if (_formKey.currentState!.validate()) {
              ahvm.saveHub(context);
              final addHubViewModel = Provider.of<AddHubViewModel>(context,listen: false);
              addHubViewModel.hubManagerApi(context);
            }
          },
          title: "Create Hub",
        )
      ],
    );
  }
}