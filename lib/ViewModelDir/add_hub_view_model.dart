import 'dart:convert';
import 'package:http/http.dart' as http;
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
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/dashboard_content.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart';
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

    latitudeController.clear();
    longitudeController.clear();
    hubZoneAddress.clear();
    pincodeHubZone.clear();

    managerAddressController.clear();
    managerAdharNumber.clear();
    managerPanNumber.clear();
    managerImage.clear();
    managerEmailController.clear();
    managerPasswordController.clear();
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
        Provider.of<HubZoneViewModel>(context, listen: false).getHubZoneListDataApi(context);
        clearForm();
        hubNameController.clear();
        latitudeController.clear();
        longitudeController.clear();
        hubZoneAddress.clear();
        pincodeHubZone.clear();
        final adminVM = Provider.of<AdminViewModel>(context, listen: false);
        adminVM.changeScreen(const DashboardContent(), 0);
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.adminSliderLayoutScreen,
              (route) => false,
        );
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
      if (kDebugMode) print('❌ hub zone create error: $e');
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

  XFile? _managerImageFile;
  XFile? get managerImageFile => _managerImageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickManagerImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      _managerImageFile = picked;
      notifyListeners();
    }
  }

  String cloudName = "ddsnwfgaw";
  String preset = "FastoDriver";

  Future<String?> uploadToCloudinary(XFile file) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] = preset;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await file.readAsBytes(),
          filename: file.name,
        ),
      );

      final response = await request.send();
      final resData = await response.stream.bytesToString();

      final jsonData = jsonDecode(resData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'];
      } else {
        debugPrint("Cloudinary Error: $jsonData");
        return null;
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  Future<void> hubManagerApi(BuildContext context,String hubZoneId) async {
    if (!context.mounted) return;

    _setAddLoading(true);
    String imageUrl = '';

    if (_managerImageFile != null) {
      final uploadedUrl = await uploadToCloudinary(_managerImageFile!);

      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      } else {
        CustomSnackBar.show(
          context,
          message: 'Image upload failed',
          title: 'Error',
          type: SnackBarType.error,
        );
        _setAddLoading(false);
        return;
      }
    }
    final data = {
      "hubzoneid": hubZoneId,
      "name": managerNameController.text.trim(),
      "phone": managerContactController.text.trim(),
      "address": managerAddressController.text.trim(),
      "adharno": managerAdharNumber.text.trim(),
      "panno": managerPanNumber.text.trim(),
      "img":  imageUrl,
      "email": managerEmailController.text.trim(),
      "password": managerPasswordController.text.trim(),
    };
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
        Provider.of<AllHubViewModel>(context, listen: false).getHubListDataApi(context);
        clearManagerForm();
        final adminVM = Provider.of<AdminViewModel>(context, listen: false);
        adminVM.changeScreen(const DashboardContent(), 0);
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.adminSliderLayoutScreen,
              (route) => false,
        );
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

  void clearManagerForm() {
    managerNameController.clear();
    managerContactController.clear();
    managerAddressController.clear();
    managerAdharNumber.clear();
    managerPanNumber.clear();
    managerEmailController.clear();
    managerPasswordController.clear();

    // ✅ Clear image
    _managerImageFile = null;

    // ✅ Reset dropdown
    _selectedHubZoneId = null;

    notifyListeners();
  }
}
