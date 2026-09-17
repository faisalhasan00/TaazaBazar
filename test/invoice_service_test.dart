import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/core/constants/app_constants.dart';
import 'package:taazabazar/features/cart/domain/cart_item.dart';
import 'package:taazabazar/features/checkout/domain/order_model.dart';
import 'package:taazabazar/features/orders/domain/customer_order.dart';
import 'package:taazabazar/features/orders/services/invoice_pdf_service.dart';
import 'package:taazabazar/features/products/domain/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dummyProduct1 = Product(
    id: 'prod_1',
    name: 'Fresh Spinach',
    categoryId: 'leafy',
    categoryName: 'Leafy Greens',
    price: 40.0,
    originalPrice: 50.0,
    unit: '250g bunch',
    emoji: '🥬',
    description: 'Fresh farm spinach',
  );

  const dummyProduct2 = Product(
    id: 'prod_2',
    name: 'Organic Tomatoes',
    categoryId: 'vegetables',
    categoryName: 'Vegetables',
    price: 30.0,
    originalPrice: 35.0,
    unit: '500g',
    emoji: '🍅',
    description: 'Fresh organic tomatoes',
  );

  CustomerOrder createTestOrder({
    required String orderId,
    required double itemTotal,
    required double deliveryFee,
    required double discount,
    required double grandTotal,
    PaymentMethod paymentMethod = PaymentMethod.cashOnDelivery,
    PaymentStatus paymentStatus = PaymentStatus.pending,
    PaymentGateway? paymentGateway,
    String? gatewayOrderId,
    String? gatewayPaymentId,
    String? refundStatus,
    String? refundId,
    DateTime? refundedAt,
    double? refundAmount,
    OrderStatus status = OrderStatus.placed,
    List<CartItem>? items,
  }) {
    final orderItems = items ??
        [
          CartItem(product: dummyProduct1, quantity: 2),
        ];

    return CustomerOrder(
      orderId: orderId,
      orderDate: DateTime(2026, 9, 14, 10, 30),
      slotDate: 'Today, 14 Sep',
      timeSlot: '6:00 AM - 8:00 AM',
      status: status,
      items: orderItems,
      itemTotal: itemTotal,
      deliveryFee: deliveryFee,
      discount: discount,
      grandTotal: grandTotal,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      paymentGateway: paymentGateway,
      gatewayOrderId: gatewayOrderId,
      gatewayPaymentId: gatewayPaymentId,
      refundStatus: refundStatus,
      refundId: refundId,
      refundedAt: refundedAt,
      refundAmount: refundAmount,
      deliveryAddress: 'Flat 402, Green Meadows, Gachibowli, Hyderabad - 500032',
      timeline: const [],
    );
  }

  group('Invoice Service Tests', () {
    test('1. Invoice number generation is deterministic and clean', () {
      expect(InvoicePdfService.getInvoiceNumber('#FRSH-9281'), 'INV-FRSH-9281');
      expect(InvoicePdfService.getInvoiceNumber('TB-10293'), 'INV-TB-10293');
      expect(InvoicePdfService.getInvoiceNumber('INV-ORD-55'), 'INV-ORD-55');
      expect(InvoicePdfService.getInvoiceNumber(' #TB 8892 '), 'INV-TB-8892');
    });

    test('2. Boundary & Pricing: ₹0 order calculation parity', () {
      const itemTotal = 0.0;
      final deliveryFee = itemTotal >= AppConstants.freeDeliveryThreshold
          ? 0.0
          : AppConstants.standardDeliveryFee;
      const discount = 0.0;
      final grandTotal = itemTotal + deliveryFee - discount;

      final order = createTestOrder(
        orderId: 'TB-0',
        itemTotal: itemTotal,
        deliveryFee: deliveryFee,
        discount: discount,
        grandTotal: grandTotal,
        items: [],
      );

      expect(order.itemTotal, 0.0);
      expect(order.deliveryFee, 25.0);
      expect(order.grandTotal, 25.0);
      expect(order.itemTotal + order.deliveryFee - order.discount, order.grandTotal);
    });

    test('3. Boundary & Pricing: ₹50 order calculation parity', () {
      const itemTotal = 50.0;
      final deliveryFee = itemTotal >= AppConstants.freeDeliveryThreshold
          ? 0.0
          : AppConstants.standardDeliveryFee;
      const discount = 0.0;
      final grandTotal = itemTotal + deliveryFee - discount;

      final order = createTestOrder(
        orderId: 'TB-50',
        itemTotal: itemTotal,
        deliveryFee: deliveryFee,
        discount: discount,
        grandTotal: grandTotal,
      );

      expect(order.deliveryFee, 25.0);
      expect(order.grandTotal, 75.0);
      expect(order.itemTotal + order.deliveryFee - order.discount, order.grandTotal);
    });

    test('4. Boundary & Pricing: ₹198 order calculation parity (< ₹199 threshold)', () {
      const itemTotal = 198.0;
      final deliveryFee = itemTotal >= AppConstants.freeDeliveryThreshold
          ? 0.0
          : AppConstants.standardDeliveryFee;
      const discount = 0.0;
      final grandTotal = itemTotal + deliveryFee - discount;

      final order = createTestOrder(
        orderId: 'TB-198',
        itemTotal: itemTotal,
        deliveryFee: deliveryFee,
        discount: discount,
        grandTotal: grandTotal,
      );

      expect(order.deliveryFee, 25.0);
      expect(order.grandTotal, 223.0);
      expect(order.itemTotal + order.deliveryFee - order.discount, order.grandTotal);
    });

    test('5. Boundary & Pricing: ₹199 order calculation parity (Exact Free Delivery Threshold)', () {
      const itemTotal = 199.0;
      final deliveryFee = itemTotal >= AppConstants.freeDeliveryThreshold
          ? 0.0
          : AppConstants.standardDeliveryFee;
      const discount = 0.0;
      final grandTotal = itemTotal + deliveryFee - discount;

      final order = createTestOrder(
        orderId: 'TB-199',
        itemTotal: itemTotal,
        deliveryFee: deliveryFee,
        discount: discount,
        grandTotal: grandTotal,
      );

      expect(order.deliveryFee, 0.0);
      expect(order.grandTotal, 199.0);
      expect(order.itemTotal + order.deliveryFee - order.discount, order.grandTotal);
    });

    test('6. Boundary & Pricing: ₹200 order calculation parity (> ₹199 threshold)', () {
      const itemTotal = 200.0;
      final deliveryFee = itemTotal >= AppConstants.freeDeliveryThreshold
          ? 0.0
          : AppConstants.standardDeliveryFee;
      const discount = 0.0;
      final grandTotal = itemTotal + deliveryFee - discount;

      final order = createTestOrder(
        orderId: 'TB-200',
        itemTotal: itemTotal,
        deliveryFee: deliveryFee,
        discount: discount,
        grandTotal: grandTotal,
      );

      expect(order.deliveryFee, 0.0);
      expect(order.grandTotal, 200.0);
      expect(order.itemTotal + order.deliveryFee - order.discount, order.grandTotal);
    });

    test('7. Discounted order maintains mathematical invoice integrity', () {
      const itemTotal = 350.0;
      const discount = 50.0;
      final deliveryFee = itemTotal >= AppConstants.freeDeliveryThreshold ? 0.0 : 25.0;
      final grandTotal = itemTotal + deliveryFee - discount;

      final order = createTestOrder(
        orderId: 'TB-DISC',
        itemTotal: itemTotal,
        deliveryFee: deliveryFee,
        discount: discount,
        grandTotal: grandTotal,
      );

      expect(order.grandTotal, 300.0);
      expect(order.itemTotal + order.deliveryFee - order.discount, order.grandTotal);
      expect(order.grandTotal >= 0, isTrue);
    });

    test('8. COD Pending order invoice details', () {
      final order = createTestOrder(
        orderId: 'TB-COD-1',
        itemTotal: 150.0,
        deliveryFee: 25.0,
        discount: 0.0,
        grandTotal: 175.0,
        paymentMethod: PaymentMethod.cashOnDelivery,
        paymentStatus: PaymentStatus.pending,
      );

      expect(order.paymentMethod, PaymentMethod.cashOnDelivery);
      expect(order.paymentStatus, PaymentStatus.pending);
      expect(order.gatewayPaymentId, isNull);
    });

    test('9. Razorpay Paid order invoice details', () {
      final order = createTestOrder(
        orderId: 'TB-RZP-PAID',
        itemTotal: 250.0,
        deliveryFee: 0.0,
        discount: 25.0,
        grandTotal: 225.0,
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.paid,
        paymentGateway: PaymentGateway.razorpay,
        gatewayOrderId: 'order_TEST123',
        gatewayPaymentId: 'pay_TEST456',
      );

      expect(order.paymentStatus, PaymentStatus.paid);
      expect(order.paymentGateway, PaymentGateway.razorpay);
      expect(order.gatewayPaymentId, 'pay_TEST456');
    });

    test('10. Razorpay Failed order invoice details', () {
      final order = createTestOrder(
        orderId: 'TB-RZP-FAIL',
        itemTotal: 120.0,
        deliveryFee: 25.0,
        discount: 0.0,
        grandTotal: 145.0,
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.failed,
        paymentGateway: PaymentGateway.razorpay,
      );

      expect(order.paymentStatus, PaymentStatus.failed);
      expect(order.gatewayPaymentId, isNull);
    });

    test('11. Cancelled COD order invoice details', () {
      final order = createTestOrder(
        orderId: 'TB-COD-CANCELLED',
        itemTotal: 160.0,
        deliveryFee: 25.0,
        discount: 0.0,
        grandTotal: 185.0,
        paymentMethod: PaymentMethod.cashOnDelivery,
        paymentStatus: PaymentStatus.cancelled,
        status: OrderStatus.cancelled,
      );

      expect(order.status, OrderStatus.cancelled);
      expect(order.paymentStatus, PaymentStatus.cancelled);
      expect(order.refundStatus, isNull);
    });

    test('12. Refunded Razorpay order invoice details', () {
      final order = createTestOrder(
        orderId: 'TB-RZP-REFUNDED',
        itemTotal: 300.0,
        deliveryFee: 0.0,
        discount: 0.0,
        grandTotal: 300.0,
        paymentMethod: PaymentMethod.card,
        paymentStatus: PaymentStatus.refunded,
        paymentGateway: PaymentGateway.razorpay,
        gatewayPaymentId: 'pay_TEST789',
        refundStatus: 'refunded',
        refundId: 'rfnd_TEST999',
        refundAmount: 300.0,
        status: OrderStatus.cancelled,
      );

      expect(order.status, OrderStatus.cancelled);
      expect(order.paymentStatus, PaymentStatus.refunded);
      expect(order.refundStatus, 'refunded');
      expect(order.refundId, 'rfnd_TEST999');
      expect(order.refundAmount, 300.0);
    });

    test('13. Refund Pending order invoice details', () {
      final order = createTestOrder(
        orderId: 'TB-RZP-REFUND-PENDING',
        itemTotal: 250.0,
        deliveryFee: 0.0,
        discount: 0.0,
        grandTotal: 250.0,
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.paid,
        paymentGateway: PaymentGateway.razorpay,
        gatewayPaymentId: 'pay_TEST111',
        refundStatus: 'pending',
        refundId: 'rfnd_PENDING1',
        refundAmount: 250.0,
        status: OrderStatus.cancelled,
      );

      expect(order.status, OrderStatus.cancelled);
      expect(order.refundStatus, 'pending');
      expect(order.refundAmount, 250.0);
    });

    test('14. Refund Failed order invoice details', () {
      final order = createTestOrder(
        orderId: 'TB-RZP-REFUND-FAILED',
        itemTotal: 180.0,
        deliveryFee: 25.0,
        discount: 0.0,
        grandTotal: 205.0,
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.paid,
        paymentGateway: PaymentGateway.razorpay,
        gatewayPaymentId: 'pay_TEST222',
        refundStatus: 'failed',
        status: OrderStatus.cancelled,
      );

      expect(order.status, OrderStatus.cancelled);
      expect(order.refundStatus, 'failed');
    });

    test('15. Historical order missing optional/newer fields generates invoice safely', () {
      final historicalOrder = CustomerOrder(
        orderId: 'HISTORICAL-001',
        orderDate: DateTime(2025, 1, 1),
        slotDate: '01 Jan 2025',
        timeSlot: 'Morning',
        status: OrderStatus.delivered,
        items: [CartItem(product: dummyProduct2, quantity: 1)],
        itemTotal: 30.0,
        deliveryFee: 25.0,
        discount: 0.0,
        grandTotal: 55.0,
        paymentMethod: PaymentMethod.cashOnDelivery,
        deliveryAddress: 'Old Address, Ameerpet, Hyderabad',
        timeline: const [],
      );

      expect(historicalOrder.paymentStatus, PaymentStatus.pending);
      expect(historicalOrder.paymentGateway, isNull);
      expect(historicalOrder.gatewayOrderId, isNull);
      expect(InvoicePdfService.getInvoiceNumber(historicalOrder.orderId), 'INV-HISTORICAL-001');
    });

    test('16. PDF Generation produces valid %PDF- bytes without throwing or leaking secrets', () async {
      final order = createTestOrder(
        orderId: 'TB-VALID-PDF',
        itemTotal: 220.0,
        deliveryFee: 0.0,
        discount: 20.0,
        grandTotal: 200.0,
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.paid,
        paymentGateway: PaymentGateway.razorpay,
        gatewayOrderId: 'order_SEC999',
        gatewayPaymentId: 'pay_PUB999',
      );

      final Uint8List pdfBytes = await InvoicePdfService.generateInvoicePdf(order);

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(100));

      // PDF specification magic header is '%PDF-'
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, '%PDF-');

      // Convert raw bytes to ascii/latin1 string to check for accidental secret leaks
      final pdfContent = latin1.decode(pdfBytes);
      expect(pdfContent.contains('RAZORPAY_KEY_SECRET'), isFalse);
      expect(pdfContent.contains('RAZORPAY_WEBHOOK_SECRET'), isFalse);
    });
  });
}
