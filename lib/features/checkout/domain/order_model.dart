import '../../cart/domain/cart_item.dart';

/// Payment method enum for Freshly checkout
enum PaymentMethod {
  cashOnDelivery('Cash on Delivery', '💵', 'Pay via Cash or UPI at your doorstep'),
  upi('Instant UPI', '⚡', 'Google Pay, PhonePe, Paytm & BHIM'),
  card('Credit / Debit Card', '💳', 'Visa, Mastercard, RuPay & Diners'),
  netBanking('Net Banking', '🏦', 'All Indian Major Banks Supported');

  final String title;
  final String icon;
  final String subtitle;

  const PaymentMethod(this.title, this.icon, this.subtitle);
}

/// Payment status enum for order payment lifecycle
enum PaymentStatus {
  pending('Pending', 'Payment is pending'),
  paid('Paid', 'Payment completed successfully'),
  failed('Failed', 'Payment failed or declined'),
  refunded('Refunded', 'Payment refunded to original source'),
  cancelled('Cancelled', 'Payment cancelled');

  final String title;
  final String description;

  const PaymentStatus(this.title, this.description);

  bool get isPending => this == PaymentStatus.pending;
  bool get isPaid => this == PaymentStatus.paid;
  bool get isFailed => this == PaymentStatus.failed;
  bool get isRefunded => this == PaymentStatus.refunded;
  bool get isCancelled => this == PaymentStatus.cancelled;

  static PaymentStatus fromString(
    String? val, {
    PaymentStatus defaultStatus = PaymentStatus.pending,
  }) {
    if (val == null || val.trim().isEmpty) return defaultStatus;
    final clean = val.trim().toLowerCase();
    for (final status in PaymentStatus.values) {
      if (status.name.toLowerCase() == clean ||
          status.title.toLowerCase() == clean) {
        return status;
      }
    }
    return defaultStatus;
  }
}

/// Supported payment gateways / processors
enum PaymentGateway {
  cod('Cash on Delivery', 'cod'),
  razorpay('Razorpay', 'razorpay'),
  stripe('Stripe', 'stripe');

  final String title;
  final String code;

  const PaymentGateway(this.title, this.code);

  static PaymentGateway? fromString(
    String? val, {
    PaymentGateway? defaultGateway,
  }) {
    if (val == null || val.trim().isEmpty) return defaultGateway;
    final clean = val.trim().toLowerCase();
    for (final gateway in PaymentGateway.values) {
      if (gateway.name.toLowerCase() == clean ||
          gateway.code.toLowerCase() == clean ||
          gateway.title.toLowerCase() == clean) {
        return gateway;
      }
    }
    return defaultGateway;
  }
}

/// Delivery slot model
class DeliverySlot {
  final String date;
  final String timeRange;
  final String label;
  final bool isPopular;

  const DeliverySlot({
    required this.date,
    required this.timeRange,
    required this.label,
    this.isPopular = false,
  });

  String get fullDisplayText => '$date • $timeRange';
}

/// Placed Order Model
class TaazaOrder {
  final String orderId;
  final List<CartItem> items;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final DeliverySlot slot;
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
  final double itemTotal;
  final double deliveryFee;
  final double couponDiscount;
  final double grandTotal;
  final DateTime orderTime;

  const TaazaOrder({
    required this.orderId,
    required this.items,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.slot,
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
    required this.itemTotal,
    required this.deliveryFee,
    required this.couponDiscount,
    required this.grandTotal,
    required this.orderTime,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);
}

/// Backwards compatibility alias
typedef FreshlyOrder = TaazaOrder;

