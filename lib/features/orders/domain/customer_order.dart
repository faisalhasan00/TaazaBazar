import '../../cart/domain/cart_item.dart';
import '../../checkout/domain/order_model.dart';

/// Delivery lifecycle stages for an active order
enum OrderStatus {
  placed('Order Placed', 'Order confirmed & sent to farm', 0),
  preparing('Preparing', 'Farm harvest & eco-packaging', 1),
  outForDelivery('Out for Delivery', 'On the way with Freshly Rider', 2),
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
  final String deliveryAddress;
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
    required this.deliveryAddress,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    this.estimatedDeliveryTime,
    this.userRating,
    required this.timeline,
  });

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  String get itemsSummary {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) return items.first.product.name;
    if (items.length == 2) {
      return '${items[0].product.name}, ${items[1].product.name}';
    }
    return '${items[0].product.name}, ${items[1].product.name} +${items.length - 2} more';
  }
}
