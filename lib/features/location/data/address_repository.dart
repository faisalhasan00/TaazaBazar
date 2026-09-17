import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../domain/models/delivery_address.dart';

/// Repository for handling Saved Delivery Addresses via Cloud Firestore per authenticated user
class AddressRepository {
  static final AddressRepository _instance = AddressRepository._internal();
  factory AddressRepository() => _instance;
  AddressRepository._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Active Firebase User ID from FirebaseAuthService
  String? get _currentUserId => FirebaseAuthService().currentUserId;

  /// In-memory cache for fast local responses and offline support
  List<DeliveryAddress> _cachedAddresses = [];

  /// Access current cached addresses
  List<DeliveryAddress> get cachedAddresses => List.unmodifiable(_cachedAddresses);

  /// Seed initial cache for tests or mock environments
  void setInitialCache(List<DeliveryAddress> addresses) {
    _cachedAddresses = List.from(addresses);
  }

  /// Get the current default delivery address, if any exists
  DeliveryAddress? getDefaultAddress() {
    try {
      return _cachedAddresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _cachedAddresses.isNotEmpty ? _cachedAddresses.first : null;
    }
  }

  /// Stream of saved addresses for the authenticated user from users/{uid}/addresses
  Stream<List<DeliveryAddress>> getAddressesStream({String? userId}) {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null) {
      return Stream.value(_cachedAddresses);
    }

    try {
      return db
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          _cachedAddresses = [];
          return <DeliveryAddress>[];
        }
        final list = snapshot.docs
            .map((doc) => DeliveryAddress.fromMap(doc.data(), doc.id))
            .toList();
        _cachedAddresses = list;
        return list;
      }).handleError((e) {
        debugPrint('AddressRepository: Firestore stream error: $e');
        return _cachedAddresses;
      });
    } catch (_) {
      return Stream.value(_cachedAddresses);
    }
  }

  /// Save or update an address in users/{uid}/addresses/{addressId}
  Future<void> saveAddress(DeliveryAddress address, {String? userId}) async {
    final uid = userId ?? _currentUserId;
    final docId = address.id ?? 'addr-${DateTime.now().millisecondsSinceEpoch}';
    final updated = address.copyWith(id: docId);

    // Update in-memory
    final existingIndex = _cachedAddresses.indexWhere((a) => a.id == docId);
    if (updated.isDefault) {
      _cachedAddresses = _cachedAddresses.map((a) => a.copyWith(isDefault: false)).toList();
    }
    if (existingIndex >= 0) {
      _cachedAddresses[existingIndex] = updated;
    } else {
      _cachedAddresses.add(updated);
    }

    // Update in Firestore under users/{uid}/addresses
    final db = _firestore;
    if (db != null && uid != null) {
      try {
        final collection = db.collection('users').doc(uid).collection('addresses');
        if (updated.isDefault) {
          // Unset other defaults in Firestore
          final batch = db.batch();
          final existing = await collection.get();
          for (var doc in existing.docs) {
            batch.update(doc.reference, {'isDefault': false});
          }
          batch.set(collection.doc(docId), updated.toMap());
          await batch.commit();
        } else {
          await collection.doc(docId).set(updated.toMap(), SetOptions(merge: true));
        }
        debugPrint('AddressRepository: Saved address $docId under users/$uid/addresses');
      } catch (e) {
        debugPrint('AddressRepository: Firestore saveAddress error: $e');
      }
    }
  }

  /// Set default delivery address in users/{uid}/addresses
  Future<void> setDefaultAddress(String addressId, {String? userId}) async {
    final uid = userId ?? _currentUserId;

    // Update local cache
    _cachedAddresses = _cachedAddresses.map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();

    // Update Firestore under users/{uid}/addresses
    final db = _firestore;
    if (db != null && uid != null) {
      try {
        final collection = db.collection('users').doc(uid).collection('addresses');
        final batch = db.batch();
        final docs = await collection.get();
        for (var doc in docs.docs) {
          batch.update(doc.reference, {'isDefault': doc.id == addressId});
        }
        await batch.commit();
        debugPrint('AddressRepository: Default address set to $addressId under users/$uid/addresses');
      } catch (e) {
        debugPrint('AddressRepository: Firestore setDefaultAddress error: $e');
      }
    }
  }

  /// Delete an address from users/{uid}/addresses/{addressId}
  Future<void> deleteAddress(String addressId, {String? userId}) async {
    final uid = userId ?? _currentUserId;

    // Update local cache
    _cachedAddresses.removeWhere((a) => a.id == addressId);
    if (_cachedAddresses.isNotEmpty && !_cachedAddresses.any((a) => a.isDefault)) {
      _cachedAddresses[0] = _cachedAddresses[0].copyWith(isDefault: true);
    }

    // Update Firestore under users/{uid}/addresses
    final db = _firestore;
    if (db != null && uid != null) {
      try {
        await db
            .collection('users')
            .doc(uid)
            .collection('addresses')
            .doc(addressId)
            .delete();
        debugPrint('AddressRepository: Deleted address $addressId under users/$uid/addresses');
      } catch (e) {
        debugPrint('AddressRepository: Firestore deleteAddress error: $e');
      }
    }
  }
}

