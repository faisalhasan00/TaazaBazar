import '../../cart/domain/cart_item.dart';
import '../../checkout/domain/order_model.dart';
import '../../products/data/mock_products_data.dart';
import '../domain/customer_order.dart';

/// Repository of realistic mock customer orders for Freshly
class MockOrdersData {
  MockOrdersData._();

  static List<CustomerOrder> getActiveOrders() {
    final products = MockProductsData.allProducts;
    
    final tomato = products.firstWhere((p) => p.id == 'v_tomato', orElse: () => products[0]);
    final spinach = products.firstWhere((p) => p.id == 'v_spinach', orElse: () => products[1]);
    final milk = products.firstWhere((p) => p.id == 'd_cow_milk', orElse: () => products[2]);
    final apple = products.firstWhere((p) => p.id == 'f_apple', orElse: () => products[3]);
    final eggs = products.firstWhere((p) => p.id == 'e_brown_eggs', orElse: () => products[4]);

    return [
      CustomerOrder(
        orderId: '#FRSH-89421',
        orderDate: DateTime.now().subtract(const Duration(hours: 2)),
        slotDate: 'Today (Sun, 13 Sep)',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.outForDelivery,
        items: [
          CartItem(product: spinach, quantity: 2),
          CartItem(product: tomato, quantity: 1),
          CartItem(product: milk, quantity: 2),
        ],
        itemTotal: 290.0,
        deliveryFee: 0.0,
        discount: 50.0,
        grandTotal: 240.0,
        paymentMethod: PaymentMethod.upi,
        deliveryAddress: 'Flat 402, Green Valley Apartments, Indiranagar, Bengaluru, 560038',
        deliveryPartnerName: 'Ramesh Kumar',
        deliveryPartnerPhone: '+91 98765 12340',
        estimatedDeliveryTime: '15 mins (7:45 AM)',
        timeline: const [
          OrderTimelineStep(
            status: OrderStatus.placed,
            time: '5:30 AM',
            title: 'Order Placed & Confirmed',
            subtitle: 'Payment verified via Instant UPI',
            isCompleted: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.preparing,
            time: '6:15 AM',
            title: 'Harvested & Packed',
            subtitle: 'Sunrise Organic Farm, Shadnagar Hub',
            isCompleted: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.outForDelivery,
            time: '7:10 AM',
            title: 'Out for Delivery',
            subtitle: 'Ramesh is 2.4 km away from your doorstep',
            isCompleted: true,
            isCurrent: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.delivered,
            time: '7:45 AM (Est.)',
            title: 'Delivered',
            subtitle: 'Doorstep contactless handoff',
            isCompleted: false,
          ),
        ],
      ),
      CustomerOrder(
        orderId: '#FRSH-90142',
        orderDate: DateTime.now().subtract(const Duration(hours: 1)),
        slotDate: 'Today (Sun, 13 Sep)',
        timeSlot: '5:00 PM – 7:00 PM',
        status: OrderStatus.preparing,
        items: [
          CartItem(product: apple, quantity: 1),
          CartItem(product: eggs, quantity: 1),
        ],
        itemTotal: 280.0,
        deliveryFee: 0.0,
        discount: 0.0,
        grandTotal: 280.0,
        paymentMethod: PaymentMethod.cashOnDelivery,
        deliveryAddress: 'Flat 402, Green Valley Apartments, Indiranagar, Bengaluru, 560038',
        estimatedDeliveryTime: 'Today by 6:15 PM',
        timeline: const [
          OrderTimelineStep(
            status: OrderStatus.placed,
            time: '11:00 AM',
            title: 'Order Placed',
            subtitle: 'Pay via Cash or UPI at doorstep',
            isCompleted: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.preparing,
            time: '11:45 AM',
            title: 'Preparing Harvest',
            subtitle: 'Quality check & temperature-safe packing',
            isCompleted: true,
            isCurrent: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.outForDelivery,
            time: '5:15 PM (Est.)',
            title: 'Out for Delivery',
            subtitle: 'Delivery partner assigned soon',
            isCompleted: false,
          ),
          OrderTimelineStep(
            status: OrderStatus.delivered,
            time: '6:15 PM (Est.)',
            title: 'Delivered',
            subtitle: 'Doorstep morning drop',
            isCompleted: false,
          ),
        ],
      ),
    ];
  }

