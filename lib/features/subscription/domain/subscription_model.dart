import 'package:flutter/material.dart';

/// Supported subscription plan types
enum SubscriptionPlanType {
  readyMade('Ready-Made Plan', 'Pre-configured daily or weekly essentials'),
  familyFresh('Family Fresh Plan', 'Complete household bundle tailored to your family size'),
  buildYourOwn('Build Your Own', 'Fully customized recurring basket with independent item schedules');

  final String title;
  final String description;
  const SubscriptionPlanType(this.title, this.description);
}

/// Status of an entire subscription
enum SubscriptionStatus {
  active('Active', Color(0xFF166534), Color(0xFFDCFCE7)),
  paused('Paused', Color(0xFFD97706), Color(0xFFFEF3C7)),
  cancelled('Cancelled', Color(0xFFDC2626), Color(0xFFFEE2E2));

  final String label;
  final Color textColor;
  final Color bgColor;
  const SubscriptionStatus(this.label, this.textColor, this.bgColor);

  bool get isActive => this == active;
  bool get isPaused => this == paused;
  bool get isCancelled => this == cancelled;
}

/// Delivery frequency for individual items in a subscription
enum SubscriptionFrequency {
  daily('Daily', 'Every morning', 30),
  alternateDays('Alternate Days', 'Every other day', 15),
  weekly('Weekly', 'Once a week on your chosen day', 4.33),
  every2Weeks('Every 2 Weeks', 'Bi-weekly delivery', 2.16),
  monthly('Monthly', '1st of every month', 1.0);

  final String label;
  final String subtitle;
  final double monthlyMultiplier;
  const SubscriptionFrequency(this.label, this.subtitle, this.monthlyMultiplier);
}

/// Item pricing strategy
enum SubscriptionPriceType {
  fixed('Fixed Price'),
  basketValue('Dynamic Basket Value');

  final String label;
  const SubscriptionPriceType(this.label);
}

/// Status of an individual subscription item
enum SubscriptionItemStatus {
  active('Active'),
  paused('Paused'),
  skipped('Skipped for Next Delivery');

  final String label;
  const SubscriptionItemStatus(this.label);
}

