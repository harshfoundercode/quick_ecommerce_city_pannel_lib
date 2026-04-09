
// ─── TRANSFER TYPE ──────────────────────────────────────────────────
enum TransferType { adminRequest, hubTransfer }

// ─── BULK STOCK REQUEST MODEL ──────────────────────────────────────
class BulkStockRequest {
  final String id;
  final DateTime createdAt;
  final String requestedBy;
  final List<StockRequestItem> items;
  RequestStatus status;
  String? note;
  final TransferType transferType;
  final String? hubName;
  BulkStockRequest({
    required this.id,
    required this.createdAt,
    required this.requestedBy,
    required this.items,
    this.status = RequestStatus.pending,
    this.note,
    this.transferType = TransferType.adminRequest,
    this.hubName,
  });
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantityRequested);
}

class StockRequestItem {
  final String productId;
  final String productName;
  final String variantId;
  final String variantName;
  final int quantityRequested;
  StockRequestItem({
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.variantName,
    required this.quantityRequested,
  });
}

enum RequestStatus { pending, approved, rejected, fulfilled }