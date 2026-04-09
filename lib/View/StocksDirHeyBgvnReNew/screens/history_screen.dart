import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';
import '../widgets/app_header.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all'; // all | admin | hub

  @override
  Widget build(BuildContext context) {
    final all = context.watch<StockProvider>().bulkRequests;
    final requests = all.where((r) {
      if (_filter == 'admin') return r.transferType == TransferType.adminRequest;
      if (_filter == 'hub') return r.transferType == TransferType.hubTransfer;
      return true;
    }).toList();

    return Column(
      children: [
        const AppHeader(title: 'Request History', subtitle: 'Sabhi transfer requests'),
        _filterBar(),
        if (requests.isEmpty)
          const Expanded(child: Center(child: Text('Koi request nahi mili', style: TextStyle(color: ColorConst.textGrey, fontSize: 15))))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: requests.length,
              itemBuilder: (_, i) => _card(requests[i]),
            ),
          ),
      ],
    );
  }

  Widget _filterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          _fBtn('all', 'All'),
          const SizedBox(width: 8),
          _fBtn('admin', 'Admin Requests'),
          const SizedBox(width: 8),
          _fBtn('hub', 'Hub Transfers'),
        ],
      ),
    );
  }

  Widget _fBtn(String val, String label) {
    final active = _filter == val;
    return GestureDetector(
      onTap: () => setState(() => _filter = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? ColorConst.primaryGreen : ColorConst.containerGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? ColorConst.primaryGreen : ColorConst.borderColor),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : ColorConst.textSecondary, fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

  Widget _card(BulkStockRequest req) {
    final sInfo = _statusInfo(req.status);
    final isHub = req.transferType == TransferType.hubTransfer;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConst.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: isHub ? ColorConst.criticalBlueLight : ColorConst.greenPale, borderRadius: BorderRadius.circular(10)),
                  child: Icon(isHub ? Icons.hub : Icons.admin_panel_settings_outlined, color: isHub ? ColorConst.info : ColorConst.primaryGreen, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(isHub ? 'Hub Transfer' : 'Admin Request', style: const TextStyle(color: ColorConst.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 6),
                          if (isHub && req.hubName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: ColorConst.criticalBlueLight, borderRadius: BorderRadius.circular(6)),
                              child: Text('→ ${req.hubName}', style: const TextStyle(color: ColorConst.info, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      Text(_formatDate(req.createdAt), style: const TextStyle(color: ColorConst.textGrey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: sInfo['bg'], borderRadius: BorderRadius.circular(20), border: Border.all(color: sInfo['color'].withOpacity(0.3))),
                  child: Text(sInfo['label'], style: TextStyle(color: sInfo['color'], fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ColorConst.borderColor),
          // Items
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              children: req.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Container(width: 5, height: 5, decoration: BoxDecoration(color: ColorConst.primaryGreen, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${item.productName} · ${item.variantName}', style: const TextStyle(color: ColorConst.textSecondary, fontSize: 12))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: ColorConst.greenPale, borderRadius: BorderRadius.circular(5)),
                      child: Text('+${item.quantityRequested}', style: const TextStyle(color: ColorConst.primaryGreen, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          if (req.note != null && req.note!.isNotEmpty) ...[
            Divider(height: 1, color: ColorConst.containerGrey),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  const Icon(Icons.note_alt_outlined, color: ColorConst.textGrey, size: 13),
                  const SizedBox(width: 6),
                  Expanded(child: Text(req.note!, style: const TextStyle(color: ColorConst.textSecondary, fontSize: 12))),
                ],
              ),
            ),
          ],
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ColorConst.containerGrey2,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: ColorConst.textGrey, size: 13),
                const SizedBox(width: 5),
                Text('${req.items.length} variants · ${req.totalItems} units', style: const TextStyle(color: ColorConst.textGrey, fontSize: 11)),
                const Spacer(),
                Text('By ${req.requestedBy}', style: const TextStyle(color: ColorConst.textGrey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _statusInfo(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending: return {'label': 'Pending', 'color': ColorConst.warning, 'bg': ColorConst.honeyBg};
      case RequestStatus.approved: return {'label': 'Approved', 'color': ColorConst.info, 'bg': ColorConst.criticalBlueLight};
      case RequestStatus.rejected: return {'label': 'Rejected', 'color': ColorConst.danger, 'bg': ColorConst.dangerBg};
      case RequestStatus.fulfilled: return {'label': 'Fulfilled', 'color': ColorConst.success, 'bg': ColorConst.greenPale};
    }
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min pehle';
    if (diff.inHours < 24) return '${diff.inHours} ghante pehle';
    return '${diff.inDays} din pehle';
  }
}
