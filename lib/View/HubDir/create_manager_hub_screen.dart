import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/email_validation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/add_hub_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart';


class AddManagerScreen extends StatefulWidget {
  const AddManagerScreen({super.key});

  @override
  State<AddManagerScreen> createState() => _AddManagerScreenState();
}

class _AddManagerScreenState extends State<AddManagerScreen>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  final Set<String> _touched = {};

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    Future.microtask(() {
      if (!mounted) return;
      Provider.of<HubZoneViewModel>(context, listen: false)
          .getHubZoneListDataApi(context);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  bool _isValidEmail(String v) =>
      RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(v);
  bool _isValidPhone(String v) => v.length >= 10;
  bool _isValidPass(String v)  => v.length >= 6;

  void _touch(String key) => setState(() => _touched.add(key));

  // ── image picker bottom sheet ─────────────────────────────────────────────
  void _showImagePickerSheet(AddHubViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImagePickerSheet(
        onCamera:  () { Navigator.pop(context); vm.pickManagerImage(ImageSource.camera);  },
        onGallery: () { Navigator.pop(context); vm.pickManagerImage(ImageSource.gallery); },
      ),
    );
  }

  // ── submit ────────────────────────────────────────────────────────────────
  void _submit(AddHubViewModel vm) {
    setState(() => _touched.addAll(
        ['name','phone','address','aadhar','pan','email','pass']));
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    vm.hubManagerApi(context,vm.selectedHubZoneId.toString(),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Consumer2<HubZoneViewModel, AddHubViewModel>(
          builder: (context, hubVm, addVm, _) {
            return CustomScrollView(
              slivers: [

                // ── AppBar ──────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 56,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  surfaceTintColor: Colors.white,
                  automaticallyImplyLeading: false,
                  title: const Text('Create Manager',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.kTextHead,
                      )),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ColorConst.kAccentLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 7, height: 7,
                            decoration:  BoxDecoration(
                                shape: BoxShape.circle, color: ColorConst.success)),
                        const SizedBox(width: 5),
                        const Text('New',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:ColorConst.kAccent)),
                      ]),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Divider(height: 1, color: ColorConst.kBorder),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Hero + avatar ───────────────────────────────
                        _HeroCard(
                          vm: addVm,
                          onPickImage: () => _showImagePickerSheet(addVm),
                        ),

                        // ════════════════════════════════════════════════
                        // SECTION 1 — Assign Hub
                        // ════════════════════════════════════════════════
                        const _SectionLabel(
                          icon: Icons.hub_rounded,
                          label: 'Assign Hub',
                          subtitle: 'Select the hub this manager will oversee',
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: _HubDropdown(
                            hubVm: hubVm,
                            selectedId: addVm.selectedHubZoneId,
                            isTouched: _touched.contains('hub'),
                            onChanged: (val) {
                              _touch('hub');
                              addVm.setSelectedHubZoneId(val);
                            },
                            validator: (v) =>
                            v == null ? 'Please select a hub' : null,
                          ),
                        ),

                        // ════════════════════════════════════════════════
                        // SECTION 2 — Personal Info
                        // ════════════════════════════════════════════════
                        const _SectionLabel(
                          icon: Icons.person_rounded,
                          label: 'Personal Info',
                          subtitle: 'Manager\'s name and contact details',
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Column(children: [

                            // Full name
                            _FormField(
                              controller: addVm.managerNameController,
                              label: 'Full Name',
                              hint: 'e.g. Rahul Sharma',
                              icon: Icons.badge_rounded,
                              keyboardType: TextInputType.name,
                              isTouched: _touched.contains('name'),
                              isValid: addVm.managerNameController.text.trim().length >= 2,
                              onChanged: (_) => _touch('name'),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Name is required'
                                  : v.trim().length < 2 ? 'Too short' : null,
                            ),

                            const SizedBox(height: 12),

                            // Phone
                            _FormField(
                              controller: addVm.managerContactController,
                              label: 'Phone Number',
                              hint: 'e.g. 9876543210',
                              icon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              isTouched: _touched.contains('phone'),
                              isValid: _isValidPhone(
                                  addVm.managerContactController.text),
                              onChanged: (_) => _touch('phone'),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Phone is required';
                                if (v.length < 10) return 'Enter a valid 10-digit number';
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Address
                            _FormField(
                              controller: addVm.managerAddressController,
                              label: 'Address',
                              hint: 'e.g. 12, MG Road, Lucknow',
                              icon: Icons.location_on_rounded,
                              isTouched: _touched.contains('address'),
                              isValid: addVm.managerAddressController.text.trim().length >= 5,
                              onChanged: (_) => _touch('address'),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Address is required' : null,
                            ),
                          ]),
                        ),

                        // ════════════════════════════════════════════════
                        // SECTION 3 — KYC Documents
                        // ════════════════════════════════════════════════
                        const _SectionLabel(
                          icon: Icons.assignment_ind_rounded,
                          label: 'KYC Documents',
                          subtitle: 'Aadhaar and PAN for identity verification',
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Column(children: [

                            // Aadhaar
                            _FormField(
                              controller: addVm.managerAdharNumber,
                              label: 'Aadhaar Number',
                              hint: 'XXXX XXXX XXXX',
                              icon: Icons.credit_card_rounded,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                                AadhaarInputFormatter(),
                              ],
                              isTouched: _touched.contains('aadhar'),
                              isValid: addVm.managerAdharNumber.text
                                  .replaceAll(' ', '').length == 12,
                              onChanged: (_) => _touch('aadhar'),
                              validator: (v) {
                                final raw = v?.replaceAll(' ', '') ?? '';
                                if (raw.isEmpty) return 'Aadhaar is required';
                                if (raw.length != 12) return 'Must be 12 digits';
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // PAN
                            _FormField(
                              controller: addVm.managerPanNumber,
                              label: 'PAN Number',
                              hint: 'e.g. ABCDE1234F',
                              icon: Icons.article_rounded,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                UpperCaseTextFormatter(),
                              ],
                              isTouched: _touched.contains('pan'),
                              isValid: RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$')
                                  .hasMatch(addVm.managerPanNumber.text),
                              onChanged: (_) => _touch('pan'),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'PAN is required';
                                if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(v)) {
                                  return 'Invalid PAN format';
                                }
                                return null;
                              },
                            ),
                          ]),
                        ),

                        // ════════════════════════════════════════════════
                        // SECTION 4 — Account Credentials
                        // ════════════════════════════════════════════════
                        const _SectionLabel(
                          icon: Icons.lock_rounded,
                          label: 'Hub Account Credentials',
                          subtitle: 'Login email and password for the manager',
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Column(children: [

                            // Email
                            _FormField(
                              controller: addVm.managerEmailController,
                              label: 'Email Address',
                              hint: 'e.g. rahul@example.com',
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              isTouched: _touched.contains('email'),
                              isValid: _isValidEmail(
                                  addVm.managerEmailController.text),
                              onChanged: (_) => _touch('email'),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email is required';
                                if (!_isValidEmail(v)) return 'Enter a valid email';
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Password
                            _PasswordField(
                              controller: addVm.managerPasswordController,
                              obscure: _obscurePass,
                              isTouched: _touched.contains('pass'),
                              isValid: _isValidPass(
                                  addVm.managerPasswordController.text),
                              onToggle: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                              onChanged: (_) => _touch('pass'),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password is required';
                                if (v.length < 6) return 'Minimum 6 characters';
                                return null;
                              },
                            ),

                            // Strength bar
                            if (_touched.contains('pass') &&
                                addVm.managerPasswordController.text.isNotEmpty)
                              _PasswordStrengthBar(
                                  password: addVm.managerPasswordController.text),
                          ]),
                        ),

                        const SizedBox(height: 32),

                        // ── Submit ──────────────────────────────────────
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16, 0, 16,
                            MediaQuery.of(context).padding.bottom + 24,
                          ),
                          child: _SubmitButton(
                            isLoading: addVm.addLoading,
                            onTap: () => _submit(addVm,),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Hero card with avatar picker ────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final AddHubViewModel vm;
  final VoidCallback onPickImage;
  const _HeroCard({required this.vm, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorConst.primaryGreen.withValues(alpha:0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(children: [

        // ── Avatar picker ──────────────────────────────────────────────
        GestureDetector(
          onTap: onPickImage,
          child: Stack(children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.18),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha:0.35), width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: vm.managerImageFile != null
                  ? FutureBuilder(
                future: vm.managerImageFile!.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                },
              )
                  : const Icon(Icons.person_rounded, size: 34, color: Colors.white),
            ),
            // Camera badge
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 4),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    size: 13, color: ColorConst.kAccent),
              ),
            ),
          ]),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('New Hub Manager',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Tap the avatar to upload a\nprofile photo',
              style: TextStyle(
                  color: Colors.white.withValues(alpha:0.75),
                  fontSize: 11,
                  height: 1.5),
            ),
          ]),
        ),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.manage_accounts_rounded,
              size: 22, color: Colors.white),
        ),
      ]),
    );
  }
}

