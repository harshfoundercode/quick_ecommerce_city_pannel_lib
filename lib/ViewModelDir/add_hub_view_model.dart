import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';

class AddHubViewModel extends ChangeNotifier {

  final TextEditingController hubNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController operatingStatusController = TextEditingController();
  final TextEditingController managerNameController = TextEditingController();
  final TextEditingController managerContactController = TextEditingController();
  final TextEditingController maxOrdersController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController coverageRadiusController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  // Dropdown State
  String? _selectedStatus = "Active";
  final List<String> _statusOptions = ["Active", "Inactive", "Maintenance"];

  // Getters
  String? get selectedStatus => _selectedStatus;
  List<String> get statusOptions => _statusOptions;

  // Status Color Getter
  Color getStatusColor(String status) {
    switch (status) {
      case "Active":
        return ColorConst.primaryGreen;
      case "Inactive":
        return ColorConst.textGrey;
      case "Maintenance":
        return Colors.orange;
      default:
        return ColorConst.textGrey;
    }
  }

  // Methods
  void updateSelectedStatus(String? value) {
    if (value != null) {
      _selectedStatus = value;
      operatingStatusController.text = value;
      notifyListeners();
    }
  }

  Future<void> saveHub(BuildContext context) async {
    _showSuccessDialog(context);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(Icons.check_circle, color: ColorConst.primaryGreen, size: 60),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText.bold("Success!", fontSize: 20),
              CustomWidgets.verticalSpace(0.01),
              CustomText.medium(
                "Hub added successfully",
                color: ColorConst.textGrey,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog// Close drawer
              },
              child: CustomText.semiBold("OK", color: ColorConst.primaryGreen),
            ),
          ],
        );
      },
    );
  }



  void clearForm(){
    hubNameController.clear();
    locationController.clear();
    operatingStatusController.clear();
    managerNameController.clear();
    managerContactController.clear();
    cityController.clear();
    pincodeController.clear();
    maxOrdersController.clear();
    coverageRadiusController.clear();
    stateController.clear();

  }

  @override
  void dispose() {
    hubNameController.dispose();
    locationController.dispose();
    operatingStatusController.dispose();
    managerNameController.dispose();
    managerContactController.dispose();
    coverageRadiusController.dispose();
    stateController.dispose();
    super.dispose();
  }
}