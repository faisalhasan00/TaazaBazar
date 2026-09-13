import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/domain/cart_item.dart';
import '../domain/order_model.dart';
import 'order_success_screen.dart';
import 'widgets/checkout_bill_summary.dart';
import 'widgets/delivery_slot_picker.dart';
import 'widgets/payment_method_selector.dart';

/// Premium Checkout Screen for Freshly customer mobile app
class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  final String? deliveryAddress;
  final String? appliedCoupon;
  final double couponDiscount;

  const CheckoutScreen({
    super.key,
    required this.items,
    this.deliveryAddress,
    this.appliedCoupon,
    this.couponDiscount = 0.0,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late String _currentAddress;
  String _selectedSlot = '6:00 AM – 8:00 AM';
  PaymentMethod _selectedPayment = PaymentMethod.cashOnDelivery;

  final List<String> _slots = [
    '6:00 AM – 8:00 AM',
    '8:00 AM – 10:00 AM',
    '5:00 PM – 7:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.deliveryAddress ??
        'Flat 402, Green Valley Apartments, Indiranagar, Bengaluru, 560038';
  }

  double get _itemTotal {
    return widget.items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get _deliveryFee => _itemTotal >= 199 ? 0.0 : 25.0;

  double get _grandTotal {
    final total = _itemTotal + _deliveryFee - widget.couponDiscount;
    return total > 0 ? total : 0.0;
  }

  void _placeOrder() {
    final randomNum = 10000 + Random().nextInt(90000);
    final orderId = 'FRSH-$randomNum';

    final order = FreshlyOrder(
      orderId: orderId,
      items: widget.items,
      deliveryAddress: _currentAddress,
      slot: DeliverySlot(
        date: 'Tomorrow (Sun, 13 Sep)',
        timeRange: _selectedSlot,
        label: 'Early Morning Harvest Drop',
      ),
      paymentMethod: _selectedPayment,
      itemTotal: _itemTotal,
      deliveryFee: _deliveryFee,
      couponDiscount: widget.couponDiscount,
      grandTotal: _grandTotal,
      orderTime: DateTime.now(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(
          order: order,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Address Card
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: Color(0xFF166534),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delivery Address',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        key: const ValueKey('checkout_change_address_btn'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Address selector modal'),
                              backgroundColor: Color(0xFF166534),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentAddress,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Delivery Schedule / Slots Picker
            DeliverySlotPicker(
              slots: _slots,
              selectedSlot: _selectedSlot,
              onSelectSlot: (slot) => setState(() => _selectedSlot = slot),
            ),
            const SizedBox(height: 16),

            // 3. Payment Method Selector
            PaymentMethodSelector(
              selectedMethod: _selectedPayment,
              onSelectMethod: (method) => setState(() => _selectedPayment = method),
            ),
            const SizedBox(height: 16),

            // 4. Bill Summary
            CheckoutBillSummary(
              itemTotal: _itemTotal,
              deliveryFee: _deliveryFee,
              appliedCoupon: widget.appliedCoupon,
              couponDiscount: widget.couponDiscount,
              grandTotal: _grandTotal,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFE2E8F0)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '₹${_grandTotal.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    key: const ValueKey('place_order_btn'),
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Place Order',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