// ─── Image picker bottom sheet ────────────────────────────────────────────────

class _ImagePickerSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  const _ImagePickerSheet(
      {required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: ColorConst.kBorder,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Upload Photo',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorConst.kTextHead)),
        const SizedBox(height: 4),
        const Text('Choose a source for the manager photo',
            style: TextStyle(fontSize: 12, color: ColorConst.kTextMuted)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: _PickerOption(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              color: ColorConst.kAccent,
              onTap: onCamera,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PickerOption(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              color: const Color(0xFF10B981),
              onTap: onGallery,
            ),
          ),
        ]),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:0.2)),
        ),
        child: Column(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ]),
      ),
    );
  }
}

// ─── Hub Dropdown ──────────────────────────────────────────────────────────────

class _HubDropdown extends StatelessWidget {
  final HubZoneViewModel hubVm;
  final String? selectedId;
  final bool isTouched;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String> validator;

  const _HubDropdown({
    required this.hubVm,
    required this.selectedId,
    required this.isTouched,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final zones     = hubVm.hubZones;
    final isLoading = hubVm.isLoading;

    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      validator: validator,
      icon: isLoading
          ? const SizedBox(width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: ColorConst.kAccent))
          : const Icon(Icons.keyboard_arrow_down_rounded, color: ColorConst.kAccent),
      decoration: _fieldDecoration(
        label: 'Select Hub Zone',
        prefixIcon: const Icon(Icons.hub_rounded, size: 18, color: ColorConst.kAccent),
        suffixIcon: isTouched && selectedId != null
            ? const Padding(
            padding: EdgeInsets.only(right: 36),
            child: Icon(Icons.check_circle_rounded, size: 18, color: ColorConst.success))
            : null,
      ),
      hint: Text(isLoading ? 'Loading zones…' : 'Choose a hub zone',
          style: const TextStyle(fontSize: 13, color: ColorConst.kTextMuted)),
      items: zones.map((zone) => DropdownMenuItem<String>(
        value: zone.id.toString(),
        child: Row(children: [
          // Active/inactive dot
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (zone.status == 1 || zone.status == HubZoneStatus.active)
                  ? ColorConst.success
                  : ColorConst.error,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            zone.name?.toString() ?? 'Zone #${zone.id}',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: ColorConst.kTextHead),
          ),
          const SizedBox(width: 6),
          // Radius badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ColorConst.kAccentLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${zone.radiusInKm.toStringAsFixed(0)} km',
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: ColorConst.kAccent),
            ),
          ),
        ]),
      )).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(14),
      menuMaxHeight: 280,
    );
  }
}
// ─── Generic form field ───────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isTouched;
  final bool isValid;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String> validator;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isTouched,
    required this.isValid,
    required this.onChanged,
    required this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: ColorConst.kTextHead),
      decoration: _fieldDecoration(
        label: label,
        hint: hint,
        prefixIcon: Icon(icon, size: 18, color: ColorConst.kAccent),
        suffixIcon: isTouched
            ? Icon(
          isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 18,
          color: isValid ? ColorConst.success : ColorConst.error,
        )
            : null,
        isTouched: isTouched,
        isValid: isValid,
      ),
    );
  }
}

