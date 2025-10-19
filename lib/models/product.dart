class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String brand;
  final String? image;
  final bool inStock;
  final Map<String, String> specifications;
  final double rating;
  final int reviews;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.brand,
    this.image,
    this.inStock = true,
    this.specifications = const {},
    this.rating = 0.0,
    this.reviews = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? json['_id']) as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      category: (json['category'] as String?) ?? '',
      brand: (json['brand'] as String?) ?? '',
      image: json['image'] as String?,
      inStock: json['inStock'] as bool? ?? ((json['stock'] as num?) ?? 0) > 0,
      specifications: Map<String, String>.from(
        json['specifications'] as Map<String, dynamic>? ?? {},
      ),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'brand': brand,
      if (image != null) 'image': image,
      'inStock': inStock,
      'specifications': specifications,
      'rating': rating,
      'reviews': reviews,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? brand,
    String? image,
    bool? inStock,
    Map<String, String>? specifications,
    double? rating,
    int? reviews,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      image: image ?? this.image,
      inStock: inStock ?? this.inStock,
      specifications: specifications ?? this.specifications,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
  }
}
