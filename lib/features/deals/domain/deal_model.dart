import 'package:flutter/material.dart';

/// Deal model representing a discounted product promotion in TaazaBazar / Freshly
class DealModel {
  final String id;
  final String title;
  final String price;
  final String originalPrice;
  final String emoji;
  final Color bgColor;
  final String? productId;
  final int? discountPercentage;
  final bool isActive;

  const DealModel({
    required this.id,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.emoji,
    this.bgColor = const Color(0xFFF8FAFC),
    this.productId,
    this.discountPercentage,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'originalPrice': originalPrice,
      'emoji': emoji,
      'bgColorHex': '#${bgColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
      'productId': productId ?? id,
      'discountPercentage': discountPercentage,
      'isActive': isActive,
    };
  }

  factory DealModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    Color parsedBgColor = const Color(0xFFF8FAFC);
    final rawHex = map['bgColorHex'] ?? map['bgColor'];
    if (rawHex is String && rawHex.startsWith('#')) {
      final clean = rawHex.replaceAll('#', '');
      final val = int.tryParse(clean, radix: 16);
      if (val != null) {
        parsedBgColor = Color(clean.length == 6 ? (0xFF000000 | val) : val);
      }
    } else if (rawHex is Color) {
      parsedBgColor = rawHex;
    } else if (rawHex is int) {
      parsedBgColor = Color(rawHex);
    }

    return DealModel(
      id: map['id']?.toString() ?? docId ?? '',
      title: map['title']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      originalPrice: map['originalPrice']?.toString() ?? '',
      emoji: map['emoji']?.toString() ?? '🥦',
      bgColor: parsedBgColor,
      productId: map['productId']?.toString() ?? map['id']?.toString() ?? docId,
      discountPercentage: (map['discountPercentage'] as num?)?.toInt(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toHomeScreenMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'originalPrice': originalPrice,
      'emoji': emoji,
      'bgColor': bgColor,
    };
  }
}
