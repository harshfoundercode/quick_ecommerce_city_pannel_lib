import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';
import '../widgets/app_header.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<StockProvider>().bulkRequests;

    return Column(
      children: [
        const AppHeader(title: 'Request History', subtitle: 'Sabhi bulk stock requests'),
        if (requests.isEmpty)
          const Expanded(
            child: Center(
              child: Text('Koi request nahi hai abhi tak',
                  style: TextStyle(color: Colors.white38, fontSize: 16)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (_, i) => _buildRequestCard(context, requests[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, BulkStockRequest req) {
    final statusInfo = _statusInfo(req.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusInfo['icon'], color: statusInfo['color'], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Request #${req.id.substring(3, min(req.id.length, 10))}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(_formatDate(req.createdAt),
                          style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusInfo['color'].withOpacity(0.3)),
                  ),
                  child: Text(
                    statusInfo['label'],
                    style: TextStyle(
                        color: statusInfo['color'], fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E1E40)),
          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: req.items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, color: Color(0xFF3D5AFE), size: 6),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${item.productName} - ${item.variantName}',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A35),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${item.quantityRequested}',
                                style: const TextStyle(
                                    color: Color(0xFF3D5AFE),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          if (req.note != null && req.note!.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFF1E1E40)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.note_alt_outlined, color: Colors.white38, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(req.note!,
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
          // Footer summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${req.items.length} variants · ${req.totalItems} total units',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  'By ${req.requestedBy}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _statusInfo(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return {'label': 'Pending', 'color': Colors.orange, 'icon': Icons.hourglass_empty};
      case RequestStatus.approved:
        return {'label': 'Approved', 'color': Colors.blue, 'icon': Icons.check_circle_outline};
      case RequestStatus.rejected:
        return {'label': 'Rejected', 'color': Colors.red, 'icon': Icons.cancel_outlined};
      case RequestStatus.fulfilled:
        return {'label': 'Fulfilled', 'color': Colors.green, 'icon': Icons.task_alt};
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min pehle';
    if (diff.inHours < 24) return '${diff.inHours} ghante pehle';
    return '${diff.inDays} din pehle';
  }

  int min(int a, int b) => a < b ? a : b;
}
