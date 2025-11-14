class QuoteItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String? customSpecs;

  const QuoteItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.customSpecs,
  });

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      productId: json['_id'] as String? ?? json['productId'] as String? ?? '',
      productName: (json['name'] ?? json['productName']) as String,
      quantity: json['quantity'] as int,
      unitPrice: ((json['price'] ?? json['unitPrice']) as num).toDouble(),
      customSpecs: json['customSpecs'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      if (customSpecs != null) 'customSpecs': customSpecs,
    };
  }

  double get totalPrice => quantity * unitPrice;

  QuoteItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    String? customSpecs,
  }) {
    return QuoteItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      customSpecs: customSpecs ?? this.customSpecs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuoteItem && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;

  @override
  String toString() {
    return 'QuoteItem(productId: $productId, productName: $productName, quantity: $quantity)';
  }
}

class Quote {
  final String id;
  final String customerName;
  final String customerEmail;
  final String? company;
  final String? phone;
  final List<QuoteItem> items;
  final double totalAmount;
  final String status; // 'pending', 'approved', 'rejected', 'expired'
  final String? notes;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? adminNotes;

  const Quote({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    this.company,
    this.phone,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.expiresAt,
    this.adminNotes,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse date strings
    DateTime _parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      try {
        return date is DateTime ? date : DateTime.parse(date.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return Quote(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      customerName: (json['customerName'] ?? '').toString(),
      customerEmail: (json['customerEmail'] ?? '').toString(),
      company: json['company']?.toString(),
      phone: json['phone']?.toString(),
      items: (json['items'] is List)
          ? (json['items'] as List).map((item) {
              if (item is Map<String, dynamic>) {
                return QuoteItem.fromJson(item);
              }
              return QuoteItem(
                productId: '',
                productName: 'Unknown Item',
                quantity: 0,
                unitPrice: 0.0,
              );
            }).toList()
          : <QuoteItem>[],
      totalAmount: (json['totalAmount'] is num)
          ? (json['totalAmount'] as num).toDouble()
          : 0.0,
      status: (json['status'] ?? 'pending').toString(),
      notes: json['notes']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      expiresAt: _parseDate(json['expiresAt'] ?? json['expiryDate']),
      adminNotes: json['adminNotes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerEmail': customerEmail,
      if (company != null) 'company': company,
      if (phone != null) 'phone': phone,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      if (adminNotes != null) 'adminNotes': adminNotes,
    };
  }

  Quote copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    String? company,
    String? phone,
    List<QuoteItem>? items,
    double? totalAmount,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? adminNotes,
  }) {
    return Quote(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quote && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Quote(id: $id, customerName: $customerName, status: $status, totalAmount: $totalAmount)';
  }
}
