import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../checkout/data/payment_service.dart';
import '../../../checkout/domain/order_model.dart';
import '../../../location/data/address_repository.dart';
import '../../../products/domain/product_model.dart';
import '../../data/subscription_repository.dart';
import '../../domain/subscription_model.dart';
import '../../../checkout/presentation/payment_success_receipt_screen.dart';

/// Modal sheet for pre-configured "Family Fresh Subscription"
class FamilyFreshSheet extends StatefulWidget {
  final VoidCallback? onSubscriptionCreated;

  const FamilyFreshSheet({
    super.key,
    this.onSubscriptionCreated,
  });

  @override
  State<FamilyFreshSheet> createState() => _FamilyFreshSheetState();
}

class _FamilyFreshSheetState extends State<FamilyFreshSheet> {
  int _familySize = 4; // 2-3 (Compact), 4-5 (Standard), 6+ (Large)
  String _milkType = 'Cow Milk'; // 'Cow Milk' (₹60/L), 'Buffalo Milk' (₹70/L)
  double _milkQuantity = 2.0; // 1L, 2L, 3L
  bool _includeVegBasket = true; // ₹300/week
  bool _includeFruitBasket = true; // ₹250/week
  bool _includeEggs = true; // 12 eggs/week (₹120)
  String _selectedSlot = '6:00 AM – 8:00 AM';
  PaymentMethod _selectedPayment = PaymentMethod.upi;
  bool _isSubmitting = false;

  final PaymentService _paymentService = PaymentService();
  SubscriptionModel? _pendingSubscription;

