import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Itemized bill summary for CheckoutScreen
class CheckoutBillSummary extends StatelessWidget {
  final double itemTotal;
  final double deliveryFee;
  final String? appliedCoupon;
  final double couponDiscount;
  final double grandTotal;

  const CheckoutBillSummary({
    super.key,
    required this.itemTotal,
    required this.deliveryFee,
    required this.appliedCoupon,
    required this.couponDiscount,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Summary',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),

          _buildRow('Item Total', '₹${itemTotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),

          _buildRow(
            'Delivery Partner Fee',
            deliveryFee == 0 ? 'FREE' : '₹${deliveryFee.toStringAsFixed(0)}',
            isGreen: deliveryFee == 0,
          ),

          if (couponDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildRow(
              'Coupon Discount ($appliedCoupon)',
              '-₹${couponDiscount.toStringAsFixed(0)}',
              isGreen: true,
            ),
          ],

          const SizedBox(height: 8),
          _buildRow('Handling & Eco-Packaging', 'FREE', isGreen: true),

          const Divider(height: 24, color: Color(0xFFE2E8F0)),

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
                '₹${grandTotal.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isGreen = false}) {
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
            color: isGreen ? const Color(0xFF166534) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
