import 'package:cloud_firestore/cloud_firestore.dart';

/// Supported push and in-app notification types for TaazaBazar
enum NotificationType {
  orderPlaced('order_placed', 'Order Placed'),
  paymentSuccess('payment_success', 'Payment Successful'),
  paymentFailed('payment_failed', 'Payment Failed'),
  orderPreparing('order_preparing', 'Preparing Order'),
  orderOutForDelivery('order_out_for_delivery', 'Out for Delivery'),
  orderDelivered('order_delivered', 'Order Delivered'),
  orderCancelled('order_cancelled', 'Order Cancelled'),
  refundPending('refund_pending', 'Refund Processing'),
  refundProcessed('refund_processed', 'Refund Completed'),
  refundFailed('refund_failed', 'Refund Issue'),
  morningHarvest('morning_harvest', 'Morning Harvest'),
  promo('promo', 'Special Offer'),
  general('general', 'TaazaBazar Alert');

  final String code;
  final String label;

  const NotificationType(this.code, this.label);

  static NotificationType fromString(String? val) {
    if (val == null || val.trim().isEmpty) return NotificationType.general;
    final clean = val.trim().toLowerCase();
    for (final type in NotificationType.values) {
      if (type.code.toLowerCase() == clean ||
          type.name.toLowerCase() == clean ||
          type.label.toLowerCase() == clean) {
        return type;
      }
    }
    return NotificationType.general;
  }
}

/// Represents a trusted server-generated notification item in the customer's notification history
class CustomerNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? orderId;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  const CustomerNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.orderId,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  CustomerNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? orderId,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return CustomerNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.code,
      'orderId': orderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': isRead,
      if (data != null) 'data': data,
    };
  }

  factory CustomerNotification.fromMap(String id, Map<String, dynamic> map) {
    DateTime createdDate;
    final rawDate = map['createdAt'];
    if (rawDate is Timestamp) {
      createdDate = rawDate.toDate();
    } else if (rawDate is String) {
      createdDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      createdDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      createdDate = DateTime.now();
    }

    return CustomerNotification(
      id: id,
      title: map['title']?.toString() ?? 'TaazaBazar Alert',
      body: map['body']?.toString() ?? '',
      type: NotificationType.fromString(map['type']?.toString()),
      orderId: map['orderId']?.toString(),
      createdAt: createdDate,
      isRead: map['read'] == true,
      data: map['data'] is Map<String, dynamic> ? map['data'] as Map<String, dynamic> : null,
    );
  }
}
