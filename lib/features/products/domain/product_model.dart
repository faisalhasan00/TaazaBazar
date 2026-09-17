import 'package:flutter/material.dart';

/// Product Model for Freshly Catalog
class Product {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final String unit;
  final double price;
  final double? originalPrice;
  final String emoji;
  final Color bgColor;
  final String? badge;
  final double rating;
  final int reviewsCount;
  final bool isOrganic;
  final String? description;
  final List<String>? benefits;
  final String? shelfLife;
  final String? storageInfo;
  final String? farmOrigin;

  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.unit,
    required this.price,
    this.originalPrice,
    required this.emoji,
    this.bgColor = const Color(0xFFF0FDF4),
    this.badge,
    this.rating = 4.8,
    this.reviewsCount = 120,
    this.isOrganic = false,
    this.description,
    this.benefits,
    this.shelfLife,
    this.storageInfo,
    this.farmOrigin,
  });

  int get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get displayDescription {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    if (isOrganic) {
      return '100% organically grown $name harvested at peak freshness without any synthetic chemicals or pesticides. Hand-sorted and delivered fresh to your doorstep.';
    }
    return 'Premium farm-fresh $name directly sourced from certified local growers. Selected for optimal flavor, crisp texture, and maximum nutritional value.';
  }

  List<String> get displayBenefits {
    if (benefits != null && benefits!.isNotEmpty) {
      return benefits!;
    }
    return [
      'Directly harvested from local regional farms at sunrise',
      isOrganic
          ? 'Certified 100% organic with zero chemical residues'
          : 'Strictly checked for natural freshness and grade-A quality',
      'Packed in eco-friendly breathable packaging to maintain crunch',
      'Rich in natural vitamins, dietary minerals, and essential nutrients',
    ];
  }

  String get displayOrigin {
    return farmOrigin ?? 'Shadnagar Organic Belt, Telangana';
  }

  String get displayShelfLife {
    return shelfLife ?? 'Best consumed within 3–4 days';
  }

  String get displayStorageInfo {
    return storageInfo ?? 'Store in a cool, ventilated dry area or refrigerate';
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'unit': unit,
      'price': price,
      'originalPrice': originalPrice,
      'emoji': emoji,
      'bgColor': bgColor.toARGB32(),
      'badge': badge,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isOrganic': isOrganic,
      'description': description,
      'benefits': benefits,
      'shelfLife': shelfLife,
      'storageInfo': storageInfo,
      'farmOrigin': farmOrigin,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Product(
      id: docId ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? 'veg',
      categoryName: map['categoryName']?.toString() ?? 'Vegetables',
      unit: map['unit']?.toString() ?? '1 kg',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      emoji: map['emoji']?.toString() ?? '🥦',
      bgColor: map['bgColor'] != null ? Color(map['bgColor'] as int) : const Color(0xFFF0FDF4),
      badge: map['badge']?.toString(),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 120,
      isOrganic: map['isOrganic'] == true,
      description: map['description']?.toString(),
      benefits: (map['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      shelfLife: map['shelfLife']?.toString(),
      storageInfo: map['storageInfo']?.toString(),
      farmOrigin: map['farmOrigin']?.toString(),
    );
  }
}

/// Category Model for Freshly Catalog
class FreshCategory {
  final String id;
  final String name;
  final String emoji;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
  final int itemCount;

  const FreshCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.subtitle,
    this.bgColor = const Color(0xFFEDF7EF),
    this.iconColor = const Color(0xFF1B6E38),
    this.itemCount = 12,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'subtitle': subtitle,
      'bgColor': bgColor.toARGB32(),
      'iconColor': iconColor.toARGB32(),
      'itemCount': itemCount,
    };
  }

  factory FreshCategory.fromMap(Map<String, dynamic> map, [String? docId]) {
    return FreshCategory(
      id: docId ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      emoji: map['emoji']?.toString() ?? '🥬',
      subtitle: map['subtitle']?.toString() ?? '',
      bgColor: map['bgColor'] != null ? Color(map['bgColor'] as int) : const Color(0xFFEDF7EF),
      iconColor: map['iconColor'] != null ? Color(map['iconColor'] as int) : const Color(0xFF1B6E38),
      itemCount: (map['itemCount'] as num?)?.toInt() ?? 12,
    );
  }
}
