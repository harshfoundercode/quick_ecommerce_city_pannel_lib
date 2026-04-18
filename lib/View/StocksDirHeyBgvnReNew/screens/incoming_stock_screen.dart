import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/admin_incoming_models.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/providers/admin_incomming_stock_list_model.dart';
import '../widgets/app_header.dart';


class AdminIncomingStockScreen extends StatefulWidget {
  const AdminIncomingStockScreen({super.key});

  @override
  State<AdminIncomingStockScreen> createState() => _AdminIncomingStockScreenState();
}

class _AdminIncomingStockScreenState extends State<AdminIncomingStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _sortBy = 'Newest';

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Accepted',
    'Completed',
  ];

  final List<String> _sortOptions = [
    'Newest',
    'Oldest',
    'Quantity: High',
    'Quantity: Low'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final vm = context.read<AdminIncomingStockNewViewModel>();
    vm.getAdminIncomingDataApi(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Admin Incoming Stock',
          subtitle: 'Track incoming stock from hubs',
          actions: [
            IconButton(onPressed: (){
              final vm = context.read<AdminIncomingStockNewViewModel>();
              vm.getAdminIncomingDataApi(context);
            }, icon: Icon(Icons.refresh))
          ],
        ),
        Expanded(
          child: Column(
            children: [
              _buildSearchAndFilters(),
              _buildStatusPills(),
              Expanded(
                child: _IncomingStockContent(
                  searchQuery: _searchController.text,
                  selectedStatus: _selectedStatus,
                  sortBy: _sortBy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: ColorConst.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorConst.borderColor),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: ColorConst.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by product, ID...',
                  hintStyle: const TextStyle(
                    color: ColorConst.textGrey,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: ColorConst.textGrey,
                    size: 18,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: ColorConst.textGrey,
                      size: 16,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Sort Dropdown
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: ColorConst.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorConst.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                icon: const Icon(
                  Icons.sort,
                  color: ColorConst.textGrey,
                  size: 18,
                ),
                style: const TextStyle(
                  color: ColorConst.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                items: _sortOptions
                    .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _sortBy = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPills() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _statusFilters.length,
        separatorBuilder: (_, ii) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final status = _statusFilters[i];
          final isActive = _selectedStatus == status;
          final color = _getStatusColor(status);

          return GestureDetector(
            onTap: () => setState(() => _selectedStatus = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha:0.12) : ColorConst.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? color : ColorConst.borderColor,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? color : ColorConst.textGrey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ColorConst.warning;
      case 'received':
        return ColorConst.success;
      case 'disputed':
        return ColorConst.danger;
      case 'in transit':
        return ColorConst.info;
      default:
        return ColorConst.primaryGreen;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Incoming Stock Content
// ══════════════════════════════════════════════════════════════════════════════
class _IncomingStockContent extends StatelessWidget {
  final String searchQuery;
  final String selectedStatus;
  final String sortBy;

  const _IncomingStockContent({
    required this.searchQuery,
    required this.selectedStatus,
    required this.sortBy,
  });

  String getStatusLabel(dynamic status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Accepted';
      case 2:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  List<AdminIncomingStockData> _filterAndSort(List<AdminIncomingStockData> list) {
    var filtered = list.where((transfer) {
      // Search filter
      final query = searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          transfer.items?.any((item) =>
          '${item.productName}'.toLowerCase().contains(query) ||
              '${item.productid}'.toLowerCase().contains(query) ||
              '${item.brandname}'.toLowerCase().contains(query)) ==
              true;

      // Status filter
      final matchesStatus = selectedStatus == 'All' ||
      getStatusLabel(transfer.status).toLowerCase() ==
      selectedStatus.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();


    // Sorting
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'Oldest':
          return _parseDate('${a.createdAt}').compareTo(_parseDate('${b.createdAt}'));
        case 'Quantity: High':
          return _getTotalQuantity(b).compareTo(_getTotalQuantity(a));
        case 'Quantity: Low':
          return _getTotalQuantity(a).compareTo(_getTotalQuantity(b));
        default: // Newest
          return _parseDate('${b.createdAt}').compareTo(_parseDate('${a.createdAt}'));
      }
    });

    return filtered;
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime(2000);
    }
  }

  int _getTotalQuantity(AdminIncomingStockData transfer) {
    if (transfer.items == null) return 0;

    return transfer.items!.fold<int>(0, (sum, item) {
      if (item.variants == null) return sum;

      return sum + item.variants!.fold<int>(0, (vSum, variant) {
        final qty = variant.quantity;
        if (qty == null) return vSum;
        final parsedQty = qty is int ? qty : int.tryParse(qty.toString()) ?? 0;
        return vSum + parsedQty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminIncomingStockNewViewModel>();

    if (vm.cityStockModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = _filterAndSort(vm.cityStockModel!.data ?? []);

    if (list.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, index) => _TransferCard(transfer: list[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: ColorConst.textGrey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No incoming stock found',
            style: TextStyle(
              color: ColorConst.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Transfer Card
// ══════════════════════════════════════════════════════════════════════════════
class _TransferCard extends StatefulWidget {
  final AdminIncomingStockData transfer;

  const _TransferCard({required this.transfer});

  @override
  State<_TransferCard> createState() => _TransferCardState();
}

class _TransferCardState extends State<_TransferCard> {
  bool _expanded = false;

  int get _totalItems {
    return widget.transfer.items?.length ?? 0;
  }

  int get _totalQuantity {
    final items = widget.transfer.items;
    if (items == null) return 0;

    return items.fold<int>(0, (sum, item) {
      final variants = item.variants;
      if (variants == null) return sum;

      return sum + variants.fold<int>(0, (vSum, variant) {
        final qty = variant.quantity;
        if (qty == null) return vSum;
        final parsedQty = qty is int ? qty : int.tryParse(qty.toString()) ?? 0;
        return vSum + parsedQty;
      });
    });
  }

  int get _totalReceived {
    final items = widget.transfer.items;
    if (items == null) return 0;

    return items.fold<int>(0, (sum, item) {
      final variants = item.variants;
      if (variants == null) return sum;

      return sum + variants.fold<int>(0, (vSum, variant) {
        final qty = variant.receivedQty;
        if (qty == null) return vSum;
        final parsedQty = qty is int ? qty : int.tryParse(qty.toString()) ?? 0;
        return vSum + parsedQty;
      });
    });
  }

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (context) => _AcceptTransferDialog(
        transfer: widget.transfer,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final status = '${widget.transfer.status}';
    final statusColor = _getStatusColor(status);
    final isPending = widget.transfer.status == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConst.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inbox_outlined,
                          color: statusColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Transfer Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Transfer #${widget.transfer.transferId}',
                                  style: const TextStyle(
                                    color: ColorConst.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _StatusBadge(status: getStatusLabel(widget.transfer.status)),
                                if (isPending) ...[
                                  const SizedBox(width: 8),
                                  _AcceptButton(onPressed: _showAcceptDialog),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate('${widget.transfer.createdAt}'),
                              style: const TextStyle(
                                color: ColorConst.textGrey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expand Icon
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: ColorConst.textGrey,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  // Summary Stats
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                        label: 'Items',
                        value: '$_totalItems',
                        icon: Icons.category_outlined,
                      ),
                      _StatChip(
                        label: 'Total Qty',
                        value: '$_totalQuantity',
                        icon: Icons.inventory_2_outlined,
                      ),
                      _StatChip(
                        label: 'Received',
                        value: '$_totalReceived',
                        icon: Icons.check_circle_outline,
                        color: ColorConst.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Remark (if any)
          if (widget.transfer.remark != null && '${widget.transfer.remark}'.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 14,
                    color: ColorConst.textGrey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${widget.transfer.remark}',
                      style: TextStyle(
                        color: ColorConst.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Expanded Items
          if (_expanded && (widget.transfer.items?.isNotEmpty ?? false))
            Container(
              decoration: BoxDecoration(
                color: ColorConst.containerGrey2,
                border: Border(
                  top: BorderSide(color: ColorConst.borderColor),
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Column(
                children: widget.transfer.items!
                    .map((item) => _ProductItemCard(item: item))
                    .toList(),
              ),
            ),

          // Accept Button for Pending (at bottom)
          if (isPending && !_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAcceptDialog,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Accept Transfer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String getStatusLabel(dynamic status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Accepted';
      case 2:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status) {
      case 0:
        return ColorConst.warning;   // Pending
      case 1:
        return ColorConst.success;   // Accepted
      case 2:
        return ColorConst.primaryGreen; // Completed
      default:
        return ColorConst.textGrey;
    }
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 3) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Accept Transfer Dialog
// ══════════════════════════════════════════════════════════════════════════════
class _AcceptTransferDialog extends StatefulWidget {
  final AdminIncomingStockData transfer;

  const _AcceptTransferDialog({
    required this.transfer,
  });

  @override
  State<_AcceptTransferDialog> createState() => _AcceptTransferDialogState();
}

class _AcceptTransferDialogState extends State<_AcceptTransferDialog> {
  final TextEditingController _remarkController = TextEditingController();
  final Map<String, Map<String, dynamic>> _variantData = {};

  @override
  void initState() {
    super.initState();
    _initializeVariantData();
  }

  void _initializeVariantData() {
    for (var item in widget.transfer.items ?? []) {
      for (var variant in item.variants ?? []) {
        final key = '${item.productid}_${variant.variantid}';
        final sentQty = _parseInt(variant.quantity);
        _variantData[key] = {
          'productid': item.productid,
          'variantid': variant.variantid,
          'received_qty': sentQty,
          'missing_qty': 0,
          'dispute_qty': 0,
          'dispute_image': '',
          'maxQty': sentQty,
          'productName': item.productName,
          'variantValue': variant.value,
        };
      }
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    return value is int ? value : int.tryParse(value.toString()) ?? 0;
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }



  // ================= CLOUDINARY UPLOAD =================
  Future<String?> uploadToCloudinaryWeb(Uint8List bytes) async {
    try {
      final url = Uri.parse(ApiUrl.cloudinaryUrl);

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = ApiUrl.preset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: "upload.jpg",
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final jsonData = jsonDecode(resBody);
        return jsonData['secure_url'];
      }
    } catch (e) {
      print("UPLOAD ERROR: $e");
    }

    return null;
  }

  Future<void> _pickDisputeImage(String key) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // ✅ WEB SAFE

      setState(() {
        _variantData[key]!['dispute_image'] = "loading";
      });

      final url = await uploadToCloudinaryWeb(bytes);

      if (url != null) {
        setState(() {
          _variantData[key]!['dispute_image'] = url;
        });
      } else {
        setState(() {
          _variantData[key]!['dispute_image'] = '';
        });
      }
    }
  }


  bool canIncrease(int received, int dispute, int maxQty) {
    return (received + dispute) < maxQty;
  }

  void updateMissing(Map data) {
    data['missing_qty'] =
        data['maxQty'] - (data['received_qty'] + data['dispute_qty']);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminIncomingStockNewViewModel>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorConst.primaryGreen.withValues(alpha:0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: ColorConst.borderColor),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorConst.primaryGreen.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: ColorConst.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accept Transfer',
                          style: TextStyle(
                            color: ColorConst.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Transfer #${widget.transfer.transferId}',
                          style: TextStyle(
                            color: ColorConst.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: ColorConst.textGrey, size: 20),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Remark Field
                    Text(
                      'Remark (Optional)',
                      style: TextStyle(
                        color: ColorConst.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _remarkController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Add any remarks about this transfer...',
                        hintStyle: TextStyle(color: ColorConst.textGrey, fontSize: 13),
                        filled: true,
                        fillColor: ColorConst.containerGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Items and Variants
                    Text(
                      'Confirm Received Quantities',
                      style: TextStyle(
                        color: ColorConst.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...widget.transfer.items!.map((item) {
                      return _buildItemSection(item);
                    }),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: ColorConst.borderColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: ColorConst.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: ColorConst.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: vm.loading ? null : () => _submitTransfer(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConst.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: vm.loading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Accept Transfer',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemSection(Items item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ColorConst.primaryGreen.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.productImage != null && '${item.productImage}'.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${item.productImage}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, ii, iii) => Icon(
                      Icons.inventory_2_outlined,
                      color: ColorConst.primaryGreen,
                      size: 18,
                    ),
                  ),
                )
                    : Icon(
                  Icons.inventory_2_outlined,
                  color: ColorConst.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${item.productName}',
                  style: TextStyle(
                    color: ColorConst.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...item.variants!.map((variant) {
            return _buildVariantRow(item, variant);
          }),
        ],
      ),
    );
  }

  // Widget _buildVariantRow(Items item, Variants variant) {
  //   final key = '${item.productid}_${variant.variantid}';
  //   final data = _variantData[key]!;
  //   final maxQty = data['maxQty'] as int;
  //   final receivedQty = data['received_qty'] as int;
  //   final missingQty = data['missing_qty'] as int;
  //
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 8),
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: ColorConst.white,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: ColorConst.borderColor),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Text(
  //                 '${variant.value}',
  //                 style: TextStyle(
  //                   color: ColorConst.textPrimary,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //               decoration: BoxDecoration(
  //                 color: ColorConst.info.withValues(alpha:0.1),
  //                 borderRadius: BorderRadius.circular(6),
  //               ),
  //               child: Text(
  //                 'Sent: $maxQty',
  //                 style: TextStyle(
  //                   color: ColorConst.info,
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         Row(
  //           children: [
  //             // Received Quantity
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Received',
  //                     style: TextStyle(
  //                       color: ColorConst.textGrey,
  //                       fontSize: 10,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Container(
  //                     height: 36,
  //                     decoration: BoxDecoration(
  //                       color: ColorConst.containerGrey,
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         IconButton(
  //                           onPressed: receivedQty > 0
  //                               ? () {
  //                             setState(() {
  //                               data['received_qty'] = receivedQty - 1;
  //                               data['missing_qty'] = maxQty - (receivedQty - 1);
  //                             });
  //                           }
  //                               : null,
  //                           icon: const Icon(Icons.remove, size: 16),
  //                           padding: EdgeInsets.zero,
  //                           constraints: const BoxConstraints(minWidth: 32),
  //                         ),
  //                         Expanded(
  //                           child: Text(
  //                             '$receivedQty',
  //                             textAlign: TextAlign.center,
  //                             style: TextStyle(
  //                               color: ColorConst.success,
  //                               fontSize: 13,
  //                               fontWeight: FontWeight.w700,
  //                             ),
  //                           ),
  //                         ),
  //                         IconButton(
  //                           onPressed: receivedQty < maxQty
  //                               ? () {
  //                             setState(() {
  //                               data['received_qty'] = receivedQty + 1;
  //                               data['missing_qty'] = maxQty - (receivedQty + 1);
  //                             });
  //                           }
  //                               : null,
  //                           icon: const Icon(Icons.add, size: 16),
  //                           padding: EdgeInsets.zero,
  //                           constraints: const BoxConstraints(minWidth: 32),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             // Missing Quantity
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Missing',
  //                     style: TextStyle(
  //                       color: ColorConst.textGrey,
  //                       fontSize: 10,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Container(
  //                     height: 36,
  //                     decoration: BoxDecoration(
  //                       color: ColorConst.containerGrey,
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     alignment: Alignment.center,
  //                     child: Text(
  //                       '$missingQty',
  //                       style: TextStyle(
  //                         color: missingQty > 0 ? ColorConst.danger : ColorConst.textGrey,
  //                         fontSize: 13,
  //                         fontWeight: FontWeight.w700,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildVariantRow(Items item, Variants variant) {
    final key = '${item.productid}_${variant.variantid}';
    final data = _variantData[key]!;

    final maxQty = data['maxQty'] as int;
    final receivedQty = data['received_qty'] as int;
    final missingQty = data['missing_qty'] as int;
    final disputeQty = data['dispute_qty'] as int;
    final imageUrl = data['dispute_image'];

    void updateMissing() {
      data['missing_qty'] =
          maxQty - (data['received_qty'] + data['dispute_qty']);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  '${variant.value}',
                  style: TextStyle(
                    color: ColorConst.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('Sent: $maxQty'),
            ],
          ),

          const SizedBox(height: 10),

          // QUANTITY ROW
          Row(
            children: [

              /// RECEIVED
              Expanded(
                child: _qtyBox(
                  label: "Received",
                  value: receivedQty,
                  color: ColorConst.success,
                  onMinus: receivedQty > 0
                      ? () {
                    setState(() {
                      data['received_qty']--;
                      updateMissing();
                    });
                  }
                      : null,
                  onPlus: (receivedQty + disputeQty) < maxQty
                      ? () {
                    setState(() {
                      data['received_qty']++;
                      updateMissing();
                    });
                  }
                      : null,
                ),
              ),

              const SizedBox(width: 6),

              /// DEFECTIVE
              Expanded(
                child: _qtyBox(
                  label: "Defective",
                  value: disputeQty,
                  color: ColorConst.warning,
                  onMinus: disputeQty > 0
                      ? () {
                    setState(() {
                      data['dispute_qty']--;
                      updateMissing();
                    });
                  }
                      : null,
                  onPlus: (receivedQty + disputeQty) < maxQty
                      ? () {
                    setState(() {
                      data['dispute_qty']++;
                      updateMissing();
                    });
                  }
                      : null,
                ),
              ),

              const SizedBox(width: 6),

              /// MISSING
              Expanded(
                child: Column(
                  children: [
                    Text("Missing"),
                    Text(
                      '$missingQty',
                      style: TextStyle(
                        color: missingQty > 0
                            ? ColorConst.danger
                            : ColorConst.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// 🔥 IMAGE UPLOAD (IMPORTANT FIX)
          if (disputeQty > 0)
            GestureDetector(
              onTap: () => _pickDisputeImage(key),
              child: Container(
                height: Sizes.screenHeight*0.3,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorConst.borderColor),
                ),
                child: imageUrl == "loading"
                    ? const Center(child: CircularProgressIndicator())
                    : imageUrl != null && imageUrl != ''
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                )
                    : const Center(child: Text("Upload Image")),
              ),
            ),
        ],
      ),
    );
  }

  Widget _qtyBox({
    required String label,
    required int value,
    required Color color,
    VoidCallback? onMinus,
    VoidCallback? onPlus,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onMinus,
              icon: const Icon(Icons.remove, size: 16),
            ),
            Text('$value',
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: onPlus,
              icon: const Icon(Icons.add, size: 16),
            ),
          ],
        ),
      ],
    );
  }

  void _submitTransfer(BuildContext context) {
    for (var data in _variantData.values) {
      final max = data['maxQty'];
      final total = data['received_qty'] +
          data['dispute_qty'] +
          data['missing_qty'];

      // ❌ quantity mismatch
      if (total != max) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Quantity mismatch")),
        );
        return;
      }

      // ❌ defective but no image
      if (data['dispute_qty'] > 0 &&
          (data['dispute_image'] == null ||
              data['dispute_image'] == '')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload defective image")),
        );
        return;
      }
    }

    final vm = context.read<AdminIncomingStockNewViewModel>();

    final items = _variantData.values.map((data) {
      return {
        "productid": data['productid'],
        "variantid": data['variantid'],
        "received_qty": data['received_qty'],
        "missing_qty": data['missing_qty'],
        "dispute_qty": data['dispute_qty'],
        "dispute_image": data['dispute_image'],
      };
    }).toList();

    vm.acceptAdminTransferApi(
      context: context,
      transferId: '${widget.transfer.transferId}',
      remark: _remarkController.text.trim(),
      items: items,
      onSuccess: () {
        Navigator.pop(context);
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Product Item Card
// ══════════════════════════════════════════════════════════════════════════════
class _ProductItemCard extends StatelessWidget {
  final Items item;

  const _ProductItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorConst.borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Header
          Row(
            children: [
              // Product Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ColorConst.primaryGreen.withValues(alpha:0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: item.productImage != null && '${item.productImage}'.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    '${item.productImage}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, ii, iii) => _buildPlaceholder(),
                  ),
                )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.productName}',
                      style: const TextStyle(
                        color: ColorConst.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.brandname != null)
                          _InfoTag(
                            label: '${item.brandname}',
                            color: ColorConst.info,
                          ),
                        if (item.mainCategory != null)
                          _InfoTag(
                            label: '${item.mainCategory}',
                            color: ColorConst.textGrey,
                          ),
                        if (item.gstPercent != null)
                          _InfoTag(
                            label: 'GST: ${item.gstPercent}%',
                            color: ColorConst.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Variants
          if (item.variants != null && item.variants!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: ColorConst.borderColor),
            const SizedBox(height: 10),
            ...item.variants!.map((variant) => _VariantRow(variant: variant)),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.inventory_2_outlined,
      color: ColorConst.primaryGreen,
      size: 22,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Variant Row
// ══════════════════════════════════════════════════════════════════════════════
class _VariantRow extends StatelessWidget {
  final Variants variant;

  const _VariantRow({required this.variant});

  @override
  Widget build(BuildContext context) {
    final sentQty = _parseInt(variant.quantity);
    final receivedQty = _parseInt(variant.receivedQty);
    final missingQty = _parseInt(variant.missingQty);
    final disputeQty = _parseInt(variant.disputeQty);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Variant Value
              Expanded(
                child: Text(
                  '${variant.value}',
                  style: const TextStyle(
                    color: ColorConst.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Price
              if (variant.discountPrice != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${variant.price}',
                      style: TextStyle(
                        color: ColorConst.textGrey,
                        fontSize: 10,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '₹${variant.discountPrice}',
                      style: const TextStyle(
                        color: ColorConst.primaryGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              else if (variant.price != null)
                Text(
                  '₹${variant.price}',
                  style: const TextStyle(
                    color: ColorConst.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Quantity Pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _QtyPill(
                label: 'Sent',
                value: sentQty,
                color: ColorConst.info,
              ),
              _QtyPill(
                label: 'Received',
                value: receivedQty,
                color: ColorConst.success,
              ),
              if (missingQty > 0)
                _QtyPill(
                  label: 'Missing',
                  value: missingQty,
                  color: ColorConst.danger,
                ),
              if (disputeQty > 0)
                _QtyPill(
                  label: 'Dispute',
                  value: disputeQty,
                  color: ColorConst.warning,
                ),
            ],
          ),

          // // Status (if any)
          // if (variant.status != null && '${variant.status}'.isNotEmpty) ...[
          //   const SizedBox(height: 8),
          //   Row(
          //     children: [
          //       Icon(
          //         Icons.circle,
          //         size: 8,
          //         color: _getVariantStatusColor('${variant.status}'),
          //       ),
          //       const SizedBox(width: 4),
          //       Text(
          //         '${variant.status}',
          //         style: TextStyle(
          //           color: ColorConst.textGrey,
          //           fontSize: 10,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ],
          //   ),
          // ],
        ],
      ),
    );
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    return value is int ? value : int.tryParse(value.toString()) ?? 0;
  }

}

// ══════════════════════════════════════════════════════════════════════════════
// Shared Widgets
// ══════════════════════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ColorConst.warning;
      case 'received':
        return ColorConst.success;
      case 'disputed':
        return ColorConst.danger;
      case 'in_transit':
        return ColorConst.info;
      default:
        return ColorConst.textGrey;
    }
  }
}

class _AcceptButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AcceptButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.check_circle, size: 14, color: ColorConst.success),
      label: Text(
        'Accept',
        style: TextStyle(
          color: ColorConst.success,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        backgroundColor: ColorConst.success.withValues(alpha:0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? ColorConst.info;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withValues(alpha:0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: chipColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: chipColor.withValues(alpha:0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoTag({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _QtyPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha:0.7),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}