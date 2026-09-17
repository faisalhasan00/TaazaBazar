import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../domain/deal_model.dart';

/// Repository managing fresh promotional deals with Firestore live sync
class DealRepository {
  static final DealRepository _instance = DealRepository._internal();
  factory DealRepository() => _instance;
  DealRepository._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// In-memory cache of deals (empty in production until fetched from Firestore or seeded in tests)
  final List<DealModel> _cachedDeals = [];

  /// Helper to seed deals for unit/widget tests
  void setInitialCache(List<DealModel> deals) {
    _cachedDeals.clear();
    _cachedDeals.addAll(deals);
  }

  List<DealModel> get cachedDeals => List.unmodifiable(_cachedDeals);

  /// Live Firestore stream of deals from top-level `deals` collection
  Stream<List<DealModel>> getDealsStream() {
    final db = _firestore;
    if (db == null) {
      return Stream.value(_cachedDeals);
    }

    try {
      return db.collection('deals').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          _cachedDeals.clear();
          return <DealModel>[];
        }
        final list = snapshot.docs.map((doc) {
          return DealModel.fromMap(doc.data(), doc.id);
        }).where((d) => d.isActive).toList();

        _cachedDeals.clear();
        _cachedDeals.addAll(list);
        return list;
      }).handleError((e) {
        debugPrint('DealRepository: Stream notice: $e');
        return <DealModel>[];
      });
    } catch (e) {
      debugPrint('DealRepository: getDealsStream catch: $e');
      return Stream.value(<DealModel>[]);
    }
  }
}
