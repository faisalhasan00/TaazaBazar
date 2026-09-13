import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/order_model.dart';

/// Payment method selector widget for CheckoutScreen
class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final Function(PaymentMethod method) onSelectMethod;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onSelectMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payment_rounded,
                size: 18,
                color: Color(0xFF166534),
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Method',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildPaymentOption(
            keyName: 'payment_method_upi',
            method: PaymentMethod.upi,
            icon: Icons.qr_code_2_rounded,
            title: 'Instant UPI',
            subtitle: 'Google Pay, PhonePe, Paytm',
            tag: 'POPULAR',
          ),
          const SizedBox(height: 10),

          _buildPaymentOption(
            keyName: 'payment_method_card',
            method: PaymentMethod.card,
            icon: Icons.credit_card_rounded,
            title: 'Credit / Debit Card',
            subtitle: 'Visa, MasterCard, RuPay',
          ),
          const SizedBox(height: 10),

          _buildPaymentOption(
            keyName: 'payment_method_cod',
            method: PaymentMethod.cashOnDelivery,
            icon: Icons.payments_outlined,
            title: 'Pay on Delivery',
            subtitle: 'Cash or UPI at doorstep',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String keyName,
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    String? tag,
  }) {
    final isSelected = selectedMethod == method;

    return GestureDetector(
      key: ValueKey(keyName),
      onTap: () => onSelectMethod(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF166534) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF166534) : const Color(0xFFCBD5E1),
                  width: isSelected ? 5 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
