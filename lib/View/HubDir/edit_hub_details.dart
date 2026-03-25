// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/customTextfield.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/edit_hub_details_view_model.dart';
//
// class EditCityDrawer extends StatefulWidget {
//   const EditCityDrawer({super.key});
//
//   @override
//   State<EditCityDrawer> createState() => _EditCityDrawerState();
// }
//
// class _EditCityDrawerState extends State<EditCityDrawer> {
//
//   @override
//   Widget build(BuildContext context) {
//     final mobile = Responsive.isMobile(context);
//     return Consumer<EditCityViewModel>(
//       builder: (context, viewModel, child) {
//         return Material(
//           color: ColorConst.white,
//           child: SizedBox(
//             width: mobile ? Sizes.screenWidth : Sizes.screenWidth * 0.32,
//             child: Column(
//               children: [
//                 _buildHeader(viewModel),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric( horizontal: mobile ? 16 : 24, vertical: 16,),
//
//                     child: ListView(
//                       shrinkWrap: true,
//                       padding: EdgeInsets.only(
//                         bottom: mobile ? 24 : 0,
//                       ),
//                       children: [
//                         _buildSectionHeader("Manager Details", Icons.person_outline),
//                         CustomWidgets.verticalSpace(0.015),
//
//                         buildField(
//                           label: "Manager Name",
//                           controller: viewModel.managerNameController,
//                           icon: Icons.person,
//                           hint: "Enter manager name",
//                         ),
//                         CustomWidgets.verticalSpace(0.018),
//
//                         buildField(
//                           label: "Manager Contact",
//                           controller: viewModel.managerContactController,
//                           icon: Icons.phone_outlined,
//                           hint: "Enter contact number",
//                           keyboardType: TextInputType.phone,
//                           maxLength: 10,
//                         ),
//                         CustomWidgets.verticalSpace(0.018),
//
//                         buildField(
//                           label: "Maximum Delivery Boys Capacity",
//                           controller: viewModel.maxDeliveryBoysController,
//                           icon: Icons.group_outlined,
//                           hint: "Enter capacity",
//                           keyboardType: TextInputType.number,
//                         ),
//
//                         CustomWidgets.verticalSpace(0.035),
//
//                         _buildActionButtons(viewModel),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildHeader(EditCityViewModel viewModel) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: ColorConst.primaryExtraLightGreen,
//
//         border: const Border(bottom: BorderSide(color: Colors.black12)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: ColorConst.primaryGreen.withValues(alpha:0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(
//               Icons.edit_note,
//               color: ColorConst.primaryGreen,
//               size: 24,
//             ),
//           ),
//           CustomWidgets.horizontalSpace(0.015),
//           CustomText.bold("Edit Hub Details", fontSize: 18),
//           const Spacer(),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: IconButton(
//               onPressed: () => viewModel.closeDrawer(context),
//               icon: const Icon(Icons.close, size: 18),
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: ColorConst.primaryGreen.withValues(alpha:0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, size: 16, color: ColorConst.primaryGreen),
//         ),
//         CustomWidgets.horizontalSpace(0.01),
//         CustomText.semiBold(title, fontSize: 16),
//       ],
//     );
//   }
//
//
//
//   Widget _buildDropdownField(EditCityViewModel viewModel) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 10,top: 10),
//           child: Row(
//             children: [
//               Icon(Icons.engineering_outlined, size: 14, color: ColorConst.textGrey),
//               CustomWidgets.horizontalSpace(0.005),
//               CustomText.medium("Operating Status", fontSize: 13),
//             ],
//           ),
//         ),
//         Container(
//           height: Sizes.screenHeight*0.05,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: ColorConst.borderColor),
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 12),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               dropdownColor: ColorConst.white,
//               value: viewModel.selectedStatus,
//               isExpanded: true,
//               icon: const Icon(Icons.keyboard_arrow_down),
//               items: viewModel.statusOptions.map((String item) {
//                 return DropdownMenuItem<String>(
//                   value: item,
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: viewModel.getStatusColor(item),
//                         ),
//                       ),
//                       CustomWidgets.horizontalSpace(0.01),
//                       CustomText.medium(item,fontSize: 14,),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) => viewModel.updateSelectedStatus(value),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButtons(EditCityViewModel viewModel) {
//     return Row(
//       children: [
//         Expanded(
//           child: AppBtn(
//             height: Sizes.screenHeight*0.053 ,
//             title: "Cancel",
//             onTap: () => viewModel.cancel(context),
//             color: ColorConst.containerGrey,
//             titleColor: ColorConst.textGrey,
//           ),
//         ),
//         CustomWidgets.horizontalSpace(0.015),
//         Expanded(
//           child: AppBtn(
//             height: Sizes.screenHeight*0.053 ,
//             title: "Save Changes",
//             onTap: () => viewModel.saveChanges(context),
//           ),
//         ),
//       ],
//     );
//   }
//
// }
// Widget buildField({
//   required String label,
//   required TextEditingController controller,
//   required IconData icon,
//   String? hint,
//   TextInputType? keyboardType,
//   int? maxLength,
// }) {
//
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: EdgeInsets.only( bottom: 10,top: 10),
//         child: Row(
//           children: [
//             Icon(icon, size: 14, color: ColorConst.textGrey),
//             CustomWidgets.horizontalSpace(0.005),
//             CustomText.medium(label, fontSize: 13),
//           ],
//         ),
//       ),
//       CustomTextField(
//         controller: controller,
//         hintText: hint ?? label,
//         keyboardType: keyboardType,
//         maxLength: maxLength,
//         style: TextStyle(fontSize: 13),
//         borderSide: BorderSide(color: ColorConst.borderColor),
//         height: Sizes.screenHeight * 0.05,
//         width: Sizes.screenWidth,
//       ),
//     ],
//   );
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_manager_edit_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/profile_view_model.dart';

