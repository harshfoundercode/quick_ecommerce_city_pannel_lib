class VariantRow {
  final String name;
  final int sent;
  final int received;
  final int defective;
  final int missing;

  const VariantRow({
    required this.name,
    required this.sent,
    required this.received,
    required this.defective,
    required this.missing,
  });

  VariantRow copyWith({
    String? name,
    int? sent,
    int? received,
    int? defective,
    int? missing,
  }) {
    return VariantRow(
      name: name ?? this.name,
      sent: sent ?? this.sent,
      received: received ?? this.received,
      defective: defective ?? this.defective,
      missing: missing ?? this.missing,
    );
  }
}

enum DisputeType { defective, missing, pending }

enum DisputeSeverity { high, medium, low }

enum DisputeStatus { open, underReview, sentToCity, pendingReview, rejected }

class DisputeItem {
  final int id;
  final DisputeType type;
  final String product;
  final String hub;
  final String sku;
  final String category;
  final int transferred;
  final int defective;
  final int missing;
  final List<VariantRow> variants;
  final String note;
  final DisputeStatus status;
  final String date;
  final DisputeSeverity severity;

  const DisputeItem({
    required this.id,
    required this.type,
    required this.product,
    required this.hub,
    required this.sku,
    required this.category,
    required this.transferred,
    required this.defective,
    required this.missing,
    required this.variants,
    required this.note,
    required this.status,
    required this.date,
    required this.severity,
  });

  DisputeItem copyWith({
    int? id,
    DisputeType? type,
    String? product,
    String? hub,
    String? sku,
    String? category,
    int? transferred,
    int? defective,
    int? missing,
    List<VariantRow>? variants,
    String? note,
    DisputeStatus? status,
    String? date,
    DisputeSeverity? severity,
  }) {
    return DisputeItem(
      id: id ?? this.id,
      type: type ?? this.type,
      product: product ?? this.product,
      hub: hub ?? this.hub,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      transferred: transferred ?? this.transferred,
      defective: defective ?? this.defective,
      missing: missing ?? this.missing,
      variants: variants ?? this.variants,
      note: note ?? this.note,
      status: status ?? this.status,
      date: date ?? this.date,
      severity: severity ?? this.severity,
    );
  }

  String get typeLabel {
    switch (type) {
      case DisputeType.defective:
        return 'Defective';
      case DisputeType.missing:
        return 'Missing';
      case DisputeType.pending:
        return 'Pending';
    }
  }

  String get statusLabel {
    switch (status) {
      case DisputeStatus.open:
        return 'Open';
      case DisputeStatus.underReview:
        return 'Under Review';
      case DisputeStatus.sentToCity:
        return 'Sent to City';
      case DisputeStatus.pendingReview:
        return 'Pending Review';
      case DisputeStatus.rejected:
        return 'Rejected';
    }
  }

  String get severityLabel {
    switch (severity) {
      case DisputeSeverity.high:
        return 'High';
      case DisputeSeverity.medium:
        return 'Medium';
      case DisputeSeverity.low:
        return 'Low';
    }
  }
}