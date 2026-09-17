import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/coupon_model.dart';

/// Repository for coupons with Firestore integration
class CouponRepository {
  static final CouponRepository _instance = CouponRepository._internal();
  factory CouponRepository() => _instance;
  CouponRepository._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// In-memory cache of coupons (empty in production until fetched from Firestore or seeded in tests)
  final List<Coupon> _cachedCoupons = [];

  /// Helper to seed coupons for unit/widget tests
  void setInitialCache(List<Coupon> coupons) {
    _cachedCoupons.clear();
    _cachedCoupons.addAll(coupons);
  }

  List<Coupon> get cachedCoupons => List.unmodifiable(_cachedCoupons);

  /// Real-time stream of active coupons from top-level `coupons` collection
  Stream<List<Coupon>> getCouponsStream() {
    final db = _firestore;
    if (db == null) {
      return Stream.value(_cachedCoupons);
    }

    try {
      return db.collection('coupons').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          _cachedCoupons.clear();
          return <Coupon>[];
        }
        final list = snapshot.docs.map((doc) {
          return Coupon.fromMap(doc.data(), doc.id);
        }).toList();

        _cachedCoupons.clear();
        _cachedCoupons.addAll(list);
        return list;
      }).handleError((e) {
        debugPrint('CouponRepository: Stream notice: $e');
        return <Coupon>[];
      });
    } catch (e) {
      debugPrint('CouponRepository: getCouponsStream catch: $e');
      return Stream.value(<Coupon>[]);
    }
  }

  /// Lookup coupon by code (case-insensitive) from Firestore or seeded test cache
  Future<Coupon?> getCouponByCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;

    final db = _firestore;
    if (db != null) {
      try {
        final doc = await db.collection('coupons').doc(normalized).get();
        if (doc.exists && doc.data() != null) {
          return Coupon.fromMap(doc.data()!, doc.id);
        }

        // Also check by field query if docId differed
        final query = await db
            .collection('coupons')
            .where('code', isEqualTo: normalized)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final first = query.docs.first;
          return Coupon.fromMap(first.data(), first.id);
        }
      } catch (e) {
        debugPrint('CouponRepository: lookup error: $e');
      }
    }

    // In-memory lookup (for seeded test environments)
    try {
      return _cachedCoupons.firstWhere(
        (c) => c.code.toUpperCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }
}
