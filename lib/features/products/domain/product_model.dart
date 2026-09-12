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
}