  @override
  void initState() {
    super.initState();
    _paymentService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('FamilyFreshSheet: Razorpay payment success callback received: paymentId=${response.paymentId}');
    if (!mounted) return;

    final sub = _pendingSubscription;
    if (sub == null) return;

    final signature = response.signature ?? '';
    final gatewayOrderId = response.orderId ?? '';
    final gatewayPaymentId = response.paymentId ?? '';

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
            Text('Cryptographically verifying subscription payment...'),
          ],
        ),
        backgroundColor: Color(0xFF166534),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final verificationResult = await _paymentService.verifyPaymentSignature(
      orderId: sub.id,
      gatewayOrderId: gatewayOrderId,
      gatewayPaymentId: gatewayPaymentId,
      signature: signature,
    );

    if (!mounted) return;

    if (verificationResult.success) {
      final activeSub = sub.copyWith(
        paymentMode: 'Online (Razorpay - $gatewayPaymentId)',
      );
      await SubscriptionRepository().createSubscription(activeSub);

      if (mounted) {
        Navigator.pop(context);
        widget.onSubscriptionCreated?.call();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessReceiptScreen(
              subscription: activeSub,
              gatewayPaymentId: gatewayPaymentId,
              gatewayOrderId: gatewayOrderId,
              amountPaid: _firstDeliveryAmount,
            ),
          ),
        );
      }
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verificationResult.errorMessage ?? 'Payment verification failed.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('FamilyFreshSheet: Razorpay payment error: ${response.message}');
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment cancelled or failed: ${response.message ?? "Please try again"}'),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  double get _milkMonthlyCost {
    final ratePerLiter = _milkType == 'Buffalo Milk' ? 70.0 : 60.0;
    return ratePerLiter * _milkQuantity * 30; // Daily delivery
  }

  double get _vegMonthlyCost => _includeVegBasket ? 300.0 * 4.33 : 0.0;
  double get _fruitMonthlyCost => _includeFruitBasket ? 250.0 * 4.33 : 0.0;
  double get _eggsMonthlyCost => _includeEggs ? 120.0 * 4.33 : 0.0;

  double get _estimatedMonthlySpend {
    return _milkMonthlyCost + _vegMonthlyCost + _fruitMonthlyCost + _eggsMonthlyCost;
  }

  double get _firstDeliveryAmount {
    final ratePerLiter = _milkType == 'Buffalo Milk' ? 70.0 : 60.0;
    double firstDelivery = ratePerLiter * _milkQuantity;
    if (_includeVegBasket) firstDelivery += 300.0;
    if (_includeFruitBasket) firstDelivery += 250.0;
    if (_includeEggs) firstDelivery += 120.0;
    return firstDelivery > 0 ? firstDelivery : 100.0;
  }

  Future<void> _submitFamilyFreshPlan() async {
    setState(() => _isSubmitting = true);
    try {
      final defaultAddr = AddressRepository().getDefaultAddress();
      final address = defaultAddr?.formattedAddress ?? 'Current Delivery Location';
      final addressId = defaultAddr?.id ?? 'default_addr';
      final uid = FirebaseAuthService().currentUserId ?? 'guest_user';
      final subId = 'sub_family_${DateTime.now().millisecondsSinceEpoch}';

      final items = <SubscriptionItem>[
        // 1. Daily Milk
        SubscriptionItem(
          id: 'item_milk_${DateTime.now().millisecondsSinceEpoch}',
          subscriptionId: subId,
          productId: _milkType == 'Buffalo Milk' ? 'd_buffalo_milk' : 'd_a2milk',
          productName: _milkType == 'Buffalo Milk' ? 'Pure Buffalo Milk' : 'Fresh A2 Cow Milk',
          categoryId: 'dairy',
          categoryName: 'Dairy & Milk',
          emoji: '🥛',
          quantity: _milkQuantity,
          unit: 'L',
          pricePerUnit: _milkType == 'Buffalo Milk' ? 70.0 : 60.0,
          frequency: SubscriptionFrequency.daily,
          deliveryDay: 'Daily',
          startDate: DateTime.now().add(const Duration(days: 1)),
          nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
          status: SubscriptionItemStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // 2. Weekly Vegetable Basket
      if (_includeVegBasket) {
        items.add(
          SubscriptionItem(
            id: 'item_veg_${DateTime.now().millisecondsSinceEpoch}',
            subscriptionId: subId,
            productId: 'basket_veg_weekly',
            productName: 'Farm Fresh Vegetable Basket',
            categoryId: 'veg',
            categoryName: 'Vegetables',
            emoji: '🥬',
            quantity: 1.0,
            unit: 'Weekly Basket',
            pricePerUnit: 300.0,
            frequency: SubscriptionFrequency.weekly,
            deliveryDay: 'Sunday',
            startDate: DateTime.now().add(const Duration(days: 1)),
            nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
            status: SubscriptionItemStatus.active,
            priceType: SubscriptionPriceType.basketValue,
            basketValue: 300.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      // 3. Weekly Fruit Box
      if (_includeFruitBasket) {
        items.add(
          SubscriptionItem(
            id: 'item_fruit_${DateTime.now().millisecondsSinceEpoch}',
            subscriptionId: subId,
            productId: 'basket_fruit_weekly',
            productName: 'Seasonal Organic Fruit Box',
            categoryId: 'fruits',
            categoryName: 'Fruits',
            emoji: '🍎',
            quantity: 1.0,
            unit: 'Weekly Box',
            pricePerUnit: 250.0,
            frequency: SubscriptionFrequency.weekly,
            deliveryDay: 'Sunday',
            startDate: DateTime.now().add(const Duration(days: 1)),
            nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
            status: SubscriptionItemStatus.active,
            priceType: SubscriptionPriceType.basketValue,
            basketValue: 250.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      // 4. Weekly Eggs
      if (_includeEggs) {
        items.add(
          SubscriptionItem(
            id: 'item_eggs_${DateTime.now().millisecondsSinceEpoch}',
            subscriptionId: subId,
            productId: 'e_brown_eggs',
            productName: 'Brown Country Eggs (12 pcs)',
            categoryId: 'eggs',
            categoryName: 'Eggs',
            emoji: '🥚',
            quantity: 1.0,
            unit: '12 pcs',
            pricePerUnit: 120.0,
            frequency: SubscriptionFrequency.weekly,
            deliveryDay: 'Sunday',
            startDate: DateTime.now().add(const Duration(days: 1)),
            nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
            status: SubscriptionItemStatus.active,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      final subscription = SubscriptionModel(
        id: subId,
        userId: uid,
        name: 'Family Fresh Plan (${_familySize} Members)',
        planType: SubscriptionPlanType.familyFresh,
        startDate: DateTime.now().add(const Duration(days: 1)),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
        deliveryAddressId: addressId,
        deliveryAddress: address,
        deliverySlot: _selectedSlot,
        estimatedMonthlyAmount: _estimatedMonthlySpend,
        paymentMode: _selectedPayment == PaymentMethod.cashOnDelivery
            ? 'Cash on Delivery (Pay per drop)'
            : 'Online (Razorpay UPI / Cards)',
        items: items,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. CASH ON DELIVERY FLOW
      if (_selectedPayment == PaymentMethod.cashOnDelivery) {
        await SubscriptionRepository().createSubscription(subscription);

        if (mounted) {
          Navigator.pop(context);
          widget.onSubscriptionCreated?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Family Fresh Subscription activated! All items scheduled for delivery (COD).'),
              backgroundColor: Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // 2. ONLINE RAZORPAY PAYMENT FLOW
      final user = FirebaseAuth.instance.currentUser;
      final cartItems = items.map((i) {
        return CartItem(
          product: Product(
            id: i.productId,
            name: i.productName,
            categoryId: i.categoryId,
            categoryName: i.categoryName,
            price: i.pricePerUnit,
            unit: i.unit,
            emoji: i.emoji,
          ),
          quantity: i.quantity.round().clamp(1, 999),
        );
      }).toList();

      final result = await _paymentService.createRazorpayOrder(
        orderId: subId,
        items: cartItems,
        deliveryAddress: address,
        slotDate: 'Tomorrow',
        timeSlot: _selectedSlot,
      );

      if (!result.success || result.gatewayOrderId == null || result.gatewayOrderId!.isEmpty) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Could not initialize payment gateway.'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      _pendingSubscription = subscription;

      _paymentService.openCheckout(
        orderId: subId,
        gatewayOrderId: result.gatewayOrderId!,
        amountInPaise: (_firstDeliveryAmount * 100).round(),
        keyId: result.keyId,
        customerName: user?.displayName ?? 'Valued Family Subscriber',
        customerPhone: user?.phoneNumber ?? '',
        customerEmail: user?.email ?? '',
      );
    } catch (e) {
      debugPrint('FamilyFreshSheet: Submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted && _selectedPayment == PaymentMethod.cashOnDelivery) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Family Fresh Plan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Complete all-in-one recurring household bundle',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Configuration Form
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Family Size Selector
                Text(
                  '1. Select Family Size',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFamilySizeOption(2, '2-3 Members', '1L Milk/day'),
                    const SizedBox(width: 8),
                    _buildFamilySizeOption(4, '4-5 Members', '2L Milk/day'),
                    const SizedBox(width: 8),
                    _buildFamilySizeOption(6, '6+ Members', '3L Milk/day'),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. Milk Customization
                Text(
                  '2. Daily Fresh Milk',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildMilkTypeChip('Cow Milk', '₹60/L'),
                          const SizedBox(width: 10),
                          _buildMilkTypeChip('Buffalo Milk', '₹70/L'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Quantity',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: _milkQuantity > 0.5
                                    ? () => setState(() => _milkQuantity -= 0.5)
                                    : null,
                              ),
                              Text(
                                '${_milkQuantity == _milkQuantity.roundToDouble() ? _milkQuantity.toInt() : _milkQuantity} L / day',
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF166534)),
                                onPressed: () => setState(() => _milkQuantity += 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Weekly Baskets & Essentials
                Text(
                  '3. Weekly Baskets (Every Sunday)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                _buildBasketToggle(
                  title: 'Vegetable Basket',
                  subtitle: '₹300/week • 6-7 seasonal farm veggies',
                  emoji: '🥬',
                  value: _includeVegBasket,
                  onChanged: (v) => setState(() => _includeVegBasket = v),
                ),
                _buildBasketToggle(
                  title: 'Seasonal Fruit Basket',
                  subtitle: '₹250/week • Fresh orchard fruits',
                  emoji: '🍎',
                  value: _includeFruitBasket,
                  onChanged: (v) => setState(() => _includeFruitBasket = v),
                ),
                _buildBasketToggle(
                  title: 'Brown Eggs (12 pcs)',
                  subtitle: '₹120/week • Free-range country eggs',
                  emoji: '🥚',
                  value: _includeEggs,
                  onChanged: (v) => setState(() => _includeEggs = v),
                ),

                const SizedBox(height: 16),

                // Delivery Slot Selector
                Text(
                  'Morning Slot',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedSlot,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: '6:00 AM – 8:00 AM', child: Text('6:00 AM – 8:00 AM (Early Harvest)')),
                    DropdownMenuItem(value: '7:00 AM – 10:00 AM', child: Text('7:00 AM – 10:00 AM (Standard)')),
                  ],
                  onChanged: (v) => setState(() => _selectedSlot = v!),
                ),

                const SizedBox(height: 16),

                Text(
                  'Payment Mode',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),

                // Online Razorpay
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPayment != PaymentMethod.cashOnDelivery
                          ? const Color(0xFF166534)
                          : const Color(0xFFE2E8F0),
                      width: _selectedPayment != PaymentMethod.cashOnDelivery ? 1.5 : 1,
                    ),
                  ),
                  child: RadioListTile<PaymentMethod>(
                    value: PaymentMethod.upi,
                    groupValue: _selectedPayment,
                    activeColor: const Color(0xFF166534),
                    title: Row(
                      children: [
                        const Icon(Icons.flash_on_rounded, color: Color(0xFF166534), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Online Payment (Razorpay)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'UPI, Cards, NetBanking • Pay for first delivery',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                    onChanged: (val) => setState(() => _selectedPayment = PaymentMethod.upi),
                  ),
                ),

                // COD
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPayment == PaymentMethod.cashOnDelivery
                          ? const Color(0xFF166534)
                          : const Color(0xFFE2E8F0),
                      width: _selectedPayment == PaymentMethod.cashOnDelivery ? 1.5 : 1,
                    ),
                  ),
                  child: RadioListTile<PaymentMethod>(
                    value: PaymentMethod.cashOnDelivery,
                    groupValue: _selectedPayment,
                    activeColor: const Color(0xFF166534),
                    title: Row(
                      children: [
                        const Icon(Icons.payments_outlined, color: Color(0xFF64748B), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Cash on Delivery',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Pay delivery rider at morning drop',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                    onChanged: (val) => setState(() => _selectedPayment = PaymentMethod.cashOnDelivery),
                  ),
                ),

                const SizedBox(height: 12),

                // Breakdown Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tomorrow\'s First Delivery Amount',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF334155), fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '₹${_firstDeliveryAmount.toInt()}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Est. Monthly Family Spend',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
                          ),
                          Text(
                            '₹${_estimatedMonthlySpend.toInt()}/mo',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF166534)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar with Total & Submit
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Monthly Spend',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '₹${_estimatedMonthlySpend.toInt()}/mo',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFamilyFreshPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_selectedPayment != PaymentMethod.cashOnDelivery) ...[
                                const Icon(Icons.lock_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                _selectedPayment == PaymentMethod.cashOnDelivery
                                    ? 'Activate Plan (COD)'
                                    : 'Pay ₹${_firstDeliveryAmount.toInt()} & Activate',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilySizeOption(int size, String label, String hint) {
    final isSelected = _familySize == size;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _familySize = size;
            _milkQuantity = size == 2 ? 1.0 : (size == 4 ? 2.0 : 3.0);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF166534) : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hint,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilkTypeChip(String type, String price) {
    final isSelected = _milkType == type;
    return Expanded(
      child: ChoiceChip(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type),
            const SizedBox(width: 4),
            Text('($price)', style: const TextStyle(fontSize: 11)),
          ],
        ),
        selected: isSelected,
        selectedColor: const Color(0xFFDCFCE7),
        backgroundColor: const Color(0xFFF8FAFC),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? const Color(0xFF166534) : const Color(0xFF334155),
        ),
        onSelected: (_) => setState(() => _milkType = type),
      ),
    );
  }

  Widget _buildBasketToggle({
    required String title,
    required String subtitle,
    required String emoji,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SwitchListTile(
        value: value,
        activeColor: const Color(0xFF166534),
        onChanged: onChanged,
        secondary: Text(emoji, style: const TextStyle(fontSize: 22)),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
        ),
      ),
    );
  }
}
