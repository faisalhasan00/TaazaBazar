import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../products/domain/product_model.dart';
import '../domain/subscription_model.dart';

/// Repository for handling Recurring Household Subscriptions via Firestore and local cache
class SubscriptionRepository {
  static final SubscriptionRepository _instance = SubscriptionRepository._internal();
  factory SubscriptionRepository() => _instance;
  SubscriptionRepository._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  String? get _currentUserId => FirebaseAuthService().currentUserId;

  final List<SubscriptionModel> _cachedSubscriptions = [];
  final List<SubscriptionDelivery> _cachedDeliveries = [];
  double _dailyMilkCapacityLiters = 1000.0;
  int _skipCutoffHour = 22; // 10:00 PM previous night

  /// For testing fixtures
  @visibleForTesting
  void setInitialCache({
    List<SubscriptionModel>? subscriptions,
    List<SubscriptionDelivery>? deliveries,
    double? milkCapacity,
    int? skipCutoffHour,
  }) {
    if (subscriptions != null) {
      _cachedSubscriptions
        ..clear()
        ..addAll(subscriptions);
    }
    if (deliveries != null) {
      _cachedDeliveries
        ..clear()
        ..addAll(deliveries);
    }
    if (milkCapacity != null) _dailyMilkCapacityLiters = milkCapacity;
    if (skipCutoffHour != null) _skipCutoffHour = skipCutoffHour;
  }

  List<SubscriptionModel> get cachedSubscriptions => List.unmodifiable(_cachedSubscriptions);
  List<SubscriptionDelivery> get cachedDeliveries => List.unmodifiable(_cachedDeliveries);
  double get dailyMilkCapacityLiters => _dailyMilkCapacityLiters;
  int get skipCutoffHour => _skipCutoffHour;

  /// Check available milk capacity
  bool checkMilkCapacityAvailable(double requestedLiters, {DateTime? forDate}) {
    final activeMilkSubscriptions = _cachedSubscriptions.where(
      (s) => s.status == SubscriptionStatus.active,
    );
    double committedLiters = 0;
    for (final sub in activeMilkSubscriptions) {
      for (final item in sub.items) {
        if (item.status == SubscriptionItemStatus.active &&
            item.categoryId.toLowerCase().contains('milk')) {
          committedLiters += item.quantity;
        }
      }
    }
    return (committedLiters + requestedLiters) <= _dailyMilkCapacityLiters;
  }

  /// Real-time stream of subscriptions for active user
  Stream<List<SubscriptionModel>> getSubscriptionsStream({String? userId}) {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null || uid.isEmpty) {
      return Stream.value(List.unmodifiable(_cachedSubscriptions));
    }

