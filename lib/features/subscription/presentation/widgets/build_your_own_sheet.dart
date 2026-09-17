import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../checkout/data/payment_service.dart';
import '../../../checkout/domain/order_model.dart';
import '../../../location/data/address_repository.dart';
import '../../../products/data/mock_products_data.dart';
import '../../../products/data/product_repository.dart';
import '../../../products/domain/product_model.dart';
import '../../data/subscription_repository.dart';
import '../../domain/subscription_model.dart';
import '../../../checkout/presentation/payment_success_receipt_screen.dart';

/// Modal bottom sheet for "Build Your Own Subscription" flow
class BuildYourOwnSheet extends StatefulWidget {
  final VoidCallback? onSubscriptionCreated;

  const BuildYourOwnSheet({
    super.key,
    this.onSubscriptionCreated,
  });

  @override
  State<BuildYourOwnSheet> createState() => _BuildYourOwnSheetState();
}

class _BuildYourOwnSheetState extends State<BuildYourOwnSheet> {
  int _currentStep = 0; // 0: Select Products, 1: Configure Frequencies & Quantities, 2: Slot & Confirm
  final List<Product> _selectedProducts = [];
  final Map<String, SubscriptionFrequency> _frequencies = {};
  final Map<String, double> _quantities = {};
  final Map<String, String> _deliveryDays = {};
  String _selectedSlot = '6:00 AM – 8:00 AM';
  PaymentMethod _selectedPayment = PaymentMethod.upi;
  bool _isSubmitting = false;

  final PaymentService _paymentService = PaymentService();
  SubscriptionModel? _pendingSubscription;

  final List<String> _deliverySlots = [
    '6:00 AM – 8:00 AM',
    '7:00 AM – 10:00 AM',
  ];