// ─── Password field ───────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final bool isTouched;
  final bool isValid;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String> validator;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.isTouched,
    required this.isValid,
    required this.onToggle,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: ColorConst.kTextHead),
      decoration: _fieldDecoration(
        label: 'Password',
        hint: 'Min. 6 characters',
        prefixIcon: const Icon(Icons.lock_rounded, size: 18, color: ColorConst.kAccent),
        suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
          if (isTouched)
            Icon(
              isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 18,
              color: isValid ? ColorConst.success : ColorConst.error,
            ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 18, color: ColorConst.kTextMuted,
            ),
          ),
        ]),
        isTouched: isTouched,
        isValid: isValid,
      ),
    );
  }
}

// ─── Password strength bar ────────────────────────────────────────────────────

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  int get _score {
    int s = 0;
    if (password.length >= 6)  s++;
    if (password.length >= 10) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  Color get _color {
    if (_score <= 1) return ColorConst.error;
    if (_score <= 3) return ColorConst.kWarning;
    return ColorConst.success;
  }

  String get _label {
    if (_score <= 1) return 'Weak';
    if (_score <= 3) return 'Moderate';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _score / 5,
                minHeight: 4,
                backgroundColor: ColorConst.kBorder,
                color: _color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(_label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: _color)),
        ]),
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Use uppercase, numbers & symbols for a stronger password',
            style: TextStyle(fontSize: 10, color: ColorConst.kTextMuted),
          ),
        ),
      ]),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   subtitle;
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: ColorConst.kAccentLight,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: ColorConst.kAccent),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: ColorConst.kTextHead)),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: ColorConst.kTextMuted)),
        ]),
      ]),
    );
  }
}

// ─── Submit button ────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _SubmitButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConst.kAccent,
          disabledBackgroundColor: ColorConst.kAccent.withValues(alpha:0.55),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.white))
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_rounded, size: 20),
            SizedBox(width: 8),
            Text('Create Manager',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─── Shared field decoration factory ─────────────────────────────────────────

InputDecoration _fieldDecoration({
  required String label,
  String? hint,
  required Widget prefixIcon,
  Widget? suffixIcon,
  bool isTouched = false,
  bool isValid   = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: ColorConst.kTextMuted),
    labelStyle: const TextStyle(
        fontSize: 13, color: ColorConst.kTextMuted, fontWeight: FontWeight.w500),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorConst.kBorder)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isTouched
            ? (isValid ? ColorConst.success.withValues(alpha:0.5) : ColorConst.error.withValues(alpha:0.4))
            : ColorConst.kBorder,
      ),
    ),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorConst.kAccent, width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorConst.error, width: 1.5)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorConst.error, width: 1.5)),
  );
}

