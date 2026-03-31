import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/DisputeProducts/complaint_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/DisputeProducts/complaint_view_model.dart';


class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<ComplaintViewModel>(context, listen: false);
      vm.loadDemoData();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _buildSliverAppBar(),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: const [
            _SubmitComplaintTab(),
            _ComplaintHistoryTab(),
          ],
        ),
      ),
    );
  }

  // ── SliverAppBar ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: const Color(0xFFDC2626),
      automaticallyImplyLeading: false,
      actions: [
        Consumer<ComplaintViewModel>(
          builder: (context, vm, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {},
            tooltip: 'Refresh',
          ),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 72, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.report_problem_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complaint Center',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Report delivery issues to admin',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: const Color(0xFFDC2626),
            unselectedLabelColor: const Color(0xFF9CA3AF),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: const Color(0xFFDC2626),
            indicatorWeight: 2.5,
            tabs: const [
              Tab(
                icon: Icon(Icons.add_circle_outline_rounded, size: 18),
                text: 'New Complaint',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.history_rounded, size: 18),
                text: 'History',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Submit Complaint
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitComplaintTab extends StatefulWidget {
  const _SubmitComplaintTab();

  @override
  State<_SubmitComplaintTab> createState() => _SubmitComplaintTabState();
}

class _SubmitComplaintTabState extends State<_SubmitComplaintTab> {
  // Controllers
  final _productCtrl = TextEditingController();
  final _requestIdCtrl = TextEditingController();
  final _orderedCtrl = TextEditingController();
  final _receivedCtrl = TextEditingController();
  final _damagedCtrl = TextEditingController();
  final _missingCtrl = TextEditingController();
  final _wrongCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // State
  String _complaintType = 'damaged'; // damaged | missing | wrong | quality
  File? _photo;
  final _picker = ImagePicker();

  final _complaintTypes = [
    _ComplaintType(
      id: 'damaged',
      label: 'Damaged',
      icon: Icons.broken_image_rounded,
      color: const Color(0xFFEF4444),
      desc: 'Items received in broken/damaged condition',
    ),
    _ComplaintType(
      id: 'missing',
      label: 'Missing',
      icon: Icons.remove_shopping_cart_rounded,
      color: const Color(0xFFF59E0B),
      desc: 'Items missing from shipment',
    ),
    _ComplaintType(
      id: 'wrong',
      label: 'Wrong Item',
      icon: Icons.swap_horiz_rounded,
      color: const Color(0xFF8B5CF6),
      desc: 'Received different product',
    ),
    _ComplaintType(
      id: 'quality',
      label: 'Quality Issue',
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFEA580C),
      desc: 'Product quality not acceptable',
    ),
  ];

  @override
  void dispose() {
    _productCtrl.dispose();
    _requestIdCtrl.dispose();
    _orderedCtrl.dispose();
    _receivedCtrl.dispose();
    _damagedCtrl.dispose();
    _missingCtrl.dispose();
    _wrongCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1200,
    );
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Upload Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _photoOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFFDC2626),
                    onTap: () {
                      Navigator.pop(context);
                      _pickPhoto(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _photoOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: const Color(0xFF7C3AED),
                    onTap: () {
                      Navigator.pop(context);
                      _pickPhoto(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    // Validation
    if (_productCtrl.text.trim().isEmpty) {
      _showError('Product name is required');
      return;
    }
    if (_requestIdCtrl.text.trim().isEmpty) {
      _showError('Stock Request ID is required');
      return;
    }
    if (_orderedCtrl.text.trim().isEmpty || _receivedCtrl.text.trim().isEmpty) {
      _showError('Ordered and received quantity are required');
      return;
    }
    if (_complaintType == 'damaged' && _damagedCtrl.text.trim().isEmpty) {
      _showError('Enter damaged quantity');
      return;
    }
    if (_complaintType == 'missing' && _missingCtrl.text.trim().isEmpty) {
      _showError('Enter missing quantity');
      return;
    }
    if (_complaintType == 'wrong' && _wrongCtrl.text.trim().isEmpty) {
      _showError('Enter wrong item quantity');
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      _showError('Please describe the issue');
      return;
    }

    // final vm = Provider.of<ComplaintViewModel>(context, listen: false);
    // final success = await vm.submitComplaintApi(
    //   context: context,
    //   stockRequestId: int.tryParse(_requestIdCtrl.text) ?? 0,
    //   productName: _productCtrl.text.trim(),
    //   orderedQty: int.tryParse(_orderedCtrl.text) ?? 0,
    //   receivedQty: int.tryParse(_receivedCtrl.text) ?? 0,
    //   complaintType: _complaintType,
    //   damagedQty: int.tryParse(_damagedCtrl.text),
    //   missingQty: int.tryParse(_missingCtrl.text),
    //   wrongQty: int.tryParse(_wrongCtrl.text),
    //   description: _descCtrl.text.trim(),
    //   photo: _photo,
    // );
    //
    // if (success) _clearForm();
  }

  void _clearForm() {
    _productCtrl.clear();
    _requestIdCtrl.clear();
    _orderedCtrl.clear();
    _receivedCtrl.clear();
    _damagedCtrl.clear();
    _missingCtrl.clear();
    _wrongCtrl.clear();
    _descCtrl.clear();
    setState(() => _photo = null);
  }

  void _showError(String msg) {
    CustomSnackBar.show(context, message: msg, type: SnackBarType.error);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintViewModel>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info banner ──────────────────────────────────────
              _buildInfoBanner(),
              const SizedBox(height: 20),

              // ── Section: Order details ───────────────────────────
              _sectionLabel('Order Details', Icons.receipt_long_rounded),
              const SizedBox(height: 12),
              _buildOrderDetailsCard(),
              const SizedBox(height: 20),

              // ── Section: Complaint type ──────────────────────────
              _sectionLabel('Complaint Type', Icons.report_problem_rounded),
              const SizedBox(height: 12),
              _buildComplaintTypeGrid(),
              const SizedBox(height: 20),

              // ── Section: Quantity details ────────────────────────
              _sectionLabel('Quantity Details', Icons.numbers_rounded),
              const SizedBox(height: 12),
              _buildQuantityCard(),
              const SizedBox(height: 20),

              // ── Section: Photo evidence ──────────────────────────
              _sectionLabel(
                  'Photo Evidence', Icons.camera_alt_rounded,
                  subtitle: 'Optional but recommended'),
              const SizedBox(height: 12),
              _buildPhotoCard(),
              const SizedBox(height: 20),

              // ── Section: Description ─────────────────────────────
              _sectionLabel('Describe the Issue', Icons.description_rounded),
              const SizedBox(height: 12),
              _buildDescriptionCard(),
              const SizedBox(height: 28),

              // ── Submit button ────────────────────────────────────
              _buildSubmitButton(vm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_rounded,
                color: Color(0xFFD97706), size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'File a complaint for your last delivery',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Admin will review and respond within 24 hours.',
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _inputField(
                  ctrl: _productCtrl,
                  label: 'Product Name',
                  hint: 'e.g. Cold Drink 250ml',
                  icon: Icons.inventory_2_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  ctrl: _requestIdCtrl,
                  label: 'Request ID',
                  hint: 'e.g. 101',
                  icon: Icons.tag_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  ctrl: _orderedCtrl,
                  label: 'Ordered Qty',
                  hint: 'e.g. 400',
                  icon: Icons.add_shopping_cart_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  ctrl: _receivedCtrl,
                  label: 'Received Qty',
                  hint: 'e.g. 380',
                  icon: Icons.shopping_bag_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          // Live difference indicator
          if (_orderedCtrl.text.isNotEmpty &&
              _receivedCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Builder(builder: (_) {
              final ordered = int.tryParse(_orderedCtrl.text) ?? 0;
              final received = int.tryParse(_receivedCtrl.text) ?? 0;
              final diff = ordered - received;
              if (diff <= 0) return const SizedBox();
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.difference_rounded,
                        size: 14, color: Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                    Text(
                      '$diff units difference detected',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildComplaintTypeGrid() {
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 4,
      children: _complaintTypes.map((type) {
        final isSelected = _complaintType == type.id;
        return GestureDetector(
          onTap: () => setState(() => _complaintType = type.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? type.color.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? type.color
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: type.color.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(type.icon, color: type.color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? type.color
                              : const Color(0xFF374151),
                        ),
                      ),
                      Text(
                        type.desc,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected
                              ? type.color.withValues(alpha: 0.8)
                              : const Color(0xFF9CA3AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded,
                      color: type.color, size: 16),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantityCard() {
    return _card(
      child: Column(
        children: [
          if (_complaintType == 'damaged') ...[
            _inputField(
              ctrl: _damagedCtrl,
              label: 'Damaged Quantity',
              hint: 'How many items were damaged?',
              icon: Icons.broken_image_rounded,
              iconColor: const Color(0xFFEF4444),
              keyboardType: TextInputType.number,
            ),
          ],
          if (_complaintType == 'missing') ...[
            _inputField(
              ctrl: _missingCtrl,
              label: 'Missing Quantity',
              hint: 'How many items are missing?',
              icon: Icons.remove_shopping_cart_rounded,
              iconColor: const Color(0xFFF59E0B),
              keyboardType: TextInputType.number,
            ),
          ],
          if (_complaintType == 'wrong') ...[
            _inputField(
              ctrl: _wrongCtrl,
              label: 'Wrong Item Quantity',
              hint: 'How many wrong items received?',
              icon: Icons.swap_horiz_rounded,
              iconColor: const Color(0xFF8B5CF6),
              keyboardType: TextInputType.number,
            ),
          ],
          if (_complaintType == 'quality') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFFD97706)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For quality issues, please describe the problem in detail below.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return _card(
      child: Column(
        children: [
          if (_photo == null)
            GestureDetector(
              onTap: _showPhotoOptions,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_photo_alternate_rounded,
                          color: Color(0xFFDC2626), size: 28),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap to add photo evidence',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Camera or Gallery • Max 5MB',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            )
          else
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _photo!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _photoActionBtn(
                        icon: Icons.edit_rounded,
                        onTap: _showPhotoOptions,
                        color: Colors.white,
                        bg: const Color(0xFF374151),
                      ),
                      const SizedBox(width: 6),
                      _photoActionBtn(
                        icon: Icons.delete_rounded,
                        onTap: () => setState(() => _photo = null),
                        color: Colors.white,
                        bg: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 12),
                        SizedBox(width: 5),
                        Text('Photo added',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _photoActionBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color bg,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _card(
      child: TextField(
        controller: _descCtrl,
        maxLines: 4,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
        decoration: InputDecoration(
          hintText:
          'Describe the issue in detail...\ne.g. 20 bottles of Cold Drink were missing from the delivery. The package was sealed but count was short.',
          hintStyle:
          const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFFDC2626), width: 1.5),
          ),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ComplaintViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: vm.submitLoading ? null : _submit,
        icon: vm.submitLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
        label: Text(
          vm.submitLoading ? 'Submitting...' : 'Submit Complaint',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          disabledBackgroundColor:
          const Color(0xFFDC2626).withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String label, IconData icon, {String? subtitle}) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: const Color(0xFFDC2626)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _inputField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    Color? iconColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(icon,
                size: 16,
                color: iconColor ?? const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
              borderSide: const BorderSide(
                  color: Color(0xFFDC2626), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — Complaint History
// ─────────────────────────────────────────────────────────────────────────────

class _ComplaintHistoryTab extends StatelessWidget {
  const _ComplaintHistoryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintViewModel>(
      builder: (context, vm, _) {
        if (vm.listLoading) {
          return const Center(
            child: CircularProgressIndicator(
                color: Color(0xFFDC2626), strokeWidth: 2),
          );
        }

        return Column(
          children: [
            // Filter chips
            _buildFilterBar(context, vm),

            // List
            Expanded(
              child: vm.filteredComplaints.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: vm.filteredComplaints.length,
                itemBuilder: (context, i) {
                  return _ComplaintHistoryCard(
                    complaint: vm.filteredComplaints[i],
                    index: i,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(BuildContext context, ComplaintViewModel vm) {
    final filters = [
      ('all', 'All', Colors.grey.shade700),
      ('pending', 'Pending', const Color(0xFFF59E0B)),
      ('under_review', 'Under Review', const Color(0xFF2563EB)),
      ('resolved', 'Resolved', const Color(0xFF10B981)),
      ('rejected', 'Rejected', const Color(0xFFEF4444)),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = filters[i];
            final isSelected = vm.statusFilter == f.$1;
            return GestureDetector(
              onTap: () => vm.setStatusFilter(f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? f.$3 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? f.$3 : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: f.$3.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                      : [],
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                    isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_outlined,
                size: 44,
                color:
                const Color(0xFFDC2626).withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 14),
          const Text('No complaints found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151))),
          const SizedBox(height: 6),
          Text('Switch filter or submit a new complaint',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ── Complaint History Card ────────────────────────────────────────────────────

class _ComplaintHistoryCard extends StatelessWidget {
  final ComplaintData complaint;
  final int index;
  const _ComplaintHistoryCard(
      {required this.complaint, required this.index});

  Color get _statusColor {
    switch (complaint.status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'under_review':
        return const Color(0xFF2563EB);
      case 'resolved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (complaint.status) {
      case 'pending':
        return 'Pending';
      case 'under_review':
        return 'Under Review';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  IconData get _statusIcon {
    switch (complaint.status) {
      case 'pending':
        return Icons.access_time_rounded;
      case 'under_review':
        return Icons.manage_search_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }


  Color get _typeColor {
    switch (complaint.complaintType) {
      case 'damaged':
        return const Color(0xFFEF4444);
      case 'missing':
        return const Color(0xFFF59E0B);
      case 'wrong':
        return const Color(0xFF8B5CF6);
      case 'quality':
        return const Color(0xFFEA580C);
      default:
        return Colors.grey;
    }
  }

  IconData get _typeIcon {
    switch (complaint.complaintType) {
      case 'damaged':
        return Icons.broken_image_rounded;
      case 'missing':
        return Icons.remove_shopping_cart_rounded;
      case 'wrong':
        return Icons.swap_horiz_rounded;
      case 'quality':
        return Icons.warning_amber_rounded;
      default:
        return Icons.report_problem_rounded;
    }
  }

  String get _typeLabel {
    switch (complaint.complaintType) {
      case 'damaged':
        return 'Damaged';
      case 'missing':
        return 'Missing';
      case 'wrong':
        return 'Wrong Item';
      case 'quality':
        return 'Quality Issue';
      default:
        return 'Other';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _statusColor.withValues(alpha: 0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top row ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_typeIcon, color: _typeColor, size: 20),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name + complaint ID
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                complaint.productName ?? 'Unknown Product',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '#${complaint.id}',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Type chip + Status badge
                        Row(
                          children: [
                            _miniChip(
                                _typeLabel, _typeColor, _typeIcon),
                            const SizedBox(width: 6),
                            _statusBadge(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade100),

            // ── Stats row ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  _statCell('Ordered',
                      '${complaint.orderedQty ?? 0}', const Color(0xFF2563EB)),
                  _vDiv(),
                  _statCell('Received',
                      '${complaint.receivedQty ?? 0}', const Color(0xFF10B981)),
                  _vDiv(),
                  if (complaint.complaintType == 'damaged')
                    _statCell('Damaged',
                        '${complaint.damagedQty ?? 0}', const Color(0xFFEF4444)),
                  if (complaint.complaintType == 'missing')
                    _statCell('Missing',
                        '${complaint.missingQty ?? 0}', const Color(0xFFF59E0B)),
                  if (complaint.complaintType == 'wrong')
                    _statCell('Wrong',
                        '${complaint.wrongQty ?? 0}', const Color(0xFF8B5CF6)),
                  if (complaint.complaintType == 'quality')
                    _statCell('Quality', 'Issue', const Color(0xFFEA580C)),
                  _vDiv(),
                  Expanded(
                    child: Text(
                      _formatDate(complaint.createdAt),
                      style: const TextStyle(
                          fontSize: 9, color: Color(0xFF9CA3AF)),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // ── Admin response (if any) ───────────────────────────
            if (complaint.adminResponse != null &&
                complaint.adminResponse!.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: _statusColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.admin_panel_settings_rounded,
                        size: 14, color: _statusColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Response',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _statusColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            complaint.adminResponse!,
                            style: TextStyle(
                              fontSize: 11,
                              color: _statusColor.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ── View details hint ─────────────────────────────────
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16)),
                border: Border(
                    top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.expand_more_rounded,
                      size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to view full details',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ctrl) => _ComplaintDetailSheet(
            complaint: complaint, scrollController: ctrl),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon, size: 10, color: _statusColor),
          const SizedBox(width: 4),
          Text(
            _statusLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 9, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _vDiv() => Container(
    width: 1,
    height: 28,
    color: const Color(0xFFF3F4F6),
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );
}

// ── Complaint Detail Bottom Sheet ─────────────────────────────────────────────

class _ComplaintDetailSheet extends StatelessWidget {
  final ComplaintData complaint;
  final ScrollController scrollController;

  const _ComplaintDetailSheet({
    required this.complaint,
    required this.scrollController,
  });

  Color get _statusColor {
    switch (complaint.status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'under_review':
        return const Color(0xFF2563EB);
      case 'resolved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? d) {
    if (d == null) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // ── Header ──────────────────────────────────────────
                _detailCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              complaint.productName ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              complaint.status == 'under_review'
                                  ? 'Under Review'
                                  : (complaint.status ?? 'Unknown')
                                  .replaceFirst(
                                  complaint.status![0],
                                  complaint.status![0]
                                      .toUpperCase()),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Complaint #${complaint.id} • Req #${complaint.stockRequestId}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(complaint.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Quantity breakdown ───────────────────────────────
                _detailCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sheetLabel('Quantity Breakdown'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _bigStat('${complaint.orderedQty ?? 0}',
                              'Ordered', const Color(0xFF2563EB)),
                          const SizedBox(width: 10),
                          _bigStat('${complaint.receivedQty ?? 0}',
                              'Received', const Color(0xFF10B981)),
                          const SizedBox(width: 10),
                          if (complaint.damagedQty != null)
                            _bigStat('${complaint.damagedQty}',
                                'Damaged', const Color(0xFFEF4444)),
                          if (complaint.missingQty != null)
                            _bigStat('${complaint.missingQty}',
                                'Missing', const Color(0xFFF59E0B)),
                          if (complaint.wrongQty != null)
                            _bigStat('${complaint.wrongQty}',
                                'Wrong', const Color(0xFF8B5CF6)),
                          if (complaint.complaintType == 'quality')
                            _bigStat('!', 'Quality', const Color(0xFFEA580C)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Description ──────────────────────────────────────
                _detailCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sheetLabel('Description'),
                      const SizedBox(height: 10),
                      Text(
                        complaint.description ?? 'No description provided.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF374151),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Photo evidence ───────────────────────────────────
                if (complaint.photoUrl != null) ...[
                  const SizedBox(height: 12),
                  _detailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sheetLabel('Photo Evidence'),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            complaint.photoUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              color: const Color(0xFFF3F4F6),
                              child: const Center(
                                child: Icon(Icons.broken_image_rounded,
                                    color: Color(0xFF9CA3AF), size: 40),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Timeline / Status track ──────────────────────────
                const SizedBox(height: 12),
                _detailCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sheetLabel('Status Timeline'),
                      const SizedBox(height: 14),
                      _timelineItem(
                        label: 'Complaint Submitted',
                        subtitle: _formatDate(complaint.createdAt),
                        color: const Color(0xFF10B981),
                        icon: Icons.check_circle_rounded,
                        isDone: true,
                        isLast: false,
                      ),
                      _timelineItem(
                        label: 'Under Admin Review',
                        subtitle: complaint.status == 'pending'
                            ? 'Awaiting review'
                            : 'In progress',
                        color: const Color(0xFF2563EB),
                        icon: Icons.manage_search_rounded,
                        isDone: complaint.status != 'pending',
                        isLast: false,
                      ),
                      _timelineItem(
                        label: complaint.status == 'rejected'
                            ? 'Complaint Rejected'
                            : 'Issue Resolved',
                        subtitle: complaint.status == 'resolved' ||
                            complaint.status == 'rejected'
                            ? _formatDate(complaint.updatedAt)
                            : 'Pending',
                        color: complaint.status == 'rejected'
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        icon: complaint.status == 'rejected'
                            ? Icons.cancel_rounded
                            : Icons.check_circle_rounded,
                        isDone: complaint.status == 'resolved' ||
                            complaint.status == 'rejected',
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                // ── Admin response ───────────────────────────────────
                if (complaint.adminResponse != null &&
                    complaint.adminResponse!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _statusColor.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings_rounded,
                                size: 16, color: _statusColor),
                            const SizedBox(width: 8),
                            Text(
                              'Admin Response',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          complaint.adminResponse!,
                          style: TextStyle(
                            fontSize: 13,
                            color: _statusColor.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sheetLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _bigStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem({
    required String label,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool isDone,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? color : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? icon : Icons.circle_outlined,
                size: 14,
                color: isDone ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isDone ? color.withValues(alpha: 0.3) : const Color(0xFFF3F4F6),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDone ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _ComplaintType {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String desc;

  const _ComplaintType({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.desc,
  });
}