import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../products/domain/product_model.dart';
import '../domain/cart_item.dart';

/// Repository for handling User Shopping Cart in Cloud Firestore (users/{uid}/cart/{productId})
class CartRepository {
  static final CartRepository _instance = CartRepository._internal();
  factory CartRepository() => _instance;
  CartRepository._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Active Firebase User ID
  String? get _currentUserId => FirebaseAuthService().currentUserId;

  /// In-memory cached cart items
  List<CartItem> _cachedCartItems = [];

  /// Current cached items
  List<CartItem> get cachedCartItems => List.unmodifiable(_cachedCartItems);

  /// Seed initial in-memory cache if provided
  void setInitialCache(List<CartItem> items) {
    _cachedCartItems = List.from(items);
  }

  /// Real-time stream of cart items from users/{uid}/cart
  Stream<List<CartItem>> getCartStream({String? userId}) {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null) {
      return Stream.value(_cachedCartItems);
    }

    try {
      return db
          .collection('users')
          .doc(uid)
          .collection('cart')
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          _cachedCartItems = [];
          return <CartItem>[];
        }
        final list = snapshot.docs.map((doc) {
          final data = doc.data();
          data['productId'] = doc.id;
          return CartItem.fromMap(data);
        }).toList();
        _cachedCartItems = list;
        return list;
      }).handleError((e) {
        debugPrint('CartRepository: Firestore cart stream error: $e');
        return _cachedCartItems;
      });
    } catch (_) {
      return Stream.value(_cachedCartItems);
    }
  }

  /// Add item or increment quantity in users/{uid}/cart/{productId}
  Future<void> addItem(
    Product product, {
    int quantity = 1,
    String? selectedPack,
    String? userId,
  }) async {
    final uid = userId ?? _currentUserId;
    final existingIndex = _cachedCartItems.indexWhere((i) => i.product.id == product.id);

    int finalQuantity = quantity;
    if (existingIndex >= 0) {
      finalQuantity = _cachedCartItems[existingIndex].quantity + quantity;
      _cachedCartItems[existingIndex].quantity = finalQuantity;
    } else {
      _cachedCartItems.add(
        CartItem(
          product: product,
          quantity: quantity,
          selectedPack: selectedPack,
        ),
      );
    }

    final db = _firestore;
    if (db != null && uid != null) {
      try {
        final docRef = db.collection('users').doc(uid).collection('cart').doc(product.id);
        await docRef.set({
          'productId': product.id,
          'quantity': finalQuantity,
          'selectedPack': selectedPack ?? product.unit,
          'product': product.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('CartRepository: Added ${product.name} (qty: $finalQuantity) under users/$uid/cart/${product.id}');
      } catch (e) {
        debugPrint('CartRepository: Firestore addItem error: $e');
      }
    }
  }

  /// Update quantity of an item in users/{uid}/cart/{productId}
  Future<void> updateQuantity(String productId, int newQuantity, {String? userId}) async {
    final uid = userId ?? _currentUserId;

    if (newQuantity <= 0) {
      await removeItem(productId, userId: uid);
      return;
    }

    final index = _cachedCartItems.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _cachedCartItems[index].quantity = newQuantity;
    }

    final db = _firestore;
    if (db != null && uid != null) {
      try {
        await db
            .collection('users')
            .doc(uid)
            .collection('cart')
            .doc(productId)
            .update({
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('CartRepository: Updated qty to $newQuantity for users/$uid/cart/$productId');
      } catch (e) {
        debugPrint('CartRepository: Firestore updateQuantity error: $e');
      }
    }
  }

  /// Remove item from users/{uid}/cart/{productId}
  Future<void> removeItem(String productId, {String? userId}) async {
    final uid = userId ?? _currentUserId;
    _cachedCartItems.removeWhere((i) => i.product.id == productId);

    final db = _firestore;
    if (db != null && uid != null) {
      try {
        await db
            .collection('users')
            .doc(uid)
            .collection('cart')
            .doc(productId)
            .delete();
        debugPrint('CartRepository: Deleted users/$uid/cart/$productId');
      } catch (e) {
        debugPrint('CartRepository: Firestore removeItem error: $e');
      }
    }
  }

  /// Clear entire cart for authenticated user
  Future<void> clearCart({String? userId}) async {
    final uid = userId ?? _currentUserId;
    _cachedCartItems.clear();

    final db = _firestore;
    if (db != null && uid != null) {
      try {
        final collection = db.collection('users').doc(uid).collection('cart');
        final snapshots = await collection.get();
        final batch = db.batch();
        for (var doc in snapshots.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        debugPrint('CartRepository: Cleared cart under users/$uid/cart');
      } catch (e) {
        debugPrint('CartRepository: Firestore clearCart error: $e');
      }
    }
  }
}
