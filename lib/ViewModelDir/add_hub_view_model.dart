import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/hub_manager_create_repo.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/hub_zone_create_repo.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/profile_view_model.dart';

class AddHubViewModel extends ChangeNotifier {
  final TextEditingController hubNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController operatingStatusController =
      TextEditingController();
  final TextEditingController managerNameController = TextEditingController();
  final TextEditingController managerContactController =
      TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController coverageRadiusController =
      TextEditingController();
  final TextEditingController stateController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  TextEditingController managerAddressController = TextEditingController();
  TextEditingController managerAdharNumber = TextEditingController();
  TextEditingController managerPanNumber = TextEditingController();
  TextEditingController managerImage = TextEditingController();
  TextEditingController managerEmailController = TextEditingController();
  TextEditingController managerPasswordController = TextEditingController();
  TextEditingController hubZoneAddress = TextEditingController();
  TextEditingController pincodeHubZone = TextEditingController();

  String? _selectedHubZoneId;
  String? get selectedHubZoneId => _selectedHubZoneId;

  void setSelectedHubZoneId(String? val) {
    _selectedHubZoneId = val;
    notifyListeners();
  }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Icon(
            Icons.check_circle,
            color: ColorConst.primaryGreen,
            size: 60,
          ),
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

  void clearForm() {
    hubNameController.clear();
    locationController.clear();
    operatingStatusController.clear();
    managerNameController.clear();
    managerContactController.clear();
    cityController.clear();
    pincodeController.clear();
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

  bool _isZoneCreated = false;
  bool get isZoneCreated => _isZoneCreated;

  void setZoneCreated(bool value) {
    _isZoneCreated = value;
    notifyListeners();
  }

  final HubZoneCreateRepo _hubZoneCreateRepo = HubZoneCreateRepo();
  final HubManagerCreateRepo _hubManagerCreateRepo = HubManagerCreateRepo();

  bool _loading = false;
  bool get loading => _loading;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> hubZoneCreateApi(BuildContext context) async {
    if (!context.mounted) return;

    _setLoading(true);
    final profileProvider = Provider.of<ProfileViewModel>(
      context,
      listen: false,
    );
    final data = {
      "cityzoneid": profileProvider.profileData?.data?.cityzoneid.toString(),
      "name": hubNameController.text.trim(),
      "address": hubZoneAddress.text.trim(),
      "pincode":pincodeHubZone.text.trim(),
      "radiuskm": coverageRadiusController.text.trim(),
      "lat": latitudeController.text.trim(),
      "long": longitudeController.text.trim(),
    };
    print(data);
    print("egdieguigiueb");
    try {
      final response = await _hubZoneCreateRepo.hubZoneCreateApi(data);

      if (!context.mounted) {
        _setLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        if (!context.mounted) {
          _setLoading(false);
          return;
        }
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Added Successful',
          title: 'Success',
          type: SnackBarType.success,
        );
        print("fkbekfbkvfb");
        Navigator.pushReplacementNamed(context, RoutesName.adminSliderLayoutScreen);
        setZoneCreated(true);
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Not added Failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ loginApi error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  bool _addLoading = false;
  bool get addLoading => _addLoading;

  void _setAddLoading(bool value) {
    _addLoading = value;
    notifyListeners();
  }

  File? _managerImageFile;
  File? get managerImageFile => _managerImageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickManagerImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      _managerImageFile = File(picked.path);

      /// convert to base64
      final bytes = await _managerImageFile!.readAsBytes();
      managerImage.text = base64Encode(bytes);

      notifyListeners();
    }
  }

  Future<void> hubManagerApi(BuildContext context,String hubZoneId) async {
    if (!context.mounted) return;

    _setAddLoading(true);
    final data = {
      "hubzoneid": hubZoneId,
      "name": managerNameController.text.trim(),
      "phone": managerContactController.text.trim(),
      "address": managerAddressController.text.trim(),
      "adharno": managerAdharNumber.text.trim(),
      "panno": managerPanNumber.text.trim(),
      // "img":  managerImage.text,
      "img":  "FUYUYFU",
      "email": managerEmailController.text.trim(),
      "password": managerPasswordController.text.trim(),
    };
    print(data);
    print("egdieguigiueb");
    try {
      final response = await _hubManagerCreateRepo.hubManagerCreateApi(data);

      if (!context.mounted) {
        _setAddLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        if (!context.mounted) {
          _setAddLoading(false);
          return;
        }
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Added Successful',
          title: 'Success',
          type: SnackBarType.success,
        );
        Navigator.pushReplacementNamed(context, RoutesName.adminSliderLayoutScreen);
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Not added Failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ loginApi error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setAddLoading(false);
    }
  }
}
