import '../../cart/domain/cart_item.dart';
import '../../checkout/domain/order_model.dart';

/// Delivery lifecycle stages for an active order
enum OrderStatus {
  placed('Order Placed', 'Order confirmed & sent to farm', 0),
  preparing('Preparing', 'Farm harvest & eco-packaging', 1),
  outForDelivery('Out for Delivery', 'On the way with Taaza Rider', 2),
  delivered('Delivered', 'Delivered to your doorstep', 3),
  cancelled('Cancelled', 'Order was cancelled', -1);

  final String title;
  final String description;
  final int stepIndex;

  const OrderStatus(this.title, this.description, this.stepIndex);

  bool get isActive => this == placed || this == preparing || this == outForDelivery;
  bool get isDelivered => this == delivered;
  bool get isCancelled => this == cancelled;
}

/// Timeline milestone with timestamp and details
class OrderTimelineStep {
  final OrderStatus status;
  final String time;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;

  const OrderTimelineStep({
    required this.status,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isCurrent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'time': time,
      'title': title,
      'subtitle': subtitle,
      'isCompleted': isCompleted,
      'isCurrent': isCurrent,
    };
  }

  factory OrderTimelineStep.fromMap(Map<String, dynamic> map) {
    final statusStr = map['status']?.toString() ?? '';
    final status = OrderStatus.values.firstWhere(
      (s) => s.name == statusStr || s.title.toLowerCase() == statusStr.toLowerCase(),
      orElse: () => OrderStatus.placed,
    );
    return OrderTimelineStep(
      status: status,
      time: map['time']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
      isCurrent: map['isCurrent'] == true,
    );
  }
}

/// Detailed Customer Order entity for Orders screen
class CustomerOrder {
  final String orderId;
  final DateTime orderDate;
  final String slotDate;
  final String timeSlot;
  final OrderStatus status;
  final List<CartItem> items;
  final double itemTotal;
  final double deliveryFee;
  final double discount;
  final double grandTotal;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final PaymentGateway? paymentGateway;
  final String? gatewayOrderId;
  final String? gatewayPaymentId;
  final DateTime? paidAt;
  final String? failureReason;
  final String? refundStatus;
  final String? refundId;
  final DateTime? refundedAt;
  final double? refundAmount;
  final String? refundFailureReason;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String? estimatedDeliveryTime;
  final int? userRating;
  final List<OrderTimelineStep> timeline;

  const CustomerOrder({
    required this.orderId,
    required this.orderDate,
    required this.slotDate,
    required this.timeSlot,
    required this.status,
    required this.items,
    required this.itemTotal,
    required this.deliveryFee,
    required this.discount,
    required this.grandTotal,
    required this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentGateway,
    this.gatewayOrderId,
    this.gatewayPaymentId,
    this.paidAt,
    this.failureReason,
    this.refundStatus,
    this.refundId,
    this.refundedAt,
    this.refundAmount,
    this.refundFailureReason,
    this.cancelledAt,
    this.cancellationReason,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    this.estimatedDeliveryTime,
    this.userRating,
    required this.timeline,
  });

