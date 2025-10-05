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
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
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
    return Quote(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String,
      company: json['company'] as String?,
      phone: json['phone'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => QuoteItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      adminNotes: json['adminNotes'] as String?,
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