class EditCityDrawer extends StatefulWidget {
  final String hubId;
  const EditCityDrawer({super.key, required this.hubId});

  @override
  State<EditCityDrawer> createState() => _EditCityDrawerState();
}

class _EditCityDrawerState extends State<EditCityDrawer> {


  // ── Controllers ────────────────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _adharCtrl;
  late final TextEditingController _panCtrl;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _adharCtrl = TextEditingController();
    _panCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final managerData =
      Provider.of<ProfileViewModel>(context, listen: false);

      managerData.getManagerProfileDataApi(context, widget.hubId);
    });

  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _addressCtrl.dispose();
    _adharCtrl.dispose();
    _panCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    final profileVM = Provider.of<ProfileViewModel>(context);

    final d = profileVM.managerProfileData?.data;

    if (d != null) {
      _nameCtrl.text = d.name?.toString() ?? '';
      _phoneCtrl.text = d.phone?.toString() ?? '';
      _emailCtrl.text = d.email?.toString() ?? '';
      _passwordCtrl.text = d.password?.toString() ?? '';
      _addressCtrl.text = d.address?.toString() ?? '';
      _adharCtrl.text = d.adharno?.toString() ?? '';
      _panCtrl.text = d.panno?.toString() ?? '';
    }
    return Consumer<HubManagerEditViewModel>(
      builder: (context, vm, _) {
        return Material(
          color: ColorConst.white,
          child: SizedBox(
            width: mobile
                ? Sizes.screenWidth
                : Sizes.screenWidth * 0.35,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: mobile ? 16 : 24,
                      vertical: 16,
                    ),
                    children: [
                      // ── Profile info strip ─────────────────────────
                      _buildProfileStrip(),
                      CustomWidgets.verticalSpace(0.025),

                      // ── Personal info ──────────────────────────────
                      _sectionHeader(
                          'Personal Info', Icons.person_outline_rounded),
                      CustomWidgets.verticalSpace(0.012),
                      _field(
                        label: 'Full Name',
                        controller: _nameCtrl,
                        icon: Icons.person_outline_rounded,
                        hint: 'Enter full name',
                      ),
                      CustomWidgets.verticalSpace(0.016),
                      _field(
                        label: 'Phone Number',
                        controller: _phoneCtrl,
                        icon: Icons.phone_outlined,
                        hint: 'Enter phone number',
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                      ),
                      CustomWidgets.verticalSpace(0.016),
                      _field(
                        label: 'Email',
                        controller: _emailCtrl,
                        icon: Icons.email_outlined,
                        hint: 'Enter email address',

                        keyboardType: TextInputType.emailAddress,
                      ),
                      CustomWidgets.verticalSpace(0.016),
                      _field(
                        label: 'Address',
                        controller: _addressCtrl,
                        icon: Icons.location_on_outlined,
                        hint: 'Enter address',
                        readOnly: true
                      ),
                      CustomWidgets.verticalSpace(0.025),

                      // ── Security ───────────────────────────────────
                      _sectionHeader(
                          'Security', Icons.lock_outline_rounded),
                      CustomWidgets.verticalSpace(0.012),
                      _passwordField(),
                      CustomWidgets.verticalSpace(0.025),

                      // ── Identity docs ──────────────────────────────
                      _sectionHeader(
                          'Identity Documents',
                          Icons.badge_outlined),
                      CustomWidgets.verticalSpace(0.012),
                      _field(
                        label: 'Aadhaar Number',
                        controller: _adharCtrl,
                        icon: Icons.credit_card_outlined,
                        hint: 'Enter Aadhaar number',
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                      ),
                      CustomWidgets.verticalSpace(0.016),
                      _field(
                        label: 'PAN Number',
                        controller: _panCtrl,
                        icon: Icons.article_outlined,
                        hint: 'Enter PAN number',
                        maxLength: 10,
                      ),
                      CustomWidgets.verticalSpace(0.035),

                      // ── Action buttons ─────────────────────────────
                      _buildActionButtons(context, vm),
                      CustomWidgets.verticalSpace(0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: ColorConst.primaryExtraLightGreen,
        border: const Border(
            bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.manage_accounts_outlined,
                color: ColorConst.primaryGreen, size: 22),
          ),
          CustomWidgets.horizontalSpace(0.015),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.bold('Edit Hub Manager', fontSize: 17),
                CustomText.regular(
                  'Update manager details',
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints:
              const BoxConstraints(maxWidth: 32, maxHeight: 32),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile strip ───────────────────────────────────────────────────────────

  Widget _buildProfileStrip() {
    final managerData = Provider.of<ProfileViewModel>(context,listen: false);
    final d = managerData.managerProfileData?.data;
    final isActive = (d?.status == 1 || d?.status == '1');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ColorConst.primaryGreen.withValues(alpha:0.2)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor:
            ColorConst.primaryGreen.withValues(alpha:0.15),
            child: Text(
              _initials(d?.name?.toString() ?? '?'),
              style: TextStyle(
                  color: ColorConst.primaryGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.semiBold(
                  d?.name?.toString() ?? '—',
                  fontSize: 14,
                ),
                const SizedBox(height: 2),
                CustomText.regular(
                  d?.email?.toString() ?? '—',
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoTag(
                        Icons.hub_outlined,
                        'Zone ID: ${d?.hubzoneid ?? '—'}',
                        const Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    _statusTag(isActive),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTag(IconData icon, String label, Color color) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Widget _statusTag(bool isActive) {
    final color = isActive
        ? const Color(0xFF059669)
        : const Color(0xFF9CA3AF);
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ColorConst.primaryGreen.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 15, color: ColorConst.primaryGreen),
        ),
        CustomWidgets.horizontalSpace(0.01),
        CustomText.semiBold(title, fontSize: 14),
      ],
    );
  }

  // ── Text field ──────────────────────────────────────────────────────────────

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    bool readOnly = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(icon, size: 13, color: ColorConst.textGrey),
              CustomWidgets.horizontalSpace(0.005),
              CustomText.medium(label, fontSize: 12),
            ],
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13),
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF), fontSize: 13),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              BorderSide(color: ColorConst.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              BorderSide(color: ColorConst.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: ColorConst.primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Password field ──────────────────────────────────────────────────────────

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 13, color: ColorConst.textGrey),
              CustomWidgets.horizontalSpace(0.005),
              CustomText.medium('Password', fontSize: 12),
            ],
          ),
        ),
        StatefulBuilder(
          builder: (_, setInner) => TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter new password',
              hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF), fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                BorderSide(color: ColorConst.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                BorderSide(color: ColorConst.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: ColorConst.primaryGreen, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Action buttons ──────────────────────────────────────────────────────────

  Widget _buildActionButtons(
      BuildContext context, HubManagerEditViewModel vm) {
    return Row(
      children: [
        // Cancel
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: BorderSide(color: ColorConst.borderColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: CustomText.medium('Cancel',
                fontSize: 14, color: ColorConst.textGrey),
          ),
        ),
        CustomWidgets.horizontalSpace(0.015),

        // Save Changes
        Expanded(
          child: ElevatedButton(
            onPressed: vm.editMangerLoading
                ? null
                : () => _onSave(context, vm),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConst.primaryGreen,
              disabledBackgroundColor:
              ColorConst.primaryGreen.withValues(alpha:0.6),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: vm.editMangerLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : CustomText.semiBold('Save Changes',
                fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ── Save handler ────────────────────────────────────────────────────────────

  void _onSave(BuildContext context, HubManagerEditViewModel vm) {
    final managerData = Provider.of<ProfileViewModel>(context,listen: false);
    final d = managerData.managerProfileData!.data;
    vm.hubManagerEditApi(
      context,
      d!.id?.toString() ?? '',
      d.hubzoneid?.toString() ?? '',
      _nameCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _adharCtrl.text.trim(),
      _addressCtrl.text.trim(),
      _panCtrl.text.trim(),
      d.img?.toString() ?? '',
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}