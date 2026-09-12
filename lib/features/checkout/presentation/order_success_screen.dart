import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/presentation/home_screen.dart';
import '../domain/order_model.dart';

/// Premium Order Confirmation Screen with generated Order ID and delivery tracking
class OrderSuccessScreen extends StatelessWidget {
  final FreshlyOrder order;

  const OrderSuccessScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateToHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            key: const ValueKey('order_success_close_btn'),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
            onPressed: () => _navigateToHome(context),
          ),
          title: Text(
            'Order Confirmed',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Success Hero Banner
                  SliverToBoxAdapter(
                    child: _buildSuccessHero(),
                  ),

                  // 2. Order ID & Estimated Delivery Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      child: _buildOrderDetailsCard(),
                    ),
                  ),

                  // 3. Live Harvest & Delivery Timeline
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: _buildDeliveryTimelineCard(),
                    ),
                  ),

                  // 4. Items & Price Summary Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: _buildItemsSummaryCard(),
                    ),
                  ),

                  // 5. Delivery Address & Payment Mode Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: _buildAddressAndPaymentCard(),
                    ),
                  ),

                  // Bottom padding for CTA buttons
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomActions(context),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  /// 1. Success Hero Banner
  Widget _buildSuccessHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      color: Colors.white,
      child: Column(
        children: [
          // Animated green check circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEDF7EF),
              border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B6E38).withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Order Placed Successfully!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'Thank you for shopping farm fresh with Freshly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Order Details Card
  Widget _buildOrderDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order ID Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.orderId,
                  key: const ValueKey('order_id_text'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Estimated Delivery Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Delivery Slot',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.slot.fullDisplayText,
                      key: const ValueKey('estimated_delivery_text'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B6E38),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Live Harvest & Delivery Timeline Card
  Widget _buildDeliveryTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: Color(0xFF1B6E38),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Farm to Doorstep Tracking',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildTimelineStep(
            icon: Icons.check_circle_rounded,
            title: 'Order Received & Confirmed',
            time: 'Just now',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineStep(
            icon: Icons.grass_rounded,
            title: 'Sunrise Farm Harvest & Quality Inspection',
            time: 'Tomorrow, 4:00 AM',
            isCompleted: false,
            isActive: true,
            isLast: false,
          ),
          _buildTimelineStep(
            icon: Icons.door_front_door_rounded,
            title: 'Morning Doorstep Drop',
            time: order.slot.timeRange,
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String time,
    bool isCompleted = false,
    bool isActive = false,
    bool isLast = false,
  }) {
    final color = isCompleted
        ? const Color(0xFF16A34A)
        : (isActive ? const Color(0xFF1B6E38) : const Color(0xFFCBD5E1));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isActive ? color.withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 14,
                  color: color,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isCompleted || isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isCompleted || isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isCompleted || isActive ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 4. Items & Price Summary Card
  Widget _buildItemsSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items Summary (${order.totalItemCount})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '₹${order.grandTotal.toInt()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B6E38),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(item.product.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${item.product.name} (${item.selectedPack})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                  Text(
                    '${item.quantity}x',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${item.subtotal.toInt()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 5. Address & Payment Mode Card
  Widget _buildAddressAndPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF1B6E38),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivered to:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      order.deliveryAddress,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),

          // Payment mode
          Row(
            children: [
              Text(
                order.paymentMethod.icon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      order.paymentMethod.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.paymentMethod == PaymentMethod.cashOnDelivery
                      ? 'Pay on Drop'
                      : 'Mock Paid',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Actions
  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Home / Continue Shopping Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  key: const ValueKey('order_success_home_btn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6E38),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _navigateToHome(context),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
