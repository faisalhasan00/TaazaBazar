import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../checkout/data/payment_service.dart';
import '../../../checkout/domain/order_model.dart';
import '../../domain/customer_order.dart';
import '../invoice_preview_screen.dart';

/// Modal bottom sheet for viewing complete order details and bill breakdown
class OrderDetailsSheet extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsSheet({
    super.key,
    required this.order,
  });

  static Future<void> show(BuildContext context, CustomerOrder order) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.orderId} • ${order.slotDate}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status Banner
              _buildStatusBanner(order),
              const SizedBox(height: 20),

              // Items Header
              Text(
                'Items in this Order (${order.items.length})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              // Items List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 20,
                  color: Color(0xFFF1F5F9),
                ),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  final product = item.product;

                  return Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${product.unit} • Qty: ${item.quantity}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${item.subtotal.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Bill Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2EBE2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Summary',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBillRow('Item Total', '₹${order.itemTotal.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    _buildBillRow(
                      'Delivery Partner Fee',
                      order.deliveryFee == 0
                          ? 'FREE'
                          : '₹${order.deliveryFee.toStringAsFixed(0)}',
                      isHighlight: order.deliveryFee == 0,
                    ),
                    const SizedBox(height: 8),
                    _buildBillRow('Handling & Eco-Packaging', 'FREE', isHighlight: true),
                    if (order.discount > 0) ...[
                      const SizedBox(height: 8),
                      _buildBillRow(
                        'Coupon Discount',
                        '-₹${order.discount.toStringAsFixed(0)}',
                        isDiscount: true,
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Color(0xFFCBD5E1)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '₹${order.grandTotal.toStringAsFixed(0)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Delivery Address
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF166534),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Address',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.deliveryAddress,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Payment Method Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(
                      order.paymentMethod.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            order.paymentMethod.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          if (order.gatewayPaymentId != null && order.gatewayPaymentId!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${order.gatewayPaymentId}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildPaymentStatusBadge(order),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Invoice & Support Action Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('view_invoice_btn'),
                      onPressed: () {
                        InvoicePreviewScreen.show(context, order);
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: Text(
                        'Invoice',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF166534),
                        side: const BorderSide(color: Color(0xFF166534)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connecting to TaazaBazar Care Support...'),
                            backgroundColor: Color(0xFF166534),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.help_outline_rounded, size: 18),
                      label: Text(
                        'Need Help?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (order.isCancellable) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const ValueKey('cancel_order_btn'),
                    onPressed: () => _showCancelConfirmationDialog(context, order),
                    icon: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFDC2626)),
                    label: Text(
                      'Cancel Order',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(CustomerOrder order) {
    if (order.status == OrderStatus.cancelled) {
      final isRefunded = order.refundStatus == 'refunded' || order.paymentStatus == PaymentStatus.refunded;
      final isPendingRefund = order.refundStatus == 'pending';
      final isFailedRefund = order.refundStatus == 'failed';

      String subtitle = 'Order was cancelled before farm harvest';
      if (isRefunded) {
        final amt = (order.refundAmount ?? order.grandTotal).toStringAsFixed(0);
        subtitle = 'Refund of ₹$amt processed to original payment method';
      } else if (isPendingRefund) {
        final amt = (order.refundAmount ?? order.grandTotal).toStringAsFixed(0);
        subtitle = 'Refund of ₹$amt is being processed by bank';
      } else if (isFailedRefund) {
        subtitle = 'Refund processing failed. Taaza Care will assist you.';
      }

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cancel_rounded,
              color: Color(0xFFDC2626),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: order.status == OrderStatus.delivered
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            order.status == OrderStatus.delivered
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            color: order.status == OrderStatus.delivered
                ? const Color(0xFF166534)
                : const Color(0xFF92400E),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.status.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: order.status == OrderStatus.delivered
                        ? const Color(0xFF166534)
                        : const Color(0xFF92400E),
                  ),
                ),
                Text(
                  order.status == OrderStatus.delivered
                      ? 'Morning doorstep delivery was completed successfully'
                      : 'Scheduled Slot: ${order.timeSlot}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: order.status == OrderStatus.delivered
                        ? const Color(0xFF166534)
                        : const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelConfirmationDialog(BuildContext context, CustomerOrder order) async {
    final isPaidOnline =
        order.paymentStatus == PaymentStatus.paid &&
        order.paymentGateway == PaymentGateway.razorpay;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cancel Order?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          isPaidOnline
              ? 'Your payment of ₹${order.grandTotal.toStringAsFixed(0)} will be sent for refund to your original payment method.'
              : 'Your Cash on Delivery order will be cancelled. No payment will be collected.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Keep Order',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            key: const ValueKey('confirm_cancel_order_btn'),
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Cancelling order...'),
            ],
          ),
          backgroundColor: Color(0xFF0F172A),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final res = await PaymentService().cancelOrder(
        orderId: order.orderId,
        reason: 'Customer requested cancellation',
      );

      if (!context.mounted) return;

      if (res.success) {
        Navigator.pop(context); // Close details sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.refundStatus == 'refunded'
                  ? 'Order cancelled! Refund of ₹${(res.refundAmount ?? order.grandTotal).toStringAsFixed(0)} processed.'
                  : (res.refundStatus == 'pending'
                      ? 'Order cancelled! Refund of ₹${(res.refundAmount ?? order.grandTotal).toStringAsFixed(0)} initiated.'
                      : 'Order ${order.orderId} has been cancelled.'),
            ),
            backgroundColor: const Color(0xFF166534),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.errorMessage ?? 'Could not cancel order. Please try again.',
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDiscount
                ? const Color(0xFF166534)
                : (isHighlight ? const Color(0xFF166534) : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusBadge(CustomerOrder order) {
    Color bgColor;
    Color textColor;
    String label;

    if (order.paymentMethod == PaymentMethod.cashOnDelivery) {
      if (order.paymentStatus == PaymentStatus.paid) {
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        label = 'PAID';
      } else if (order.paymentStatus == PaymentStatus.cancelled) {
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        label = 'CANCELLED';
      } else {
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        label = 'TO PAY (COD)';
      }
    } else {
      switch (order.paymentStatus) {
        case PaymentStatus.paid:
          bgColor = const Color(0xFFDCFCE7);
          textColor = const Color(0xFF166534);
          label = 'PAID';
          break;
        case PaymentStatus.pending:
          bgColor = const Color(0xFFFEF3C7);
          textColor = const Color(0xFF92400E);
          label = 'PENDING';
          break;
        case PaymentStatus.failed:
          bgColor = const Color(0xFFFEE2E2);
          textColor = const Color(0xFFDC2626);
          label = 'FAILED';
          break;
        case PaymentStatus.refunded:
          bgColor = const Color(0xFFF3E8FF);
          textColor = const Color(0xFF7E22CE);
          label = 'REFUNDED';
          break;
        case PaymentStatus.cancelled:
          bgColor = const Color(0xFFF1F5F9);
          textColor = const Color(0xFF475569);
          label = 'CANCELLED';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}
