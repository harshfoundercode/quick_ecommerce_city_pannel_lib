import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';

class EditCityViewModel extends ChangeNotifier {


  // Text Controllers
  final TextEditingController hubNameController = TextEditingController(text: "Hub-Gomti Nagar");
  final TextEditingController locationController = TextEditingController(text: "Uttar Pradesh");
  final TextEditingController operatingStatusController = TextEditingController(text: "Active");
  final TextEditingController managerNameController = TextEditingController(text: "Rahul Sharma");
  final TextEditingController managerContactController = TextEditingController(text: "9876543210");
  final TextEditingController maxDeliveryBoysController = TextEditingController(text: "20");

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


  Map<String, String> getFormData() {
    return {
      'hubName': hubNameController.text,
      'location': locationController.text,
      'operatingStatus': operatingStatusController.text,
      'managerName': managerNameController.text,
      'managerContact': managerContactController.text,
      'maxDeliveryBoys': maxDeliveryBoysController.text,
    };
  }

  Future<void> saveChanges(BuildContext context) async {
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
                "Hub details updated successfully",
                color: ColorConst.textGrey,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pop(context); // Close drawer
              },
              child: CustomText.semiBold("OK", color: ColorConst.primaryGreen),
            ),
          ],
        );
      },
    );
  }

  void cancel(BuildContext context) {
    Navigator.pop(context);
  }

  void closeDrawer(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    hubNameController.dispose();
    locationController.dispose();
    operatingStatusController.dispose();
    managerNameController.dispose();
    managerContactController.dispose();
    maxDeliveryBoysController.dispose();
    super.dispose();
  }
}