  static List<CustomerOrder> getPreviousOrders() {
    final products = MockProductsData.allProducts;
    
    final tomato = products.firstWhere((p) => p.id == 'v_tomato', orElse: () => products[0]);
    final spinach = products.firstWhere((p) => p.id == 'v_spinach', orElse: () => products[1]);
    final milk = products.firstWhere((p) => p.id == 'd_cow_milk', orElse: () => products[2]);
    final apple = products.firstWhere((p) => p.id == 'f_apple', orElse: () => products[3]);
    final carrot = products.firstWhere((p) => p.id == 'v_carrot', orElse: () => products[4]);
    final eggs = products.firstWhere((p) => p.id == 'e_brown_eggs', orElse: () => products[0]);

    return [
      CustomerOrder(
        orderId: '#FRSH-74109',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        slotDate: 'Yesterday (Sat, 12 Sep)',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.delivered,
        items: [
          CartItem(product: tomato, quantity: 2),
          CartItem(product: carrot, quantity: 1),
          CartItem(product: milk, quantity: 1),
          CartItem(product: spinach, quantity: 1),
        ],
        itemTotal: 345.0,
        deliveryFee: 0.0,
        discount: 30.0,
        grandTotal: 315.0,
        paymentMethod: PaymentMethod.upi,
        deliveryAddress: 'Flat 402, Green Valley Apartments, Indiranagar, Bengaluru, 560038',
        deliveryPartnerName: 'Suresh Patil',
        userRating: 5,
        timeline: const [
          OrderTimelineStep(
            status: OrderStatus.placed,
            time: '11 Sep, 8:30 PM',
            title: 'Order Placed',
            subtitle: 'Confirmed & paid',
            isCompleted: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.preparing,
            time: '12 Sep, 4:30 AM',
            title: 'Farm Harvested',
            subtitle: 'Sorted & packed',
            isCompleted: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.outForDelivery,
            time: '12 Sep, 6:40 AM',
            title: 'Out for Delivery',
            subtitle: 'With Suresh Patil',
            isCompleted: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.delivered,
            time: '12 Sep, 7:15 AM',
            title: 'Delivered',
            subtitle: 'Handed over at doorstep',
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      ),
      CustomerOrder(
        orderId: '#FRSH-68210',
        orderDate: DateTime.now().subtract(const Duration(days: 3)),
        slotDate: 'Thu, 10 Sep',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.delivered,
        items: [
          CartItem(product: apple, quantity: 2),
          CartItem(product: eggs, quantity: 1),
          CartItem(product: milk, quantity: 2),
        ],
        itemTotal: 520.0,
        deliveryFee: 0.0,
        discount: 50.0,
        grandTotal: 470.0,
        paymentMethod: PaymentMethod.card,
        deliveryAddress: 'Flat 402, Green Valley Apartments, Indiranagar, Bengaluru, 560038',
        deliveryPartnerName: 'Anand V.',
        userRating: 5,
        timeline: const [
          OrderTimelineStep(
            status: OrderStatus.placed,
            time: '9 Sep, 9:15 PM',
            title: 'Order Placed',
            subtitle: 'Paid with HDFC Card',
            isCompleted: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.delivered,
            time: '10 Sep, 7:05 AM',
            title: 'Delivered',
            subtitle: 'Fresh delivery completed',
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      ),
      CustomerOrder(
        orderId: '#FRSH-59301',
        orderDate: DateTime.now().subtract(const Duration(days: 7)),
        slotDate: 'Sun, 6 Sep',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.delivered,
        items: [
          CartItem(product: spinach, quantity: 3),
          CartItem(product: tomato, quantity: 2),
        ],
        itemTotal: 185.0,
        deliveryFee: 0.0,
        discount: 0.0,
        grandTotal: 185.0,
        paymentMethod: PaymentMethod.upi,
        deliveryAddress: 'Flat 402, Green Valley Apartments, Indiranagar, Bengaluru, 560038',
        userRating: 4,
        timeline: const [
          OrderTimelineStep(
            status: OrderStatus.placed,
            time: '5 Sep, 10:00 PM',
            title: 'Order Placed',
            subtitle: 'UPI Payment',
            isCompleted: true,
          ),
          OrderTimelineStep(
            status: OrderStatus.delivered,
            time: '6 Sep, 7:20 AM',
            title: 'Delivered',
            subtitle: 'Morning delivery completed',
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      ),
    ];
  }
}
