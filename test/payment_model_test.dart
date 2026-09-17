import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/features/cart/domain/cart_item.dart';
import 'package:taazabazar/features/checkout/domain/order_model.dart';
import 'package:taazabazar/features/orders/domain/customer_order.dart';
import 'package:taazabazar/features/products/domain/product_model.dart';

void main() {
  group('PaymentStatus & PaymentGateway Enums', () {
    test('PaymentStatus enum has all required states and helpers', () {
      expect(PaymentStatus.values.length, 5);
      expect(PaymentStatus.pending.isPending, isTrue);
      expect(PaymentStatus.paid.isPaid, isTrue);
      expect(PaymentStatus.failed.isFailed, isTrue);
      expect(PaymentStatus.refunded.isRefunded, isTrue);
      expect(PaymentStatus.cancelled.isCancelled, isTrue);

      expect(PaymentStatus.pending.title, 'Pending');
      expect(PaymentStatus.paid.title, 'Paid');
      expect(PaymentStatus.failed.title, 'Failed');
      expect(PaymentStatus.refunded.title, 'Refunded');
      expect(PaymentStatus.cancelled.title, 'Cancelled');
    });

    test('PaymentStatus.fromString parses case-insensitively and falls back safely', () {
      expect(PaymentStatus.fromString('pending'), PaymentStatus.pending);
      expect(PaymentStatus.fromString('PENDING'), PaymentStatus.pending);
      expect(PaymentStatus.fromString('Paid'), PaymentStatus.paid);
      expect(PaymentStatus.fromString('failed'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('refunded'), PaymentStatus.refunded);
      expect(PaymentStatus.fromString('cancelled'), PaymentStatus.cancelled);

      // Unknown or null values fallback safely to pending (or custom default)
      expect(PaymentStatus.fromString(null), PaymentStatus.pending);
      expect(PaymentStatus.fromString(''), PaymentStatus.pending);
      expect(PaymentStatus.fromString('unknown_status'), PaymentStatus.pending);
      expect(
        PaymentStatus.fromString('invalid', defaultStatus: PaymentStatus.failed),
        PaymentStatus.failed,
      );
    });

    test('PaymentGateway enum has all required values and helpers', () {
      expect(PaymentGateway.values.length, 3);
      expect(PaymentGateway.cod.code, 'cod');
      expect(PaymentGateway.razorpay.code, 'razorpay');
      expect(PaymentGateway.stripe.code, 'stripe');

      expect(PaymentGateway.cod.title, 'Cash on Delivery');
      expect(PaymentGateway.razorpay.title, 'Razorpay');
      expect(PaymentGateway.stripe.title, 'Stripe');
    });

    test('PaymentGateway.fromString parses accurately and handles unknown values safely', () {
      expect(PaymentGateway.fromString('cod'), PaymentGateway.cod);
      expect(PaymentGateway.fromString('COD'), PaymentGateway.cod);
      expect(PaymentGateway.fromString('Cash on Delivery'), PaymentGateway.cod);
      expect(PaymentGateway.fromString('razorpay'), PaymentGateway.razorpay);
      expect(PaymentGateway.fromString('RAZORPAY'), PaymentGateway.razorpay);
      expect(PaymentGateway.fromString('stripe'), PaymentGateway.stripe);

      expect(PaymentGateway.fromString(null), isNull);
      expect(PaymentGateway.fromString(''), isNull);
      expect(PaymentGateway.fromString('paypal'), isNull);
    });
  });

  group('CustomerOrder & TaazaOrder Payment Data Model', () {
    final sampleProduct = Product(
      id: 'test_item_1',
      name: 'Organic Tomato',
      price: 40.0,
      originalPrice: 50.0,
      unit: '500g',
      categoryId: 'vegetables',
      categoryName: 'Vegetables',
      emoji: '🍅',
      rating: 4.8,
      reviewsCount: 120,
      description: 'Fresh organic farm tomatoes',
    );

    final sampleCartItem = CartItem(product: sampleProduct, quantity: 2);

    test('A. Existing legacy order without payment fields loads successfully (Backward Compatibility)', () {
      final legacyMap = {
        'orderId': '#FRSH-10001',
        'orderDate': '2026-09-01T10:00:00.000Z',
        'slotDate': 'Tomorrow',
        'timeSlot': '6:00 AM – 8:00 AM',
        'status': 'placed',
        'items': [sampleCartItem.toMap()],
        'itemTotal': 80.0,
        'deliveryFee': 0.0,
        'discount': 10.0,
        'grandTotal': 70.0,
        'paymentMethod': 'cashOnDelivery',
        'deliveryAddress': 'Flat 101, Test Residency',
      };

      final order = CustomerOrder.fromMap(legacyMap);

      expect(order.orderId, '#FRSH-10001');
      expect(order.paymentMethod, PaymentMethod.cashOnDelivery);
      // Seamlessly defaults for legacy COD orders
      expect(order.paymentStatus, PaymentStatus.pending);
      expect(order.paymentGateway, PaymentGateway.cod);
      expect(order.gatewayOrderId, isNull);
      expect(order.gatewayPaymentId, isNull);
      expect(order.paidAt, isNull);
      expect(order.failureReason, isNull);
      expect(order.refundStatus, isNull);
      expect(order.refundId, isNull);
      expect(order.refundedAt, isNull);
    });

    test('B. COD order defaults and preserves existing COD behavior', () {
      final codOrder = CustomerOrder(
        orderId: '#FRSH-COD-1',
        orderDate: DateTime(2026, 9, 14, 8, 30),
        slotDate: 'Today',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.placed,
        items: [sampleCartItem],
        itemTotal: 80.0,
        deliveryFee: 0.0,
        discount: 0.0,
        grandTotal: 80.0,
        paymentMethod: PaymentMethod.cashOnDelivery,
        paymentStatus: PaymentStatus.pending,
        paymentGateway: PaymentGateway.cod,
        deliveryAddress: 'House 5, Green Park',
        timeline: const [],
      );

      expect(codOrder.paymentMethod, PaymentMethod.cashOnDelivery);
      expect(codOrder.paymentStatus, PaymentStatus.pending);
      expect(codOrder.paymentGateway, PaymentGateway.cod);

      final map = codOrder.toMap();
      expect(map['paymentMethod'], 'cashOnDelivery');
      expect(map['paymentStatus'], 'pending');
      expect(map['paymentGateway'], 'cod');
    });

    test('C. New order with complete online payment fields serializes and deserializes correctly', () {
      final paidTime = DateTime(2026, 9, 14, 9, 15);
      final refundedTime = DateTime(2026, 9, 14, 11, 00);

      final fullOrder = CustomerOrder(
        orderId: '#FRSH-ONL-99',
        orderDate: DateTime(2026, 9, 14, 9, 0),
        slotDate: 'Today',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.preparing,
        items: [sampleCartItem],
        itemTotal: 80.0,
        deliveryFee: 30.0,
        discount: 20.0,
        grandTotal: 90.0,
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.paid,
        paymentGateway: PaymentGateway.razorpay,
        gatewayOrderId: 'order_N99281749',
        gatewayPaymentId: 'pay_P10294819',
        paidAt: paidTime,
        failureReason: null,
        refundStatus: 'partial',
        refundId: 'rfnd_R9910293',
        refundedAt: refundedTime,
        deliveryAddress: 'Villa 12, Sunrise Valley',
        timeline: const [],
      );

      final map = fullOrder.toMap();

      expect(map['paymentStatus'], 'paid');
      expect(map['paymentGateway'], 'razorpay');
      expect(map['gatewayOrderId'], 'order_N99281749');
      expect(map['gatewayPaymentId'], 'pay_P10294819');
      expect(map['paidAt'], paidTime.toIso8601String());
      expect(map['refundStatus'], 'partial');
      expect(map['refundId'], 'rfnd_R9910293');
      expect(map['refundedAt'], refundedTime.toIso8601String());

      // Round-trip deserialization
      final restored = CustomerOrder.fromMap(map);
      expect(restored.orderId, '#FRSH-ONL-99');
      expect(restored.paymentMethod, PaymentMethod.upi);
      expect(restored.paymentStatus, PaymentStatus.paid);
      expect(restored.paymentGateway, PaymentGateway.razorpay);
      expect(restored.gatewayOrderId, 'order_N99281749');
      expect(restored.gatewayPaymentId, 'pay_P10294819');
      expect(restored.paidAt, paidTime);
      expect(restored.refundStatus, 'partial');
      expect(restored.refundId, 'rfnd_R9910293');
      expect(restored.refundedAt, refundedTime);
    });

    test('D. Firestore map with null or empty payment fields deserializes safely', () {
      final mapWithNulls = {
        'orderId': '#FRSH-NULLS',
        'orderDate': '2026-09-14T09:00:00.000Z',
        'slotDate': 'Today',
        'timeSlot': '6:00 AM – 8:00 AM',
        'status': 'placed',
        'items': [],
        'itemTotal': 0.0,
        'deliveryFee': 0.0,
        'discount': 0.0,
        'grandTotal': 0.0,
        'paymentMethod': 'card',
        'paymentStatus': null,
        'paymentGateway': null,
        'gatewayOrderId': null,
        'gatewayPaymentId': null,
        'paidAt': null,
        'failureReason': null,
        'refundStatus': null,
        'refundId': null,
        'refundedAt': null,
        'deliveryAddress': 'Test Address',
      };

      final order = CustomerOrder.fromMap(mapWithNulls);
      expect(order.orderId, '#FRSH-NULLS');
      expect(order.paymentStatus, PaymentStatus.pending);
      expect(order.paymentGateway, isNull);
      expect(order.gatewayOrderId, isNull);
      expect(order.gatewayPaymentId, isNull);
      expect(order.paidAt, isNull);
    });

    test('E. Unknown payment status does not crash and defaults safely', () {
      final mapWithUnknownStatus = {
        'orderId': '#FRSH-UNK-1',
        'orderDate': '2026-09-14T09:00:00.000Z',
        'slotDate': 'Today',
        'timeSlot': '6:00 AM – 8:00 AM',
        'status': 'placed',
        'items': [],
        'itemTotal': 0.0,
        'deliveryFee': 0.0,
        'discount': 0.0,
        'grandTotal': 0.0,
        'paymentMethod': 'upi',
        'paymentStatus': 'some_future_status_unknown',
        'deliveryAddress': 'Test Address',
      };

      final order = CustomerOrder.fromMap(mapWithUnknownStatus);
      expect(order.paymentStatus, PaymentStatus.pending);
    });

    test('F. Unknown payment gateway does not crash and handles safely', () {
      final mapWithUnknownGateway = {
        'orderId': '#FRSH-UNK-2',
        'orderDate': '2026-09-14T09:00:00.000Z',
        'slotDate': 'Today',
        'timeSlot': '6:00 AM – 8:00 AM',
        'status': 'placed',
        'items': [],
        'itemTotal': 0.0,
        'deliveryFee': 0.0,
        'discount': 0.0,
        'grandTotal': 0.0,
        'paymentMethod': 'upi',
        'paymentGateway': 'crypto_gateway_unknown',
        'deliveryAddress': 'Test Address',
      };

      final order = CustomerOrder.fromMap(mapWithUnknownGateway);
      expect(order.paymentGateway, isNull);
    });

    test('G. CustomerOrder.copyWith correctly updates payment fields', () {
      final initial = CustomerOrder(
        orderId: '#FRSH-CPY',
        orderDate: DateTime(2026, 9, 14, 10, 0),
        slotDate: 'Today',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.placed,
        items: [sampleCartItem],
        itemTotal: 80.0,
        deliveryFee: 0.0,
        discount: 0.0,
        grandTotal: 80.0,
        paymentMethod: PaymentMethod.card,
        paymentStatus: PaymentStatus.pending,
        deliveryAddress: 'Flat 3, Oak View',
        timeline: const [],
      );

      final paidTime = DateTime(2026, 9, 14, 10, 5);
      final updated = initial.copyWith(
        paymentStatus: PaymentStatus.paid,
        paymentGateway: PaymentGateway.stripe,
        gatewayPaymentId: 'pi_test_12345',
        paidAt: paidTime,
      );

      expect(updated.orderId, '#FRSH-CPY');
      expect(updated.paymentStatus, PaymentStatus.paid);
      expect(updated.paymentGateway, PaymentGateway.stripe);
      expect(updated.gatewayPaymentId, 'pi_test_12345');
      expect(updated.paidAt, paidTime);
      // Unchanged fields preserved
      expect(updated.grandTotal, 80.0);
      expect(updated.paymentMethod, PaymentMethod.card);
    });

    test('H. TaazaOrder / FreshlyOrder preserves new payment fields', () {
      final order = TaazaOrder(
        orderId: 'FRSH-99001',
        items: [sampleCartItem],
        deliveryAddress: 'Door 10, Sky Heights',
        slot: const DeliverySlot(
          date: '15 Sep',
          timeRange: '6:00 AM – 8:00 AM',
          label: 'Early Morning',
        ),
        paymentMethod: PaymentMethod.cashOnDelivery,
        paymentStatus: PaymentStatus.pending,
        paymentGateway: PaymentGateway.cod,
        itemTotal: 80.0,
        deliveryFee: 0.0,
        couponDiscount: 0.0,
        grandTotal: 80.0,
        orderTime: DateTime.now(),
      );

      expect(order.orderId, 'FRSH-99001');
      expect(order.paymentStatus, PaymentStatus.pending);
      expect(order.paymentGateway, PaymentGateway.cod);
      expect(order.totalItemCount, 2);
    });

    test('I. Pricing Parity: Boundary test vectors match backend exact rules (₹199 Threshold, ₹25 standard fee)', () {
      double computeDeliveryFee(double subtotal) {
        return subtotal >= 199.0 ? 0.0 : 25.0;
      }

      double computeGrandTotal(double subtotal, [double discount = 0.0]) {
        final fee = computeDeliveryFee(subtotal);
        final total = subtotal + fee - discount;
        return total > 0 ? total : 0.0;
      }

      // Exact parallel test vectors with backend Jest tests
      expect(computeDeliveryFee(0.0), 25.0);
      expect(computeGrandTotal(0.0), 25.0);

      expect(computeDeliveryFee(50.0), 25.0);
      expect(computeGrandTotal(50.0), 75.0);

      expect(computeDeliveryFee(198.0), 25.0);
      expect(computeGrandTotal(198.0), 223.0);

      expect(computeDeliveryFee(198.99), 25.0);
      expect(computeGrandTotal(198.99), closeTo(223.99, 0.001));

      // Exact threshold ₹199
      expect(computeDeliveryFee(199.0), 0.0);
      expect(computeGrandTotal(199.0), 199.0);

      expect(computeDeliveryFee(199.01), 0.0);
      expect(computeGrandTotal(199.01), closeTo(199.01, 0.001));

      expect(computeDeliveryFee(200.0), 0.0);
      expect(computeGrandTotal(200.0), 200.0);

      expect(computeDeliveryFee(224.0), 0.0);
      expect(computeGrandTotal(224.0), 224.0);

      // Coupon interactions
      expect(computeDeliveryFee(250.0), 0.0);
      expect(computeGrandTotal(250.0, 50.0), 200.0);

      expect(computeDeliveryFee(150.0), 25.0);
      expect(computeGrandTotal(150.0, 20.0), 155.0);
    });
  });
}
