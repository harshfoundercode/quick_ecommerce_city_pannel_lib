import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/MapDir/map_picker.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/add_hub_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_zone_list_view_model.dart';

class AddHubScreen extends StatefulWidget {
  const AddHubScreen({super.key});

  @override
  State<AddHubScreen> createState() => _AddHubScreenState();
}

class _AddHubScreenState extends State<AddHubScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _locationPicked = false;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddHubViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info banner ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ColorConst.primaryGreen.withValues(alpha:0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ColorConst.primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorConst.primaryGreen.withValues(alpha:0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: ColorConst.primaryGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Fill in the hub details and pick a location on the map to define its coverage area.',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorConst.primaryGreen,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Section: Hub Info ─────────────────────────────────────────
              _sectionHeader('Hub Information', Icons.store_outlined),
              const SizedBox(height: 12),

              _buildCard(
                children: [
                  _buildField(
                    label: 'Hub Name',
                    hint: 'e.g. Hazratganj Hub',
                    controller: vm.hubNameController,
                    icon: Icons.store_outlined,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Hub name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Coverage Radius (KM)',
                    hint: 'e.g. 5.00',
                    controller: vm.coverageRadiusController,
                    icon: Icons.radio_button_unchecked_rounded,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Radius is required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Section: Location ─────────────────────────────────────────
              _sectionHeader('Hub Location', Icons.location_on_outlined),
              const SizedBox(height: 12),

              _buildCard(
                children: [
                  // Map picker button
                  GestureDetector(
                    onTap: () async {
                      // final result = await showDialog(
                      //   context: context,
                      //   builder: (_) => const MapPickerPopup(),
                      // );
                      final zone = Provider.of<CityZoneListViewModel>(context,listen: false).cityZoneDataModel?.data?.firstWhere(
                            (z) => z.status == 1,
                      );
                      final result = await showDialog(
                        context: context,
                        builder: (_) => MapPickerPopup(cityZone: zone),
                      );
                      if (result != null) {
                        vm.locationController.text = result['address'] ?? '';
                        vm.latitudeController.text = result['lat'].toString();
                        vm.longitudeController.text = result['lng'].toString();
                        vm.hubZoneAddress.text = result['address'].toString();
                        vm.pincodeHubZone.text = result['pincode'].toString();
                        vm.coverageRadiusController.text = result['radius']
                            .toString();

                        setState(() => _locationPicked = true);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _locationPicked
                            ? ColorConst.primaryGreen.withValues(alpha:0.07)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _locationPicked
                              ? ColorConst.primaryGreen.withValues(alpha:0.4)
                              : const Color(0xFFE5E7EB),
                          width: _locationPicked ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _locationPicked
                                  ? ColorConst.primaryGreen.withValues(alpha:0.12)
                                  : const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _locationPicked
                                  ? Icons.location_on_rounded
                                  : Icons.add_location_alt_outlined,
                              color: _locationPicked
                                  ? ColorConst.primaryGreen
                                  : const Color(0xFF6B7280),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _locationPicked
                                ? 'Location Selected ✓'
                                : 'Tap to Pick Location on Map',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _locationPicked
                                  ? ColorConst.primaryGreen
                                  : const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _locationPicked
                                ? 'Tap to change location'
                                : 'Pin the hub on the map',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Show address + lat/lng only after picking
                  if (_locationPicked) ...[
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFFF3F4F6), height: 1),
                    const SizedBox(height: 14),

                    // Address (read-only display)
                    if (vm.locationController.text.isNotEmpty)
                      _readOnlyRow(
                        Icons.location_on_outlined,
                        'Address',
                        vm.locationController.text,
                      ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _readOnlyRow(
                            Icons.my_location_rounded,
                            'Latitude',
                            vm.latitudeController.text,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _readOnlyRow(
                            Icons.explore_outlined,
                            'Longitude',
                            vm.longitudeController.text,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // ── Submit button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (!_locationPicked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please pick a location on the map'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      vm.hubZoneCreateApi(context);
                    }
                  },
                  icon: const Icon(
                    Icons.hub_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Create Hub',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConst.primaryGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Hub',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Add a new delivery hub',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
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
          child: Icon(icon, size: 15, color: ColorConst.primaryGreen),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  // ── White card wrapper ──────────────────────────────────────────────────────

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ── Text field ──────────────────────────────────────────────────────────────

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(icon, size: 13, color: const Color(0xFF6B7280)),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: ColorConst.primaryGreen,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Read-only coordinate display ────────────────────────────────────────────

  Widget _readOnlyRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConst.primaryGreen.withValues(alpha:0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: ColorConst.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
