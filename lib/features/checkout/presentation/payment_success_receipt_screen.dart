import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/presentation/home_screen.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/presentation/order_tracking_screen.dart';
import '../../subscription/domain/subscription_model.dart';
import '../domain/order_model.dart';

/// Animated Payment Successful Receipt Screen
class PaymentSuccessReceiptScreen extends StatefulWidget {
  final FreshlyOrder? order;
  final SubscriptionModel? subscription;
  final String? gatewayPaymentId;
  final String? gatewayOrderId;
  final double amountPaid;

  const PaymentSuccessReceiptScreen({
    super.key,
    this.order,
    this.subscription,
    this.gatewayPaymentId,
    this.gatewayOrderId,
    required this.amountPaid,
  });

  @override
  State<PaymentSuccessReceiptScreen> createState() => _PaymentSuccessReceiptScreenState();
}

class _PaymentSuccessReceiptScreenState extends State<PaymentSuccessReceiptScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        backgroundColor: const Color(0xFF166534),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubscription = widget.subscription != null;
    final referenceId = isSubscription
        ? (widget.subscription?.id ?? 'SUB-${DateTime.now().millisecondsSinceEpoch}')
        : (widget.order?.orderId ?? 'FRSH-${DateTime.now().millisecondsSinceEpoch}');
    final paymentId = widget.gatewayPaymentId ??
        widget.order?.gatewayPaymentId ??
        'pay_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _navigateToHome();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
            onPressed: _navigateToHome,
          ),
          centerTitle: true,
          title: Text(
            'Payment Receipt',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Color(0xFF166534)),
              tooltip: 'Share Receipt',
              onPressed: () => _copyToClipboard('TaazaBazar Payment Receipt\nRef: $referenceId\nPaid: ₹${widget.amountPaid.toInt()}\nPayment ID: $paymentId', 'Receipt summary'),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    // 1. Animated Celebratory Success Icon
                    _buildAnimatedHero(),
                    const SizedBox(height: 16),

                    // 2. Main Animated Digital Receipt Card
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildDigitalReceiptCard(referenceId, paymentId, isSubscription),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Next Scheduled Drop / Delivery Card
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildDeliveryScheduleCard(isSubscription),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Action Buttons
                    _buildActionButtons(isSubscription),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHero() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Glowing Halo
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                ),
              ),
            ),
            // Middle Circle
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDCFCE7),
                border: Border.all(color: const Color(0xFF86EFAC), width: 2),
              ),
            ),
            // Inner Scaling Checkmark
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4016A34A),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Payment Successful!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF166534)),
              const SizedBox(width: 4),
              Text(
                '100% Verified via Razorpay',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalReceiptCard(String referenceId, String paymentId, bool isSubscription) {
    final now = DateTime.now();
    final formattedDate = '${now.day} ${_getMonthName(now.month)} ${now.year}, ${_formatTime(now)}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Receipt Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF064E3B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isSubscription ? 'Recurring Subscription Receipt' : 'Order Payment Receipt',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: const Color(0xFFA7F3D0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PAID',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Total Paid Amount Badge
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            child: Column(
              children: [
                Text(
                  'Amount Paid',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${widget.amountPaid.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Dashed Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    color: index % 2 == 0 ? Colors.transparent : const Color(0xFFCBD5E1),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Receipt Key-Value Rows
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildReceiptRow(
                  'Payment ID',
                  paymentId,
                  isCopyable: true,
                  onCopy: () => _copyToClipboard(paymentId, 'Payment ID'),
                ),
                const SizedBox(height: 10),
                _buildReceiptRow(
                  isSubscription ? 'Subscription Ref' : 'Order ID',
                  referenceId,
                  isCopyable: true,
                  onCopy: () => _copyToClipboard(referenceId, 'Reference ID'),
                ),
                const SizedBox(height: 10),
                _buildReceiptRow('Payment Gateway', 'Razorpay Secure Checkout'),
                const SizedBox(height: 10),
                _buildReceiptRow('Payment Method', 'UPI / Instant Bank Transfer'),
                const SizedBox(height: 10),
                _buildReceiptRow('Payment Status', 'Success (Captured)'),
                if (isSubscription) ...[
                  const SizedBox(height: 10),
                  _buildReceiptRow('Plan Type', widget.subscription?.planType.title ?? 'Household Basket'),
                  const SizedBox(height: 10),
                  _buildReceiptRow('Est. Monthly Spend', '₹${widget.subscription?.estimatedMonthlyAmount.toInt() ?? 0}/mo'),
                ],
              ],
            ),
          ),

          // Items summary breakdown
          if (widget.subscription?.items.isNotEmpty == true || widget.order?.items.isNotEmpty == true) ...[
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscribed / Ordered Items',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isSubscription)
                    ...widget.subscription!.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.emoji} ${item.productName} (${item.quantity.toInt()} ${item.unit})',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF475569)),
                            ),
                            Text(
                              item.frequency.label,
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF166534)),
                            ),
                          ],
                        ),
                      );
                    })
                  else if (widget.order != null)
                    ...widget.order!.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.product.name} × ${item.quantity}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF475569)),
                            ),
                            Text(
                              '₹${item.subtotal.toInt()}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isCopyable = false, VoidCallback? onCopy}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (isCopyable) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onCopy,
                child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF166534)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryScheduleCard(bool isSubscription) {
    final slot = isSubscription
        ? (widget.subscription?.deliverySlot ?? '6:00 AM – 8:00 AM')
        : (widget.order?.slot.timeRange ?? '6:00 AM – 8:00 AM');
    final address = isSubscription
        ? (widget.subscription?.deliveryAddress ?? 'Registered Address')
        : (widget.order?.deliveryAddress ?? 'Registered Address');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFF166534), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'First Delivery Scheduled',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Tomorrow Morning • $slot',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isSubscription) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              if (isSubscription) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              } else if (widget.order != null) {
                final customerOrder = OrderRepository().getOrderById(widget.order!.orderId);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(order: customerOrder),
                  ),
                );
              } else {
                _navigateToHome();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              isSubscription ? 'View My Subscriptions Hub' : 'Track Order Status',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _navigateToHome,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E293B),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'Back to Home',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
