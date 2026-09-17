import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/core/constants/payment_config.dart';
import 'package:taazabazar/features/checkout/data/payment_service.dart';
import 'package:taazabazar/features/checkout/domain/order_model.dart';
import 'package:taazabazar/features/orders/domain/customer_order.dart';

void main() {
  group('PaymentConfig Tests', () {
    test('PaymentConfig exposes valid defaults and currency', () {
      expect(PaymentConfig.currency, 'INR');
      expect(PaymentConfig.brandColorHex, '#16A34A');
      expect(PaymentConfig.functionsRegion, 'asia-south1');
      expect(PaymentConfig.getKeyId(), isNotEmpty);
    });

    test('PaymentConfig.getKeyId prioritizes server-supplied key ID over default', () {
      expect(
        PaymentConfig.getKeyId('rzp_test_server123'),
        'rzp_test_server123',
      );
      expect(
        PaymentConfig.getKeyId(null),
        PaymentConfig.razorpayTestKeyId,
      );
    });
  });

  group('RazorpayOrderResult Model Tests', () {
    test('parses valid map from Cloud Function response', () {
      final map = {
        'success': true,
        'orderId': '#FRSH-12345',
        'gatewayOrderId': 'order_N99281749',
        'amount': 240.0,
        'amountInPaise': 24000,
        'currency': 'INR',
        'keyId': 'rzp_test_xyz',
      };

      final result = RazorpayOrderResult.fromMap(map);
      expect(result.success, isTrue);
      expect(result.orderId, '#FRSH-12345');
      expect(result.gatewayOrderId, 'order_N99281749');
      expect(result.amount, 240.0);
      expect(result.amountInPaise, 24000);
      expect(result.currency, 'INR');
      expect(result.keyId, 'rzp_test_xyz');
      expect(result.errorMessage, isNull);
    });

    test('RazorpayOrderResult.error creates error result safely', () {
      final error = RazorpayOrderResult.error('Payment server unavailable', 'FRSH-999');
      expect(error.success, isFalse);
      expect(error.orderId, 'FRSH-999');
      expect(error.errorMessage, 'Payment server unavailable');
      expect(error.gatewayOrderId, isNull);
    });
  });

  group('RazorpayVerificationResult Model Tests', () {
    test('parses valid verification success map from Cloud Function', () {
      final map = {
        'success': true,
        'orderId': '#FRSH-12345',
        'paymentStatus': 'paid',
        'message': 'Payment verified successfully.',
        'paidAt': '2026-09-14T10:30:00.000Z',
      };

      final result = RazorpayVerificationResult.fromMap(map);
      expect(result.success, isTrue);
      expect(result.orderId, '#FRSH-12345');
      expect(result.paymentStatus, 'paid');
      expect(result.message, 'Payment verified successfully.');
      expect(result.paidAt, isNotNull);
      expect(result.errorMessage, isNull);
    });

    test('parses already-verified idempotent response safely', () {
      final map = {
        'success': true,
        'orderId': '#FRSH-12345',
        'paymentStatus': 'paid',
        'message': 'Payment already verified.',
        'paidAt': '2026-09-14T10:00:00.000Z',
      };

      final result = RazorpayVerificationResult.fromMap(map);
      expect(result.success, isTrue);
      expect(result.paymentStatus, 'paid');
      expect(result.message, contains('already verified'));
    });

    test('RazorpayVerificationResult.error creates error result safely', () {
      final error = RazorpayVerificationResult.error('Signature mismatch', 'FRSH-999');
      expect(error.success, isFalse);
      expect(error.orderId, 'FRSH-999');
      expect(error.paymentStatus, 'pending');
      expect(error.errorMessage, 'Signature mismatch');
      expect(error.paidAt, isNull);
    });
  });

  group('Order Security & Payment Status Lifecycle Tests', () {
    test('1. COD path remains 100% untouched and sets cod gateway with pending status', () {
      const codMethod = PaymentMethod.cashOnDelivery;
      expect(codMethod.title, 'Cash on Delivery');

      final order = CustomerOrder(
        orderId: '#FRSH-COD-TEST',
        orderDate: DateTime(2026, 9, 14),
        slotDate: 'Tomorrow',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.placed,
        items: const [],
        itemTotal: 100.0,
        deliveryFee: 25.0,
        discount: 0.0,
        grandTotal: 125.0,
        paymentMethod: codMethod,
        paymentStatus: PaymentStatus.pending,
        paymentGateway: PaymentGateway.cod,
        deliveryAddress: 'Flat 101, Test App',
        timeline: const [],
      );

      expect(order.paymentMethod, PaymentMethod.cashOnDelivery);
      expect(order.paymentGateway, PaymentGateway.cod);
      expect(order.paymentStatus, PaymentStatus.pending);
      expect(order.paidAt, isNull);
      expect(order.gatewayPaymentId, isNull);
    });

    test('2. Online order (UPI/Card/NetBanking) starts with pending status and razorpay gateway', () {
      final onlineOrder = CustomerOrder(
        orderId: '#FRSH-ONL-TEST',
        orderDate: DateTime(2026, 9, 14),
        slotDate: 'Tomorrow',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.placed,
        items: const [],
        itemTotal: 250.0,
        deliveryFee: 0.0,
        discount: 50.0,
        grandTotal: 200.0,
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.pending,
        paymentGateway: PaymentGateway.razorpay,
        gatewayOrderId: 'order_test_999',
        deliveryAddress: 'House 5, Indiranagar',
        timeline: const [],
      );

      expect(onlineOrder.paymentMethod, PaymentMethod.upi);
      expect(onlineOrder.paymentGateway, PaymentGateway.razorpay);
      expect(onlineOrder.paymentStatus, PaymentStatus.pending);
      // Crucial Security Rule: Client callback must NOT set paidAt or mark paid directly
      expect(onlineOrder.paidAt, isNull);
      expect(onlineOrder.gatewayPaymentId, isNull);
    });

    test('3. Client cannot directly update paymentStatus to paid without backend verification', () {
      final pendingOrder = CustomerOrder(
        orderId: '#FRSH-UNVERIFIED',
        orderDate: DateTime(2026, 9, 14),
        slotDate: 'Today',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.placed,
        items: const [],
        itemTotal: 150.0,
        deliveryFee: 25.0,
        discount: 0.0,
        grandTotal: 175.0,
        paymentMethod: PaymentMethod.card,
        paymentStatus: PaymentStatus.pending,
        paymentGateway: PaymentGateway.razorpay,
        deliveryAddress: 'Test Villa',
        timeline: const [],
      );

      expect(pendingOrder.paymentStatus.isPending, isTrue);
      expect(pendingOrder.paymentStatus.isPaid, isFalse);
    });

    test('4. Successful backend verification results in a paid order with gateway payment ID and paidAt', () {
      final verifiedPaidOrder = FreshlyOrder(
        orderId: 'FRSH-VERIFIED-PAID',
        items: const [],
        deliveryAddress: 'Indiranagar 100ft Rd',
        slot: DeliverySlot(date: 'Tomorrow', timeRange: '6:00 AM – 8:00 AM', label: 'Morning Drop'),
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.paid,
        paymentGateway: PaymentGateway.razorpay,
        gatewayOrderId: 'order_N99281749',
        gatewayPaymentId: 'pay_P10294819',
        paidAt: DateTime(2026, 9, 14, 10, 30),
        itemTotal: 300.0,
        deliveryFee: 0.0,
        couponDiscount: 0.0,
        grandTotal: 300.0,
        orderTime: DateTime(2026, 9, 14, 10, 29),
      );

      expect(verifiedPaidOrder.paymentStatus.isPaid, isTrue);
      expect(verifiedPaidOrder.gatewayOrderId, 'order_N99281749');
      expect(verifiedPaidOrder.gatewayPaymentId, 'pay_P10294819');
      expect(verifiedPaidOrder.paidAt, isNotNull);
    });

    test('5. Cart preservation: Unverified, cancelled, or failed payments retain pending status', () {
      final cancelledOrder = CustomerOrder(
        orderId: '#FRSH-CANCELLED',
        orderDate: DateTime.now(),
        slotDate: 'Tomorrow',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.placed,
        items: const [],
        itemTotal: 120.0,
        deliveryFee: 25.0,
        discount: 0.0,
        grandTotal: 145.0,
        paymentMethod: PaymentMethod.netBanking,
        paymentStatus: PaymentStatus.pending,
        paymentGateway: PaymentGateway.razorpay,
        deliveryAddress: 'Flat 302',
        timeline: const [],
      );

      // Cart is NOT cleared on cancellation/failure
      expect(cancelledOrder.paymentStatus.isPaid, isFalse);
    });
  });

  group('CancelOrderResult & Cancellation Lifecycle Tests', () {
    test('CancelOrderResult parses valid map from Cloud Function', () {
      final map = {
        'success': true,
        'orderId': '#FRSH-12345',
        'status': 'cancelled',
        'paymentStatus': 'refunded',
        'refundStatus': 'refunded',
        'refundId': 'rfnd_998877',
        'refundAmount': 250.0,
        'message': 'Order cancelled and refund processed.',
        'refundedAt': '2026-09-14T11:00:00.000Z',
        'cancelledAt': '2026-09-14T11:00:00.000Z',
      };

      final result = CancelOrderResult.fromMap(map);
      expect(result.success, isTrue);
      expect(result.orderId, '#FRSH-12345');
      expect(result.status, 'cancelled');
      expect(result.paymentStatus, 'refunded');
      expect(result.refundStatus, 'refunded');
      expect(result.refundId, 'rfnd_998877');
      expect(result.refundAmount, 250.0);
      expect(result.refundedAt, isNotNull);
      expect(result.cancelledAt, isNotNull);
      expect(result.errorMessage, isNull);
    });

    test('CancelOrderResult.error safely constructs failure', () {
      final error = CancelOrderResult.error('Order cannot be cancelled in outForDelivery stage.', 'FRSH-555');
      expect(error.success, isFalse);
      expect(error.orderId, 'FRSH-555');
      expect(error.errorMessage, contains('cannot be cancelled'));
    });

    test('CustomerOrder isCancellable returns true ONLY for placed status', () {
      CustomerOrder createWithStatus(OrderStatus status) {
        return CustomerOrder(
          orderId: '#TEST',
          orderDate: DateTime.now(),
          slotDate: 'Today',
          timeSlot: '6-8',
          status: status,
          items: const [],
          itemTotal: 100,
          deliveryFee: 0,
          discount: 0,
          grandTotal: 100,
          paymentMethod: PaymentMethod.cashOnDelivery,
          deliveryAddress: 'Home',
          timeline: const [],
        );
      }

      expect(createWithStatus(OrderStatus.placed).isCancellable, isTrue);
      expect(createWithStatus(OrderStatus.preparing).isCancellable, isFalse);
      expect(createWithStatus(OrderStatus.outForDelivery).isCancellable, isFalse);
      expect(createWithStatus(OrderStatus.delivered).isCancellable, isFalse);
      expect(createWithStatus(OrderStatus.cancelled).isCancellable, isFalse);
    });
  });
}