    try {
      return db
          .collection('users')
          .doc(uid)
          .collection('subscriptions')
          .snapshots()
          .map((snapshot) {
        final subs = snapshot.docs.map((doc) {
          return SubscriptionModel.fromMap(doc.data(), doc.id);
        }).toList();

        subs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _cachedSubscriptions
          ..clear()
          ..addAll(subs);
        return subs;
      }).handleError((e) {
        debugPrint('SubscriptionRepository: getSubscriptionsStream notice: $e');
        return List.unmodifiable(_cachedSubscriptions);
      });
    } catch (_) {
      return Stream.value(List.unmodifiable(_cachedSubscriptions));
    }
  }

  /// Real-time stream of combined deliveries for a subscription or all active user subscriptions
  Stream<List<SubscriptionDelivery>> getUpcomingDeliveriesStream({String? userId, String? subscriptionId}) {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    if (db == null || uid == null || uid.isEmpty) {
      if (subscriptionId != null) {
        return Stream.value(
          _cachedDeliveries.where((d) => d.subscriptionId == subscriptionId).toList(),
        );
      }
      return Stream.value(List.unmodifiable(_cachedDeliveries));
    }

    try {
      final collectionRef = db
          .collection('users')
          .doc(uid)
          .collection('subscription_deliveries');

      Query<Map<String, dynamic>> query = collectionRef;
      if (subscriptionId != null) {
        query = query.where('subscriptionId', isEqualTo: subscriptionId);
      }

      return query.snapshots().map((snapshot) {
        final list = snapshot.docs.map((doc) {
          return SubscriptionDelivery.fromMap(doc.data(), doc.id);
        }).toList();

        list.sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));
        _cachedDeliveries
          ..clear()
          ..addAll(list);
        return list;
      }).handleError((e) {
        debugPrint('SubscriptionRepository: getUpcomingDeliveriesStream notice: $e');
        return List.unmodifiable(_cachedDeliveries);
      });
    } catch (_) {
      return Stream.value(List.unmodifiable(_cachedDeliveries));
    }
  }

  /// Create a new subscription
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription, {String? userId}) async {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    // Check milk capacity if milk included
    double totalMilkLiters = 0;
    for (final item in subscription.items) {
      if (item.categoryId.toLowerCase().contains('milk')) {
        totalMilkLiters += item.quantity;
      }
    }
    if (totalMilkLiters > 0 && !checkMilkCapacityAvailable(totalMilkLiters)) {
      throw Exception('Milk capacity limit reached (${_dailyMilkCapacityLiters.toInt()}L/day). Please reduce milk quantity.');
    }

    final calculatedSpend = subscription.calculateEstimatedMonthlySpend();
    final subWithSpend = subscription.copyWith(
      estimatedMonthlyAmount: calculatedSpend > 0 ? calculatedSpend : subscription.estimatedMonthlyAmount,
      userId: uid ?? subscription.userId,
    );

    // Save in local cache
    final existingIdx = _cachedSubscriptions.indexWhere((s) => s.id == subWithSpend.id);
    if (existingIdx >= 0) {
      _cachedSubscriptions[existingIdx] = subWithSpend;
    } else {
      _cachedSubscriptions.insert(0, subWithSpend);
    }

    // Persist to Firestore
    if (db != null && uid != null && uid.isNotEmpty) {
      try {
        final subMap = Map<String, dynamic>.from(subWithSpend.toMap());
        final authService = FirebaseAuthService();
        final savedPhone = await authService.getSavedUserPhone();
        final savedName = await authService.getSavedUserName();
        final cleanDigits = savedPhone != null ? savedPhone.replaceAll(RegExp(r'\D'), '') : '';

        subMap['userId'] = uid;
        subMap['phone'] = savedPhone ?? '';
        subMap['customerPhone'] = savedPhone ?? '';
        subMap['customerName'] = savedName ?? 'Subscriber';
        subMap['createdAt'] = FieldValue.serverTimestamp();

        // 1. Save in user subcollection
        await db
            .collection('users')
            .doc(uid)
            .collection('subscriptions')
            .doc(subWithSpend.id)
            .set(subMap, SetOptions(merge: true));

        // 2. Save in top-level 'subscriptions' collection for Admin CMS
        await db
            .collection('subscriptions')
            .doc(subWithSpend.id)
            .set(subMap, SetOptions(merge: true));

        // 3. Mark user as active subscriber
        await db.collection('users').doc(uid).set({
          'isPassMember': true,
          'memberStatus': 'VIP Pass Member',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (cleanDigits.isNotEmpty) {
          await db.collection('phone_users').doc(cleanDigits).set({
            'isPassMember': true,
            'memberStatus': 'VIP Pass Member',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('SubscriptionRepository: createSubscription error: $e');
      }
    }

    // Generate upcoming 14-day combined deliveries
    await generateUpcomingDeliveries(subWithSpend, daysAhead: 14, userId: uid);

    return subWithSpend;
  }

  /// Update subscription status (pause, resume, cancel)
  Future<void> updateSubscriptionStatus(
    String subscriptionId,
    SubscriptionStatus status, {
    String? cancellationReason,
    String? userId,
  }) async {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    final index = _cachedSubscriptions.indexWhere((s) => s.id == subscriptionId);
    if (index >= 0) {
      final sub = _cachedSubscriptions[index];
      final updated = sub.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        cancelledAt: status == SubscriptionStatus.cancelled ? DateTime.now() : null,
        cancellationReason: cancellationReason,
      );
      _cachedSubscriptions[index] = updated;

      if (db != null && uid != null && uid.isNotEmpty) {
        try {
          final payload = <String, dynamic>{
            'status': status.name,
            'updatedAt': DateTime.now().toIso8601String(),
            if (status == SubscriptionStatus.cancelled) ...{
              'cancelledAt': DateTime.now().toIso8601String(),
              'cancellationReason': cancellationReason,
            },
          };

          // 1. Update user subcollection
          await db
              .collection('users')
              .doc(uid)
              .collection('subscriptions')
              .doc(subscriptionId)
              .set(payload, SetOptions(merge: true));

          // 2. Update top-level collection for Admin CMS sync
          await db
              .collection('subscriptions')
              .doc(subscriptionId)
              .set(payload, SetOptions(merge: true));

          // 3. If all subscriptions are cancelled, update member status
          if (status == SubscriptionStatus.cancelled) {
            final activeRemaining = _cachedSubscriptions.where((s) => s.status == SubscriptionStatus.active);
            if (activeRemaining.isEmpty) {
              await db.collection('users').doc(uid).set({
                'isPassMember': false,
                'memberStatus': 'TaazaBazar Member',
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          }
        } catch (e) {
          debugPrint('SubscriptionRepository: updateSubscriptionStatus error: $e');
        }
      }
    }
  }

  /// Modify an individual item in a subscription (pause/resume item, change qty/frequency)
  Future<void> updateSubscriptionItem(
    String subscriptionId,
    SubscriptionItem updatedItem, {
    String? userId,
  }) async {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    final subIndex = _cachedSubscriptions.indexWhere((s) => s.id == subscriptionId);
    if (subIndex >= 0) {
      final sub = _cachedSubscriptions[subIndex];
      final itemIndex = sub.items.indexWhere((i) => i.id == updatedItem.id);
      final newItems = List<SubscriptionItem>.from(sub.items);
      if (itemIndex >= 0) {
        newItems[itemIndex] = updatedItem.copyWith(updatedAt: DateTime.now());
      } else {
        newItems.add(updatedItem);
      }

      final updatedSub = sub.copyWith(
        items: newItems,
        updatedAt: DateTime.now(),
      );
      final finalSub = updatedSub.copyWith(
        estimatedMonthlyAmount: updatedSub.calculateEstimatedMonthlySpend(),
      );
      _cachedSubscriptions[subIndex] = finalSub;

      if (db != null && uid != null && uid.isNotEmpty) {
        try {
          await db
              .collection('users')
              .doc(uid)
              .collection('subscriptions')
              .doc(subscriptionId)
              .set(finalSub.toMap(), SetOptions(merge: true));
        } catch (e) {
          debugPrint('SubscriptionRepository: updateSubscriptionItem error: $e');
        }
      }

      // Re-generate upcoming deliveries with new item configurations
      await generateUpcomingDeliveries(finalSub, daysAhead: 14, userId: uid);
    }
  }

  /// Skip the next scheduled delivery (Cutoff: before 10:00 PM previous day)
  Future<bool> skipNextDelivery(String subscriptionId, String deliveryId, {DateTime? now, String? userId}) async {
    final currentTime = now ?? DateTime.now();
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    final delIndex = _cachedDeliveries.indexWhere((d) => d.id == deliveryId);
    if (delIndex >= 0) {
      final delivery = _cachedDeliveries[delIndex];
      final deliveryDate = delivery.deliveryDate;

      // Cutoff check: 10:00 PM previous day
      final cutoffDate = DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day - 1, _skipCutoffHour, 0);
      if (currentTime.isAfter(cutoffDate)) {
        throw Exception('Cutoff time reached (10:00 PM previous day). Delivery cannot be skipped.');
      }

      final updatedDelivery = SubscriptionDelivery(
        id: delivery.id,
        subscriptionId: delivery.subscriptionId,
        userId: delivery.userId,
        deliveryDate: delivery.deliveryDate,
        deliverySlot: delivery.deliverySlot,
        address: delivery.address,
        items: delivery.items,
        totalAmount: delivery.totalAmount,
        status: 'skipped',
        orderId: delivery.orderId,
        createdAt: delivery.createdAt,
      );
      _cachedDeliveries[delIndex] = updatedDelivery;

      if (db != null && uid != null && uid.isNotEmpty) {
        try {
          await db
              .collection('users')
              .doc(uid)
              .collection('subscription_deliveries')
              .doc(deliveryId)
              .update({'status': 'skipped'});
        } catch (e) {
          debugPrint('SubscriptionRepository: skipNextDelivery error: $e');
        }
      }
      return true;
    }
    return false;
  }

  /// Add a one-time item to tomorrow's / next scheduled delivery
  Future<void> addOneTimeToNextDelivery(
    String subscriptionId,
    Product product,
    int quantity, {
    String? userId,
  }) async {
    final db = _firestore;
    final uid = userId ?? _currentUserId;

    // Find the next active delivery
    final upcoming = _cachedDeliveries.where((d) => d.status == 'pending').toList();
    upcoming.sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));

    if (upcoming.isNotEmpty) {
      final targetDelivery = upcoming.first;
      final addOnItem = SubscriptionItem(
        id: 'addon_${DateTime.now().millisecondsSinceEpoch}',
        subscriptionId: subscriptionId,
        productId: product.id,
        productName: product.name,
        categoryId: product.categoryId,
        categoryName: product.categoryName,
        emoji: product.emoji,
        quantity: quantity.toDouble(),
        unit: product.unit,
        pricePerUnit: product.price,
        frequency: SubscriptionFrequency.daily,
        deliveryDay: 'Next Delivery',
        startDate: targetDelivery.deliveryDate,
        nextDeliveryDate: targetDelivery.deliveryDate,
        status: SubscriptionItemStatus.active,
        isOneTimeAddOn: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedItems = List<SubscriptionItem>.from(targetDelivery.items)..add(addOnItem);
      final updatedTotal = targetDelivery.totalAmount + (product.price * quantity);

      final updatedDelivery = SubscriptionDelivery(
        id: targetDelivery.id,
        subscriptionId: targetDelivery.subscriptionId,
        userId: targetDelivery.userId,
        deliveryDate: targetDelivery.deliveryDate,
        deliverySlot: targetDelivery.deliverySlot,
        address: targetDelivery.address,
        items: updatedItems,
        totalAmount: updatedTotal,
        status: targetDelivery.status,
        orderId: targetDelivery.orderId,
        createdAt: targetDelivery.createdAt,
      );

      final idx = _cachedDeliveries.indexWhere((d) => d.id == targetDelivery.id);
      if (idx >= 0) {
        _cachedDeliveries[idx] = updatedDelivery;
      }

      if (db != null && uid != null && uid.isNotEmpty) {
        try {
          await db
              .collection('users')
              .doc(uid)
              .collection('subscription_deliveries')
              .doc(targetDelivery.id)
              .set(updatedDelivery.toMap(), SetOptions(merge: true));
        } catch (e) {
          debugPrint('SubscriptionRepository: addOneTimeToNextDelivery error: $e');
        }
      }
    }
  }

  /// Idempotent, duplicate-safe Delivery Generator
  /// Combines all active subscription items for the same date/slot/address into ONE single delivery basket.
  Future<List<SubscriptionDelivery>> generateUpcomingDeliveries(
    SubscriptionModel subscription, {
    int daysAhead = 14,
    String? userId,
  }) async {
    final db = _firestore;
    final uid = userId ?? _currentUserId;
    final generated = <SubscriptionDelivery>[];

    if (subscription.status != SubscriptionStatus.active) return generated;

    final now = DateTime.now();
    final startDate = subscription.startDate.isAfter(now)
        ? subscription.startDate
        : DateTime(now.year, now.month, now.day + 1);

    for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      final targetDate = startDate.add(Duration(days: dayOffset));
      final dateKey = '${targetDate.year}${targetDate.month.toString().padLeft(2, '0')}${targetDate.day.toString().padLeft(2, '0')}';
      final deterministicDeliveryId = 'del_${subscription.id}_$dateKey';

      // Check if this delivery date matches any active items' frequency & schedule
      final scheduledItems = <SubscriptionItem>[];
      for (final item in subscription.items) {
        if (item.status != SubscriptionItemStatus.active) continue;

        bool matchesSchedule = false;
        switch (item.frequency) {
          case SubscriptionFrequency.daily:
            matchesSchedule = true;
            break;
          case SubscriptionFrequency.alternateDays:
            final diffDays = targetDate.difference(subscription.startDate).inDays;
            matchesSchedule = diffDays % 2 == 0;
            break;
          case SubscriptionFrequency.weekly:
            final weekdayName = _getWeekdayName(targetDate.weekday);
            matchesSchedule = item.deliveryDay.toLowerCase() == weekdayName.toLowerCase() ||
                item.deliveryDay == 'Daily' ||
                targetDate.weekday == subscription.startDate.weekday;
            break;
          case SubscriptionFrequency.every2Weeks:
            final diffDays = targetDate.difference(subscription.startDate).inDays;
            matchesSchedule = diffDays % 14 == 0;
            break;
          case SubscriptionFrequency.monthly:
            matchesSchedule = targetDate.day == 1 || targetDate.day == subscription.startDate.day;
            break;
        }

        if (matchesSchedule) {
          scheduledItems.add(item);
        }
      }

      // If at least one item is scheduled, generate the combined delivery (idempotently)
      if (scheduledItems.isNotEmpty) {
        double total = 0;
        for (final itm in scheduledItems) {
          total += itm.perDeliveryCost;
        }

        // Check if existing delivery already generated for this deterministic ID
        final existingIdx = _cachedDeliveries.indexWhere((d) => d.id == deterministicDeliveryId);
        final delivery = SubscriptionDelivery(
          id: deterministicDeliveryId,
          subscriptionId: subscription.id,
          userId: uid ?? subscription.userId,
          deliveryDate: targetDate,
          deliverySlot: subscription.deliverySlot,
          address: subscription.deliveryAddress,
          items: scheduledItems,
          totalAmount: total,
          status: existingIdx >= 0 && _cachedDeliveries[existingIdx].status == 'skipped'
              ? 'skipped'
              : 'pending',
          createdAt: DateTime.now(),
        );

        if (existingIdx >= 0) {
          // Update in-memory if already present, preserving skipped status
          _cachedDeliveries[existingIdx] = delivery;
        } else {
          _cachedDeliveries.add(delivery);
        }
        generated.add(delivery);

        if (db != null && uid != null && uid.isNotEmpty) {
          try {
            await db
                .collection('users')
                .doc(uid)
                .collection('subscription_deliveries')
                .doc(deterministicDeliveryId)
                .set(delivery.toMap(), SetOptions(merge: true));
          } catch (e) {
            debugPrint('SubscriptionRepository: generateUpcomingDeliveries set error: $e');
          }
        }
      }
    }

    return generated;
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }
}
