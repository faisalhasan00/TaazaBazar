import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../features/coupons/domain/coupon_model.dart';
import '../../features/deals/domain/deal_model.dart';
import '../../features/products/data/mock_products_data.dart';

/// One-tap Idempotent Firestore Database Seeder for TaazaBazar / Freshly
class FirestoreSeeder {
  static Future<Map<String, dynamic>> seedDatabase() async {
    final results = <String, dynamic>{};
    try {
      final db = FirebaseFirestore.instance;

      // 1. Seed Categories (7 items)
      final categoryBatch = db.batch();
      for (final cat in MockProductsData.categories) {
        final docRef = db.collection('categories').doc(cat.id);
        categoryBatch.set(docRef, cat.toMap(), SetOptions(merge: true));
      }
      await categoryBatch.commit();
      debugPrint('FirestoreSeeder: Seeded ${MockProductsData.categories.length} categories.');
      results['categories'] = MockProductsData.categories.length;

      // 2. Seed Products (36 items)
      final productBatch = db.batch();
      for (final prod in MockProductsData.allProducts) {
        final docRef = db.collection('products').doc(prod.id);
        productBatch.set(docRef, prod.toMap(), SetOptions(merge: true));
      }
      await productBatch.commit();
      debugPrint('FirestoreSeeder: Seeded ${MockProductsData.allProducts.length} products.');
      results['products'] = MockProductsData.allProducts.length;

      // 3. Seed Coupons (2 items)
      const coupons = [
        Coupon(
          code: 'FRESH50',
          discount: 50,
          minOrder: 199,
          title: '₹50 Flat Off on first 3 orders',
          description: 'Valid on farm fresh vegetables and fruit baskets',
        ),
        Coupon(
          code: 'TAAZA100',
          discount: 100,
          minOrder: 499,
          title: '₹100 Off on orders above ₹499',
          description: 'Applicable on organic dairy, eggs and pantry staples',
        ),
      ];
      final couponBatch = db.batch();
      for (final coupon in coupons) {
        final docRef = db.collection('coupons').doc(coupon.code);
        couponBatch.set(docRef, coupon.toMap(), SetOptions(merge: true));
      }
      await couponBatch.commit();
      debugPrint('FirestoreSeeder: Seeded ${coupons.length} coupons.');
      results['coupons'] = coupons.length;

      // 4. Seed Deals (5 items)
      final deals = [
        const DealModel(
          id: 'v_tomato',
          title: 'Tomato',
          price: '₹25/kg',
          originalPrice: '₹35',
          emoji: '🍅',
          bgColor: Color(0xFFFFF1F2),
          productId: 'v_tomato',
        ),
        const DealModel(
          id: 'd_cow_milk',
          title: 'Milk',
          price: '₹60/L',
          originalPrice: '₹68',
          emoji: '🥛',
          bgColor: Color(0xFFF0F9FF),
          productId: 'd_a2milk',
        ),
        const DealModel(
          id: 'v_spinach',
          title: 'Spinach',
          price: '₹20/bunch',
          originalPrice: '₹28',
          emoji: '🥬',
          bgColor: Color(0xFFF0FDF4),
          productId: 'v_spinach',
        ),
        const DealModel(
          id: 'v_carrot',
          title: 'Carrot',
          price: '₹38/kg',
          originalPrice: '₹48',
          emoji: '🥕',
          bgColor: Color(0xFFFFF7ED),
          productId: 'v_carrot',
        ),
        const DealModel(
          id: 'e_brown_eggs',
          title: 'Eggs',
          price: '₹65/6pcs',
          originalPrice: '₹75',
          emoji: '🥚',
          bgColor: Color(0xFFFFFBEB),
          productId: 'e_organic',
        ),
      ];
      final dealBatch = db.batch();
      for (final deal in deals) {
        final docRef = db.collection('deals').doc(deal.id);
        dealBatch.set(docRef, deal.toMap(), SetOptions(merge: true));
      }
      await dealBatch.commit();
      debugPrint('FirestoreSeeder: Seeded ${deals.length} deals.');
      results['deals'] = deals.length;

      results['success'] = true;
      return results;
    } catch (e) {
      debugPrint('FirestoreSeeder: Seeding error: $e');
      results['success'] = false;
      results['error'] = e.toString();
      return results;
    }
  }

  /// Verification function to inspect Firestore catalog document counts and IDs
  static Future<Map<String, dynamic>> verifyCatalog() async {
    final report = <String, dynamic>{};
    try {
      final db = FirebaseFirestore.instance;

      final categoriesSnap = await db.collection('categories').get();
      report['categories_count'] = categoriesSnap.docs.length;
      report['categories_ids'] = categoriesSnap.docs.map((d) => d.id).toList();

      final productsSnap = await db.collection('products').get();
      report['products_count'] = productsSnap.docs.length;
      report['products_ids'] = productsSnap.docs.map((d) => d.id).toList();

      final couponsSnap = await db.collection('coupons').get();
      report['coupons_count'] = couponsSnap.docs.length;
      report['coupons_ids'] = couponsSnap.docs.map((d) => d.id).toList();

      final dealsSnap = await db.collection('deals').get();
      report['deals_count'] = dealsSnap.docs.length;
      report['deals_ids'] = dealsSnap.docs.map((d) => d.id).toList();

      report['success'] = true;
    } catch (e) {
      report['success'] = false;
      report['error'] = e.toString();
    }
    return report;
  }
}

