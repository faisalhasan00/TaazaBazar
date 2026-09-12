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
  });

  int get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
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
