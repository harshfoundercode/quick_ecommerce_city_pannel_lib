class IncomingStock {
  final String id;
  final String supplierName;
  final DateTime expectedDate;
  final List<IncomingStockItem> items;
  IncomingStatus status;
  DateTime? receivedDate;
  IncomingStock({
    required this.id,
    required this.supplierName,
    required this.expectedDate,
    required this.items,
    this.status = IncomingStatus.pending,
    this.receivedDate,
  });
  int get totalExpected => items.fold(0, (s, i) => s + i.expectedQty);
  int get totalReceived => items.fold(0, (s, i) => s + i.receivedQty);
  int get totalDefective => items.fold(0, (s, i) => s + i.defectiveQty);
  int get totalMissing => items.fold(0, (s, i) => s + i.computedMissing);
  int get totalAccepted => items.fold(0, (s, i) => s + i.acceptedQty);
}

class IncomingStockItem {
  final String id;
  final String productId;
  final String productName;
  final String variantId;
  final String variantName;
  final int expectedQty;
  int receivedQty;
  int defectiveQty;
  List<String> defectivePhotos;
  String? note;
  ItemStatus itemStatus;
  IncomingStockItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.variantName,
    required this.expectedQty,
    this.receivedQty = 0,
    this.defectiveQty = 0,
    List<String>? defectivePhotos,
    this.note,
    this.itemStatus = ItemStatus.pending,
  }) : defectivePhotos = defectivePhotos ?? [];
  int get acceptedQty => (receivedQty - defectiveQty).clamp(0, receivedQty);
  int get computedMissing => (expectedQty - receivedQty).clamp(0, expectedQty);
}

enum IncomingStatus { pending, partiallyReceived, received, disputed }

enum ItemStatus { pending, accepted, defective, missing, mixed }
