import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a coupon/promo code in TaazaBazar / Freshly
class Coupon {
  final String code;
  final String title;
  final String description;
  final double discount;
  final double minOrder;
  final String discountType; // 'flat' or 'percent'
  final double? maxDiscount;
  final DateTime? expiryDate;
  final bool isActive;

  const Coupon({
    required this.code,
    required this.title,
    required this.description,
    required this.discount,
    this.minOrder = 0.0,
    this.discountType = 'flat',
    this.maxDiscount,
    this.expiryDate,
    this.isActive = true,
  });

  bool isValidFor(double cartTotal) {
    if (!isActive) return false;
    if (expiryDate != null && expiryDate!.isBefore(DateTime.now())) return false;
    if (cartTotal < minOrder) return false;
    return true;
  }

  double calculateDiscount(double cartTotal) {
    if (!isValidFor(cartTotal)) return 0.0;
    if (discountType == 'percent') {
      final calculated = (cartTotal * discount) / 100.0;
      if (maxDiscount != null && calculated > maxDiscount!) {
        return maxDiscount!;
      }
      return calculated;
    }
    return discount > cartTotal ? cartTotal : discount;
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'discount': discount,
      'minOrder': minOrder,
      'discountType': discountType,
      'maxDiscount': maxDiscount,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isActive': isActive,
    };
  }

  factory Coupon.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime? parsedExpiry;
    final rawExpiry = map['expiryDate'] ?? map['expiry'];
    if (rawExpiry is Timestamp) {
      parsedExpiry = rawExpiry.toDate();
    } else if (rawExpiry is DateTime) {
      parsedExpiry = rawExpiry;
    } else if (rawExpiry is String) {
      parsedExpiry = DateTime.tryParse(rawExpiry);
    }

    return Coupon(
      code: map['code']?.toString() ?? docId ?? '',
      title: map['title']?.toString() ?? '${map['discount'] ?? 50} Off',
      description: map['description']?.toString() ?? 'Applicable on orders above ₹${map['minOrder'] ?? 0}',
      discount: (map['discount'] as num?)?.toDouble() ?? 50.0,
      minOrder: (map['minOrder'] as num?)?.toDouble() ?? 0.0,
      discountType: map['discountType']?.toString() ?? 'flat',
      maxDiscount: (map['maxDiscount'] as num?)?.toDouble(),
      expiryDate: parsedExpiry,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
