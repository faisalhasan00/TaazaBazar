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
class FreshlyOrder {
  final String orderId;
  final List<CartItem> items;
  final String deliveryAddress;
  final DeliverySlot slot;
  final PaymentMethod paymentMethod;
  final double itemTotal;
  final double deliveryFee;
  final double couponDiscount;
  final double grandTotal;
  final DateTime orderTime;

  const FreshlyOrder({
    required this.orderId,
    required this.items,
    required this.deliveryAddress,
    required this.slot,
    required this.paymentMethod,
    required this.itemTotal,
    required this.deliveryFee,
    required this.couponDiscount,
    required this.grandTotal,
    required this.orderTime,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);
}