  final List<String> _weekdays = [
    'Daily',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    // Default pre-selection with milk & essentials if available
    final products = ProductRepository().cachedProducts.isNotEmpty
        ? ProductRepository().cachedProducts
        : MockProductsData.allProducts;

    final defaultMilk = products.firstWhere(
      (p) => p.categoryId.toLowerCase().contains('milk') || p.id == 'd_a2milk' || p.id == 'd_buffalo_milk',
      orElse: () => products.first,
    );
    _selectedProducts.add(defaultMilk);
    _frequencies[defaultMilk.id] = SubscriptionFrequency.daily;
    _quantities[defaultMilk.id] = 1.0;
    _deliveryDays[defaultMilk.id] = 'Daily';

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
    debugPrint('BuildYourOwnSheet: Razorpay payment success callback received: paymentId=${response.paymentId}');
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
    debugPrint('BuildYourOwnSheet: Razorpay payment error: ${response.message}');
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

  double get _estimatedMonthlySpend {
    double total = 0;
    for (final prod in _selectedProducts) {
      final qty = _quantities[prod.id] ?? 1.0;
      final freq = _frequencies[prod.id] ?? SubscriptionFrequency.daily;
      total += (prod.price * qty) * freq.monthlyMultiplier;
    }
    return total;
  }

  double get _firstDeliveryAmount {
    double total = 0;
    for (final prod in _selectedProducts) {
      final qty = _quantities[prod.id] ?? 1.0;
      total += (prod.price * qty);
    }
    return total > 0 ? total : 50.0;
  }

  void _toggleProduct(Product product) {
    setState(() {
      if (_selectedProducts.any((p) => p.id == product.id)) {
        if (_selectedProducts.length > 1) {
          _selectedProducts.removeWhere((p) => p.id == product.id);
          _frequencies.remove(product.id);
          _quantities.remove(product.id);
          _deliveryDays.remove(product.id);
        }
      } else {
        _selectedProducts.add(product);
        _frequencies[product.id] = product.categoryId.toLowerCase().contains('milk')
            ? SubscriptionFrequency.daily
            : SubscriptionFrequency.weekly;
        _quantities[product.id] = 1.0;
        _deliveryDays[product.id] = 'Daily';
      }
    });
  }

  Future<void> _submitSubscription() async {
    setState(() => _isSubmitting = true);
    try {
      final defaultAddr = AddressRepository().getDefaultAddress();
      final address = defaultAddr?.formattedAddress ?? 'Current Delivery Location';
      final addressId = defaultAddr?.id ?? 'default_addr';
      final uid = FirebaseAuthService().currentUserId ?? 'guest_user';
      final subId = 'sub_${DateTime.now().millisecondsSinceEpoch}';

      final items = _selectedProducts.map((prod) {
        final qty = _quantities[prod.id] ?? 1.0;
        final freq = _frequencies[prod.id] ?? SubscriptionFrequency.daily;
        final day = _deliveryDays[prod.id] ?? 'Daily';

        return SubscriptionItem(
          id: 'item_${prod.id}_${DateTime.now().millisecondsSinceEpoch}',
          subscriptionId: subId,
          productId: prod.id,
          productName: prod.name,
          categoryId: prod.categoryId,
          categoryName: prod.categoryName,
          emoji: prod.emoji,
          quantity: qty,
          unit: prod.unit,
          pricePerUnit: prod.price,
          frequency: freq,
          deliveryDay: day,
          startDate: DateTime.now().add(const Duration(days: 1)),
          nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
          status: SubscriptionItemStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      final subscription = SubscriptionModel(
        id: subId,
        userId: uid,
        name: 'My Custom Household Basket',
        planType: SubscriptionPlanType.buildYourOwn,
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
              content: Text('🎉 Your Custom Subscription is active! Tomorrow\'s delivery scheduled (COD).'),
              backgroundColor: Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // 2. ONLINE RAZORPAY PAYMENT FLOW
      final user = FirebaseAuth.instance.currentUser;
      final cartItems = _selectedProducts.map((p) {
        return CartItem(
          product: p,
          quantity: (_quantities[p.id] ?? 1.0).round().clamp(1, 999),
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
        customerName: user?.displayName ?? 'Valued Subscriber',
        customerPhone: user?.phoneNumber ?? '',
        customerEmail: user?.email ?? '',
      );
    } catch (e) {
      debugPrint('BuildYourOwnSheet: Submit error: $e');
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
    final availableProducts = ProductRepository().cachedProducts.isNotEmpty
        ? ProductRepository().cachedProducts
        : MockProductsData.allProducts;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
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
                          'Build Your Own Subscription',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Step ${_currentStep + 1} of 3 • Custom Recurring Basket',
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

          // Step Content
          Expanded(
            child: _currentStep == 0
                ? _buildStep1ProductSelection(availableProducts)
                : _currentStep == 1
                    ? _buildStep2FrequencyConfig()
                    : _buildStep3ReviewAndConfirm(),
          ),

          // Bottom Bar with Live Estimated Spend & Next / Confirm CTA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
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
                  if (_currentStep > 0) ...[
                    OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_currentStep < 2) {
                              setState(() => _currentStep++);
                            } else {
                              _submitSubscription();
                            }
                          },
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
                              if (_currentStep == 2 && _selectedPayment != PaymentMethod.cashOnDelivery) ...[
                                const Icon(Icons.lock_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                _currentStep < 2
                                    ? 'Next'
                                    : _selectedPayment == PaymentMethod.cashOnDelivery
                                        ? 'Subscribe (COD)'
                                        : 'Pay ₹${_firstDeliveryAmount.toInt()} & Subscribe',
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

  Widget _buildStep1ProductSelection(List<Product> products) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Select items for your recurring basket:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ...products.map((prod) {
          final isSelected = _selectedProducts.any((p) => p.id == prod.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: CheckboxListTile(
              value: isSelected,
              activeColor: const Color(0xFF166534),
              onChanged: (_) => _toggleProduct(prod),
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(prod.emoji, style: const TextStyle(fontSize: 20))),
              ),
              title: Text(
                prod.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                '₹${prod.price.toInt()} / ${prod.unit} • ${prod.categoryName}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2FrequencyConfig() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Set independent frequency & quantity for each item:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ..._selectedProducts.map((prod) {
          final qty = _quantities[prod.id] ?? 1.0;
          final freq = _frequencies[prod.id] ?? SubscriptionFrequency.daily;
          final day = _deliveryDays[prod.id] ?? 'Daily';

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(prod.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prod.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    // Quantity Counter
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: qty > 1
                              ? () => setState(() => _quantities[prod.id] = qty - 1)
                              : null,
                        ),
                        Text(
                          '${qty.toInt()} ${prod.unit}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF166534)),
                          onPressed: () => setState(() => _quantities[prod.id] = qty + 1),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Frequency Selector
                Text(
                  'Delivery Frequency',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: SubscriptionFrequency.values.map((f) {
                    final isSelected = freq == f;
                    return ChoiceChip(
                      label: Text(f.label),
                      selected: isSelected,
                      selectedColor: const Color(0xFFDCFCE7),
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF166534) : const Color(0xFF475569),
                      ),
                      onSelected: (_) => setState(() => _frequencies[prod.id] = f),
                    );
                  }).toList(),
                ),

                if (freq == SubscriptionFrequency.weekly) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Preferred Delivery Day',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _weekdays.contains(day) ? day : 'Sunday',
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _weekdays.map((w) {
                      return DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _deliveryDays[prod.id] = val);
                    },
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep3ReviewAndConfirm() {
    final defaultAddr = AddressRepository().getDefaultAddress();
    final address = defaultAddr?.formattedAddress ?? 'Current Delivery Location';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // One combined delivery benefit banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.eco_rounded, color: Color(0xFF166534), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Combined Delivery Advantage',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF166534),
                      ),
                    ),
                    Text(
                      'All items scheduled for the same morning arrive together in one fresh eco-delivery.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Delivery Address
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded, color: Color(0xFF166534), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivering To',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
        ),

        const SizedBox(height: 16),

        Text(
          'Select Morning Delivery Slot',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        ..._deliverySlots.map((slot) {
          final isSelected = _selectedSlot == slot;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: RadioListTile<String>(
              value: slot,
              groupValue: _selectedSlot,
              activeColor: const Color(0xFF166534),
              title: Text(
                slot,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                slot.contains('6:00') ? 'Direct from morning farm harvest' : 'Standard morning slot',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              onChanged: (val) => setState(() => _selectedSlot = val!),
            ),
          );
        }),

        const SizedBox(height: 16),

        Text(
          'Payment Mode',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),

        // Online Razorpay Option
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'UPI (GPay/PhonePe), Cards, NetBanking • Pay for first delivery',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            onChanged: (val) => setState(() => _selectedPayment = PaymentMethod.upi),
          ),
        ),

        // Cash on Delivery Option
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Pay cash or UPI to delivery partner upon doorstep delivery',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            onChanged: (val) => setState(() => _selectedPayment = PaymentMethod.cashOnDelivery),
          ),
        ),

        const SizedBox(height: 16),

        // First delivery payment card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tomorrow\'s First Basket Total',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF334155), fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${_firstDeliveryAmount.toInt()}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Est. Monthly Plan Value',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  Text(
                    '₹${_estimatedMonthlySpend.toInt()}/mo',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF166534)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Dynamic vegetable/fruit basket notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Text(
            '💡 You can modify items, quantities, pause, or skip deliveries any night before 10:00 PM cutoff.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF92400E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