/// Model for an individual recurring item within a subscription
class SubscriptionItem {
  final String id;
  final String subscriptionId;
  final String productId;
  final String productName;
  final String categoryId;
  final String categoryName;
  final String emoji;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final SubscriptionFrequency frequency;
  final String deliveryDay; // e.g., 'Daily', 'Monday', 'Sunday', '1st of Month'
  final DateTime startDate;
  final DateTime nextDeliveryDate;
  final SubscriptionItemStatus status;
  final SubscriptionPriceType priceType;
  final double? basketValue;
  final bool isOneTimeAddOn;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionItem({
    required this.id,
    required this.subscriptionId,
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.frequency,
    this.deliveryDay = 'Daily',
    required this.startDate,
    required this.nextDeliveryDate,
    this.status = SubscriptionItemStatus.active,
    this.priceType = SubscriptionPriceType.fixed,
    this.basketValue,
    this.isOneTimeAddOn = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cost for single delivery occurrence
  double get perDeliveryCost {
    if (priceType == SubscriptionPriceType.basketValue && basketValue != null) {
      return basketValue!;
    }
    return pricePerUnit * quantity;
  }

  /// Estimated monthly cost contribution
  double get estimatedMonthlyCost {
    if (status == SubscriptionItemStatus.paused) return 0.0;
    if (isOneTimeAddOn) return perDeliveryCost;
    return perDeliveryCost * frequency.monthlyMultiplier;
  }

  SubscriptionItem copyWith({
    String? id,
    String? subscriptionId,
    String? productId,
    String? productName,
    String? categoryId,
    String? categoryName,
    String? emoji,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    SubscriptionFrequency? frequency,
    String? deliveryDay,
    DateTime? startDate,
    DateTime? nextDeliveryDate,
    SubscriptionItemStatus? status,
    SubscriptionPriceType? priceType,
    double? basketValue,
    bool? isOneTimeAddOn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionItem(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      emoji: emoji ?? this.emoji,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      frequency: frequency ?? this.frequency,
      deliveryDay: deliveryDay ?? this.deliveryDay,
      startDate: startDate ?? this.startDate,
      nextDeliveryDate: nextDeliveryDate ?? this.nextDeliveryDate,
      status: status ?? this.status,
      priceType: priceType ?? this.priceType,
      basketValue: basketValue ?? this.basketValue,
      isOneTimeAddOn: isOneTimeAddOn ?? this.isOneTimeAddOn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'productId': productId,
      'productName': productName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'emoji': emoji,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'frequency': frequency.name,
      'deliveryDay': deliveryDay,
      'startDate': startDate.toIso8601String(),
      'nextDeliveryDate': nextDeliveryDate.toIso8601String(),
      'status': status.name,
      'priceType': priceType.name,
      'basketValue': basketValue,
      'isOneTimeAddOn': isOneTimeAddOn,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SubscriptionItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    final freqStr = map['frequency']?.toString() ?? 'daily';
    final freq = SubscriptionFrequency.values.firstWhere(
      (f) => f.name == freqStr,
      orElse: () => SubscriptionFrequency.daily,
    );

    final statusStr = map['status']?.toString() ?? 'active';
    final status = SubscriptionItemStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => SubscriptionItemStatus.active,
    );

    final priceTypeStr = map['priceType']?.toString() ?? 'fixed';
    final priceType = SubscriptionPriceType.values.firstWhere(
      (p) => p.name == priceTypeStr,
      orElse: () => SubscriptionPriceType.fixed,
    );

    return SubscriptionItem(
      id: docId ?? map['id']?.toString() ?? '',
      subscriptionId: map['subscriptionId']?.toString() ?? '',
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',
      emoji: map['emoji']?.toString() ?? '🥛',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit']?.toString() ?? '1L',
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      frequency: freq,
      deliveryDay: map['deliveryDay']?.toString() ?? 'Daily',
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      nextDeliveryDate: map['nextDeliveryDate'] != null
          ? DateTime.tryParse(map['nextDeliveryDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: status,
      priceType: priceType,
      basketValue: (map['basketValue'] as num?)?.toDouble(),
      isOneTimeAddOn: map['isOneTimeAddOn'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Overall Customer Subscription Model
class SubscriptionModel {
  final String id;
  final String userId;
  final String name;
  String get planName => name;
  final SubscriptionPlanType planType;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime nextDeliveryDate;
  final String deliveryAddressId;
  final String deliveryAddress;
  final String deliverySlot;
  final double estimatedMonthlyAmount;
  final String paymentMode;
  final List<SubscriptionItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  SubscriptionModel({
    required this.id,
    required this.userId,
    String? name,
    String? planName,
    required this.planType,
    this.status = SubscriptionStatus.active,
    required this.startDate,
    required this.nextDeliveryDate,
    this.deliveryAddressId = '',
    required this.deliveryAddress,
    this.deliverySlot = '6:00 AM – 8:00 AM',
    required this.estimatedMonthlyAmount,
    this.paymentMode = 'Prepaid Wallet / Card',
    this.items = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.cancelledAt,
    this.cancellationReason,
  })  : name = name ?? planName ?? 'My Subscription',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Recalculates estimated monthly spend from items
  double calculateEstimatedMonthlySpend() {
    double total = 0;
    for (final item in items) {
      if (item.status == SubscriptionItemStatus.active && !item.isOneTimeAddOn) {
        total += item.estimatedMonthlyCost;
      }
    }
    return total;
  }

  /// Single upcoming delivery amount
  double get nextDeliveryAmount {
    double total = 0;
    for (final item in items) {
      if (item.status == SubscriptionItemStatus.active) {
        total += item.perDeliveryCost;
      }
    }
    return total;
  }

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? name,
    SubscriptionPlanType? planType,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? nextDeliveryDate,
    String? deliveryAddressId,
    String? deliveryAddress,
    String? deliverySlot,
    double? estimatedMonthlyAmount,
    String? paymentMode,
    List<SubscriptionItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      planType: planType ?? this.planType,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      nextDeliveryDate: nextDeliveryDate ?? this.nextDeliveryDate,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliverySlot: deliverySlot ?? this.deliverySlot,
      estimatedMonthlyAmount: estimatedMonthlyAmount ?? this.estimatedMonthlyAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'planType': planType.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'nextDeliveryDate': nextDeliveryDate.toIso8601String(),
      'deliveryAddressId': deliveryAddressId,
      'deliveryAddress': deliveryAddress,
      'deliverySlot': deliverySlot,
      'estimatedMonthlyAmount': estimatedMonthlyAmount,
      'paymentMode': paymentMode,
      'items': items.map((i) => i.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final planTypeStr = map['planType']?.toString() ?? 'buildYourOwn';
    final planType = SubscriptionPlanType.values.firstWhere(
      (p) => p.name == planTypeStr,
      orElse: () => SubscriptionPlanType.buildYourOwn,
    );

    final statusStr = map['status']?.toString() ?? 'active';
    final status = SubscriptionStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => SubscriptionStatus.active,
    );

    final rawItems = map['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => SubscriptionItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return SubscriptionModel(
      id: docId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'My Daily Essentials',
      planType: planType,
      status: status,
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      nextDeliveryDate: map['nextDeliveryDate'] != null
          ? DateTime.tryParse(map['nextDeliveryDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      deliveryAddressId: map['deliveryAddressId']?.toString() ?? '',
      deliveryAddress: map['deliveryAddress']?.toString() ?? '',
      deliverySlot: map['deliverySlot']?.toString() ?? '6:00 AM – 8:00 AM',
      estimatedMonthlyAmount: (map['estimatedMonthlyAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: map['paymentMode']?.toString() ?? 'Prepaid Wallet / Card',
      items: items,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.tryParse(map['cancelledAt'].toString())
          : null,
      cancellationReason: map['cancellationReason']?.toString(),
    );
  }
}

/// Model for a combined scheduled subscription delivery (e.g. "Tomorrow's Fresh Basket")
class SubscriptionDelivery {
  final String id;
  final String subscriptionId;
  final String userId;
  final DateTime deliveryDate;
  final String deliverySlot;
  final String address;
  final List<SubscriptionItem> items;
  final double totalAmount;
  final String status; // 'pending', 'preparing', 'outForDelivery', 'delivered', 'skipped', 'cancelled'
  final String? orderId;
  final DateTime createdAt;

  const SubscriptionDelivery({
    required this.id,
    required this.subscriptionId,
    required this.userId,
    required this.deliveryDate,
    required this.deliverySlot,
    required this.address,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.orderId,
    required this.createdAt,
  });

  bool get isSkipped => status == 'skipped';
  bool get isDelivered => status == 'delivered';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'userId': userId,
      'deliveryDate': deliveryDate.toIso8601String(),
      'deliverySlot': deliverySlot,
      'address': address,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderId': orderId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubscriptionDelivery.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => SubscriptionItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return SubscriptionDelivery(
      id: docId ?? map['id']?.toString() ?? '',
      subscriptionId: map['subscriptionId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      deliveryDate: map['deliveryDate'] != null
          ? DateTime.tryParse(map['deliveryDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      deliverySlot: map['deliverySlot']?.toString() ?? '6:00 AM – 8:00 AM',
      address: map['address']?.toString() ?? '',
      items: items,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? 'pending',
      orderId: map['orderId']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
