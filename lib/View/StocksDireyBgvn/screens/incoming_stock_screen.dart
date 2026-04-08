import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';
import '../widgets/app_header.dart';

class IncomingStockScreen extends StatelessWidget {
  const IncomingStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = context.watch<StockProvider>().incomingStocks;

    return Column(
      children: [
        const AppHeader(title: 'Incoming Stock', subtitle: 'Awaiting deliveries'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stocks.length,
            itemBuilder: (_, i) => _IncomingShipmentCard(shipment: stocks[i]),
          ),
        ),
      ],
    );
  }
}

class _IncomingShipmentCard extends StatelessWidget {
  final IncomingStock shipment;

  const _IncomingShipmentCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(shipment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          // Shipment Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusInfo['color'].withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_shipping, color: statusInfo['color'], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shipment.supplierName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white38, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(shipment.expectedDate),
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusInfo['color'].withOpacity(0.4)),
                  ),
                  child: Text(statusInfo['label'],
                      style: TextStyle(
                          color: statusInfo['color'], fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E1E40)),
          // Items
          ...shipment.items.map((item) => _IncomingItemRow(
                item: item,
                shipmentId: shipment.id,
              )),
        ],
      ),
    );
  }

  Map<String, dynamic> _statusInfo(IncomingStatus status) {
    switch (status) {
      case IncomingStatus.pending:
        return {'label': 'Arriving', 'color': Colors.blue};
      case IncomingStatus.partiallyReceived:
        return {'label': 'Partial', 'color': Colors.orange};
      case IncomingStatus.received:
        return {'label': 'Received', 'color': Colors.green};
      case IncomingStatus.disputed:
        return {'label': 'Issues Found', 'color': Colors.red};
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative) return 'Aaj expected tha';
    if (diff.inDays == 0) return 'Aaj aa raha hai';
    if (diff.inDays == 1) return 'Kal aayega';
    return '${diff.inDays} din mein';
  }
}

class _IncomingItemRow extends StatefulWidget {
  final IncomingStockItem item;
  final String shipmentId;

  const _IncomingItemRow({required this.item, required this.shipmentId});

  @override
  State<_IncomingItemRow> createState() => _IncomingItemRowState();
}

class _IncomingItemRowState extends State<_IncomingItemRow> {
  bool _isExpanded = false;
  late TextEditingController _receivedCtrl;
  late TextEditingController _defectiveCtrl;
  late TextEditingController _missingCtrl;
  late TextEditingController _noteCtrl;
  ItemStatus _selectedStatus = ItemStatus.pending;

  @override
  void initState() {
    super.initState();
    _receivedCtrl = TextEditingController(text: '${widget.item.receivedQty}');
    _defectiveCtrl = TextEditingController(text: '${widget.item.defectiveQty}');
    _missingCtrl = TextEditingController(text: '${widget.item.missingQty}');
    _noteCtrl = TextEditingController(text: widget.item.note ?? '');
    _selectedStatus = widget.item.itemStatus;
  }

  @override
  void dispose() {
    _receivedCtrl.dispose();
    _defectiveCtrl.dispose();
    _missingCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemStatusInfo = _itemStatusInfo(widget.item.itemStatus);

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Item info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.productName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(widget.item.variantName,
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _infoChip(
                              Icons.inventory_2_outlined, 'Expected: ${widget.item.expectedQty}',
                              Colors.blue),
                          const SizedBox(width: 6),
                          if (widget.item.receivedQty > 0)
                            _infoChip(Icons.check, 'Mila: ${widget.item.receivedQty}',
                                Colors.green),
                          if (widget.item.defectiveQty > 0) ...[
                            const SizedBox(width: 6),
                            _infoChip(
                                Icons.warning, 'Defective: ${widget.item.defectiveQty}', Colors.orange),
                          ],
                          if (widget.item.missingQty > 0) ...[
                            const SizedBox(width: 6),
                            _infoChip(Icons.help_outline, 'Missing: ${widget.item.missingQty}',
                                Colors.red),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: itemStatusInfo['color'].withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(itemStatusInfo['label'],
                          style: TextStyle(
                              color: itemStatusInfo['color'],
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white38,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Expanded form
        if (_isExpanded) _buildInputForm(context),
        const Divider(height: 1, color: Color(0xFF1A1A35)),
      ],
    );
  }

  Widget _buildInputForm(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Item Details Update',
              style: TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          // Qty fields
          Row(
            children: [
              Expanded(child: _qtyField('Received Qty', _receivedCtrl, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _qtyField('Defective', _defectiveCtrl, Colors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _qtyField('Missing', _missingCtrl, Colors.red)),
            ],
          ),
          const SizedBox(height: 14),
          // Status selection
          const Text('Status', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ItemStatus.values.map((s) {
              final info = _itemStatusInfo(s);
              final isSelected = _selectedStatus == s;
              return GestureDetector(
                onTap: () => setState(() => _selectedStatus = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? info['color'].withOpacity(0.25)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? info['color'] : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(info['label'],
                      style: TextStyle(
                        color: isSelected ? info['color'] : Colors.white54,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                      )),
                ),
              );
            }).toList(),
          ),
          // Defective photo section
          if (_selectedStatus == ItemStatus.defective) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.camera_alt_outlined, color: Colors.white38, size: 16),
                const SizedBox(width: 6),
                const Text('Defective Photos',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // In real app, open camera/gallery
                    context.read<StockProvider>().addDefectivePhoto(
                        widget.shipmentId, widget.item.id, 'photo_${DateTime.now().millisecond}.jpg');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo added (simulated)'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D5AFE).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_a_photo, color: Color(0xFF3D5AFE), size: 14),
                        SizedBox(width: 4),
                        Text('Add Photo',
                            style: TextStyle(color: Color(0xFF3D5AFE), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (widget.item.defectivePhotos.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.item.defectivePhotos.length,
                  itemBuilder: (_, i) => Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Stack(
                      children: [
                        const Center(child: Icon(Icons.image, color: Colors.orange, size: 24)),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('${i + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 14),
          // Note field
          TextField(
            controller: _noteCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Note likhein...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF1A1A35),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 14),
          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<StockProvider>().updateIncomingItem(
                      incomingId: widget.shipmentId,
                      itemId: widget.item.id,
                      receivedQty: int.tryParse(_receivedCtrl.text) ?? 0,
                      defectiveQty: int.tryParse(_defectiveCtrl.text) ?? 0,
                      missingQty: int.tryParse(_missingCtrl.text) ?? 0,
                      status: _selectedStatus,
                      note: _noteCtrl.text.trim(),
                    );
                setState(() => _isExpanded = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Item update ho gaya!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D5AFE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save & Update Stock'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyField(String label, TextEditingController ctrl, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: color.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Map<String, dynamic> _itemStatusInfo(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return {'label': 'Pending', 'color': Colors.white54};
      case ItemStatus.accepted:
        return {'label': 'Accepted', 'color': Colors.green};
      case ItemStatus.defective:
        return {'label': 'Defective', 'color': Colors.orange};
      case ItemStatus.missing:
        return {'label': 'Missing', 'color': Colors.red};
    }
  }
}
