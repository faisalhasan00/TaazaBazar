import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../profile/data/profile_repository.dart';
import '../domain/customer_order.dart';

/// Repository for handling Customer Orders via Firestore with real-time sync and local cache
class OrderRepository {
  static final OrderRepository _instance = OrderRepository._internal();
  factory OrderRepository() => _instance;
  OrderRepository._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  String? get _currentUserId => FirebaseAuthService().currentUserId;

  final List<CustomerOrder> _cachedOrders = [];

  /// For testing purposes only: seed initial orders into the cache
  @visibleForTesting
  void setInitialCache(List<CustomerOrder> orders) {
    _cachedOrders
      ..clear()
      ..addAll(orders);
  }

  /// Stream of active orders (placed, preparing, out for delivery)
  Stream<List<CustomerOrder>> getActiveOrdersStream({String? userId}) {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null || uid.isEmpty) {
      return Stream.value(
        _cachedOrders.where((o) => o.status.isActive).toList(),
      );
    }

    try {
      return db
          .collection('users')
          .doc(uid)
          .collection('orders')
          .snapshots()
          .map((snapshot) {
        final orders = snapshot.docs.map((doc) {
          return CustomerOrder.fromMap(doc.data(), doc.id);
        }).toList();

        // Sort descending by order date
        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

        // Update local cache
        _cachedOrders.clear();
        _cachedOrders.addAll(orders);

        return orders.where((o) => o.status.isActive).toList();
      }).handleError((e) {
        debugPrint('OrderRepository: Active orders stream error: $e');
        return _cachedOrders.where((o) => o.status.isActive).toList();
      });
    } catch (e) {
      debugPrint('OrderRepository: getActiveOrdersStream catch: $e');
      return Stream.value(
        _cachedOrders.where((o) => o.status.isActive).toList(),
      );
    }
  }

  /// Stream of previous/delivered/cancelled orders
  Stream<List<CustomerOrder>> getPreviousOrdersStream({String? userId}) {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null || uid.isEmpty) {
      return Stream.value(
        _cachedOrders
            .where((o) => o.status.isDelivered || o.status.isCancelled)
            .toList(),
      );
    }

    try {
      return db
          .collection('users')
          .doc(uid)
          .collection('orders')
          .snapshots()
          .map((snapshot) {
        final orders = snapshot.docs.map((doc) {
          return CustomerOrder.fromMap(doc.data(), doc.id);
        }).toList();

        // Sort descending by order date
        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

        return orders
            .where((o) => o.status.isDelivered || o.status.isCancelled)
            .toList();
      }).handleError((e) {
        debugPrint('OrderRepository: Previous orders stream error: $e');
        return _cachedOrders
            .where((o) => o.status.isDelivered || o.status.isCancelled)
            .toList();
      });
    } catch (e) {
      debugPrint('OrderRepository: getPreviousOrdersStream catch: $e');
      return Stream.value(
        _cachedOrders
            .where((o) => o.status.isDelivered || o.status.isCancelled)
            .toList(),
      );
    }
  }

  /// Stream of all customer orders
  Stream<List<CustomerOrder>> getAllOrdersStream({String? userId}) {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null || uid.isEmpty) {
      return Stream.value(List.unmodifiable(_cachedOrders));
    }

    try {
      return db
          .collection('users')
          .doc(uid)
          .collection('orders')
          .snapshots()
          .map((snapshot) {
        final orders = snapshot.docs.map((doc) {
          return CustomerOrder.fromMap(doc.data(), doc.id);
        }).toList();

        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        return orders;
      }).handleError((e) {
        debugPrint('OrderRepository: All orders stream error: $e');
        return List.unmodifiable(_cachedOrders);
      });
    } catch (e) {
      debugPrint('OrderRepository: getAllOrdersStream catch: $e');
      return Stream.value(List.unmodifiable(_cachedOrders));
    }
  }

  /// Look up a cached order by ID
  CustomerOrder? getOrderById(String orderId) {
    try {
      final cleanId = orderId.replaceAll('#', '').toLowerCase();
      return _cachedOrders.firstWhere(
        (o) => o.orderId.replaceAll('#', '').toLowerCase() == cleanId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Place a new order into Firestore under users/{uid}/orders/{orderId} AND top-level orders/{orderId}
  Future<void> placeOrder(CustomerOrder order, {String? userId}) async {
    final db = _firestore;
    var uid = userId ?? _currentUserId;

    if (uid == null || uid.isEmpty) {
      final auth = FirebaseAuthService();
      uid = auth.currentUserId;
      if (uid == null || uid.isEmpty) {
        // Sign in anonymously to get a valid user ID if needed
        try {
          final user = await auth.ensureAuthenticated();
          uid = user?.uid;
        } catch (_) {}
      }
    }

    final effectiveUid = (uid != null && uid.isNotEmpty) ? uid : 'guest_customer';

    // Cache locally for authenticated user
    final existingIdx = _cachedOrders.indexWhere((o) => o.orderId == order.orderId);
    if (existingIdx >= 0) {
      _cachedOrders[existingIdx] = order;
    } else {
      _cachedOrders.insert(0, order);
    }

    if (db != null) {
      try {
        final docId = order.orderId.replaceAll('#', '');
        final orderMap = Map<String, dynamic>.from(order.toMap());
        orderMap['userId'] = effectiveUid;
        
        final authService = FirebaseAuthService();
        final savedName = await authService.getSavedUserName();
        final savedPhone = await authService.getSavedUserPhone();
        final cachedProf = ProfileRepository().cachedProfile;

        final customerName = (savedName != null && savedName.trim().isNotEmpty)
            ? savedName.trim()
            : ((cachedProf != null && cachedProf.name.trim().isNotEmpty && cachedProf.name != 'Guest User')
                ? cachedProf.name.trim()
                : (FirebaseAuth.instance.currentUser?.displayName ?? 'App Member'));

        final customerPhone = (savedPhone != null && savedPhone.trim().isNotEmpty)
            ? savedPhone.trim()
            : ((cachedProf != null && cachedProf.phone.trim().isNotEmpty)
                ? cachedProf.phone.trim()
                : (FirebaseAuth.instance.currentUser?.phoneNumber ?? ''));

        orderMap['customerName'] = customerName;
        orderMap['userName'] = customerName;
        orderMap['customerPhone'] = customerPhone;
        orderMap['phone'] = customerPhone;
        
        orderMap['totalAmount'] = order.grandTotal;
        orderMap['createdAt'] = FieldValue.serverTimestamp();

        // 1. Write to top-level collection 'orders' (for Admin CMS / Store management)
        await db
            .collection('orders')
            .doc(docId)
            .set(orderMap, SetOptions(merge: true));

        // 2. Write to user subcollection 'users/{uid}/orders' (for customer app screen)
        if (effectiveUid != 'guest_customer') {
          await db
              .collection('users')
              .doc(effectiveUid)
              .collection('orders')
              .doc(docId)
              .set(orderMap, SetOptions(merge: true));
        }

        debugPrint('OrderRepository: Successfully wrote order $docId to orders and users/$effectiveUid/orders');
      } catch (e) {
        debugPrint('OrderRepository: placeOrder error: $e');
        rethrow;
      }
    }
  }
}