  /// True if the order can safely be cancelled by customer (MVP policy: only 'placed' stage)
  bool get isCancellable => status == OrderStatus.placed;

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  String get itemsSummary {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) return items.first.product.name;
    if (items.length == 2) {
      return '${items[0].product.name}, ${items[1].product.name}';
    }
    return '${items[0].product.name}, ${items[1].product.name} +${items.length - 2} more';
  }

  CustomerOrder copyWith({
    String? orderId,
    DateTime? orderDate,
    String? slotDate,
    String? timeSlot,
    OrderStatus? status,
    List<CartItem>? items,
    double? itemTotal,
    double? deliveryFee,
    double? discount,
    double? grandTotal,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    PaymentGateway? paymentGateway,
    String? gatewayOrderId,
    String? gatewayPaymentId,
    DateTime? paidAt,
    String? failureReason,
    String? refundStatus,
    String? refundId,
    DateTime? refundedAt,
    double? refundAmount,
    String? refundFailureReason,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    String? estimatedDeliveryTime,
    int? userRating,
    List<OrderTimelineStep>? timeline,
  }) {
    return CustomerOrder(
      orderId: orderId ?? this.orderId,
      orderDate: orderDate ?? this.orderDate,
      slotDate: slotDate ?? this.slotDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      items: items ?? this.items,
      itemTotal: itemTotal ?? this.itemTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      gatewayOrderId: gatewayOrderId ?? this.gatewayOrderId,
      gatewayPaymentId: gatewayPaymentId ?? this.gatewayPaymentId,
      paidAt: paidAt ?? this.paidAt,
      failureReason: failureReason ?? this.failureReason,
      refundStatus: refundStatus ?? this.refundStatus,
      refundId: refundId ?? this.refundId,
      refundedAt: refundedAt ?? this.refundedAt,
      refundAmount: refundAmount ?? this.refundAmount,
      refundFailureReason: refundFailureReason ?? this.refundFailureReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
      deliveryPartnerPhone: deliveryPartnerPhone ?? this.deliveryPartnerPhone,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      userRating: userRating ?? this.userRating,
      timeline: timeline ?? this.timeline,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'orderId': orderId,
      'orderDate': orderDate.toIso8601String(),
      'slotDate': slotDate,
      'timeSlot': timeSlot,
      'status': status.name,
      'statusTitle': status.title,
      'items': items.map((item) => item.toMap()).toList(),
      'itemTotal': itemTotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod.name,
      'paymentMethodTitle': paymentMethod.title,
      'paymentStatus': paymentStatus.name,
      'paymentStatusTitle': paymentStatus.title,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'deliveryPartnerName': deliveryPartnerName,
      'deliveryPartnerPhone': deliveryPartnerPhone,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'userRating': userRating,
      'timeline': timeline.map((step) => step.toMap()).toList(),
      'isCompleted': status.isDelivered || status.isCancelled,
      'createdAt': orderDate.toIso8601String(),
    };

    if (paymentGateway != null) {
      map['paymentGateway'] = paymentGateway!.code;
    }
    if (gatewayOrderId != null) {
      map['gatewayOrderId'] = gatewayOrderId;
    }
    if (gatewayPaymentId != null) {
      map['gatewayPaymentId'] = gatewayPaymentId;
    }
    if (paidAt != null) {
      map['paidAt'] = paidAt!.toIso8601String();
    }
    if (failureReason != null) {
      map['failureReason'] = failureReason;
    }
    if (refundStatus != null) {
      map['refundStatus'] = refundStatus;
    }
    if (refundId != null) {
      map['refundId'] = refundId;
    }
    if (refundedAt != null) {
      map['refundedAt'] = refundedAt!.toIso8601String();
    }
    if (refundAmount != null) {
      map['refundAmount'] = refundAmount;
    }
    if (refundFailureReason != null) {
      map['refundFailureReason'] = refundFailureReason;
    }
    if (cancelledAt != null) {
      map['cancelledAt'] = cancelledAt!.toIso8601String();
    }
    if (cancellationReason != null) {
      map['cancellationReason'] = cancellationReason;
    }

    return map;
  }

  factory CustomerOrder.fromMap(Map<String, dynamic> map, [String? docId]) {
    final id = map['orderId']?.toString() ??
        (docId != null
            ? (docId.startsWith('#') ? docId : '#$docId')
            : '#FRSH-00000');

    DateTime? parseDateTime(dynamic raw) {
      if (raw == null) return null;
      if (raw is DateTime) return raw;
      try {
        if (raw.runtimeType.toString() == 'Timestamp' ||
            raw.toString().contains('Timestamp')) {
          return (raw as dynamic).toDate();
        }
        return DateTime.tryParse(raw.toString());
      } catch (_) {
        return null;
      }
    }

    final parsedDate = parseDateTime(map['orderDate']) ??
        parseDateTime(map['createdAt']) ??
        DateTime.now();

    final statusStr = map['status']?.toString() ?? '';
    final status = OrderStatus.values.firstWhere(
      (s) =>
          s.name == statusStr ||
          s.title.toLowerCase() == statusStr.toLowerCase(),
      orElse: () => OrderStatus.placed,
    );

    final paymentStr = map['paymentMethod']?.toString() ?? '';
    final payment = PaymentMethod.values.firstWhere(
      (p) =>
          p.name == paymentStr ||
          p.title.toLowerCase() == paymentStr.toLowerCase(),
      orElse: () => PaymentMethod.cashOnDelivery,
    );

    // Payment status parsing with safe default
    final paymentStatusStr = map['paymentStatus']?.toString();
    final PaymentStatus paymentStatus;
    if (paymentStatusStr != null && paymentStatusStr.isNotEmpty) {
      paymentStatus = PaymentStatus.fromString(paymentStatusStr);
    } else {
      // Historical COD orders default to pending
      paymentStatus = PaymentStatus.pending;
    }

    // Payment gateway parsing with safe default for COD
    final paymentGatewayStr = map['paymentGateway']?.toString();
    final PaymentGateway? paymentGateway;
    if (paymentGatewayStr != null && paymentGatewayStr.isNotEmpty) {
      paymentGateway = PaymentGateway.fromString(paymentGatewayStr);
    } else if (payment == PaymentMethod.cashOnDelivery) {
      paymentGateway = PaymentGateway.cod;
    } else {
      paymentGateway = null;
    }

    final rawItems = map['items'];
    final List<CartItem> parsedItems = [];
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map<String, dynamic>) {
          parsedItems.add(CartItem.fromMap(it));
        } else if (it is Map) {
          parsedItems.add(CartItem.fromMap(Map<String, dynamic>.from(it)));
        }
      }
    }

    final rawTimeline = map['timeline'];
    final List<OrderTimelineStep> parsedTimeline = [];
    if (rawTimeline is List) {
      for (final step in rawTimeline) {
        if (step is Map<String, dynamic>) {
          parsedTimeline.add(OrderTimelineStep.fromMap(step));
        } else if (step is Map) {
          parsedTimeline.add(
              OrderTimelineStep.fromMap(Map<String, dynamic>.from(step)));
        }
      }
    }

    final timelineList = parsedTimeline.isNotEmpty
        ? parsedTimeline
        : _buildDefaultTimeline(
            status,
            parsedDate,
            map['timeSlot']?.toString() ?? '6:00 AM – 8:00 AM',
          );

    double? parseCoord(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return CustomerOrder(
      orderId: id,
      orderDate: parsedDate,
      slotDate: map['slotDate']?.toString() ?? 'Today',
      timeSlot: map['timeSlot']?.toString() ?? '6:00 AM – 8:00 AM',
      status: status,
      items: parsedItems,
      itemTotal: (map['itemTotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grandTotal'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: payment,
      paymentStatus: paymentStatus,
      paymentGateway: paymentGateway,
      gatewayOrderId: map['gatewayOrderId']?.toString(),
      gatewayPaymentId: map['gatewayPaymentId']?.toString(),
      paidAt: parseDateTime(map['paidAt']),
      failureReason: map['failureReason']?.toString(),
      refundStatus: map['refundStatus']?.toString(),
      refundId: map['refundId']?.toString(),
      refundedAt: parseDateTime(map['refundedAt']),
      refundAmount: (map['refundAmount'] as num?)?.toDouble(),
      refundFailureReason: map['refundFailureReason']?.toString(),
      cancelledAt: parseDateTime(map['cancelledAt']),
      cancellationReason: map['cancellationReason']?.toString(),
      deliveryAddress: map['deliveryAddress']?.toString() ?? '',
      deliveryLatitude: parseCoord(map['deliveryLatitude']),
      deliveryLongitude: parseCoord(map['deliveryLongitude']),
      deliveryPartnerName: map['deliveryPartnerName']?.toString(),
      deliveryPartnerPhone: map['deliveryPartnerPhone']?.toString(),
      estimatedDeliveryTime: map['estimatedDeliveryTime']?.toString(),
      userRating: (map['userRating'] as num?)?.toInt(),
      timeline: timelineList,
    );
  }

  static List<OrderTimelineStep> _buildDefaultTimeline(
      OrderStatus status, DateTime date, String slot) {
    final timeFormatted =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return [
      OrderTimelineStep(
        status: OrderStatus.placed,
        time: timeFormatted,
        title: 'Order Placed & Confirmed',
        subtitle: 'Payment verified & order sent to farm',
        isCompleted: true,
        isCurrent: status == OrderStatus.placed,
      ),
      OrderTimelineStep(
        status: OrderStatus.preparing,
        time: 'Harvest & Pack',
        title: 'Sunrise Farm Harvest',
        subtitle: 'Sorted, quality-checked and temperature-packed',
        isCompleted: status == OrderStatus.preparing ||
            status == OrderStatus.outForDelivery ||
            status == OrderStatus.delivered,
        isCurrent: status == OrderStatus.preparing,
      ),
      OrderTimelineStep(
        status: OrderStatus.outForDelivery,
        time: slot,
        title: 'Out for Delivery',
        subtitle: 'Taaza rider on the way',
        isCompleted: status == OrderStatus.outForDelivery ||
            status == OrderStatus.delivered,
        isCurrent: status == OrderStatus.outForDelivery,
      ),
      OrderTimelineStep(
        status: OrderStatus.delivered,
        time: 'Doorstep Drop',
        title: 'Delivered',
        subtitle: 'Contactless eco-bag delivery completed',
        isCompleted: status == OrderStatus.delivered,
        isCurrent: status == OrderStatus.delivered,
      ),
    ];
  }
}
