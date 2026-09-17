import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/delivery_slot_helper.dart';
import '../../cart/data/cart_repository.dart';
import '../../cart/domain/cart_item.dart';
import '../../location/data/address_repository.dart';
import '../../location/domain/models/delivery_address.dart';
import '../../location/presentation/saved_addresses_screen.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/domain/customer_order.dart';
import '../data/payment_service.dart';
import '../domain/order_model.dart';
import 'order_success_screen.dart';
import 'payment_success_receipt_screen.dart';
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
  DeliveryAddress? _selectedAddressModel;
  PaymentMethod _selectedPayment = PaymentMethod.cashOnDelivery;
  String _selectedSlot = '6:00 AM – 8:00 AM';
  bool _isPlacingOrder = false;
  final PaymentService _paymentService = PaymentService();

  // Pending online payment state tracking
  String? _pendingOrderId;
  String? _pendingGatewayOrderId;
  DeliverySlot? _pendingSlot;
  bool _isNavigatedToSuccess = false;

  final List<String> _slots = [
    '6:00 AM – 8:00 AM',
    '8:00 AM – 10:00 AM',
    '5:00 PM – 7:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final defaultAddr = AddressRepository().getDefaultAddress();
    _selectedAddressModel = defaultAddr;
    _currentAddress = widget.deliveryAddress ??
        defaultAddr?.formattedAddress ??
        'Select delivery address';

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
    debugPrint(
      'CheckoutScreen: Razorpay Test payment success received: '
      'paymentId=${response.paymentId}, orderId=${response.orderId}, signature=${response.signature}',
    );
    if (!mounted) return;

    final localOrderId = _pendingOrderId;
    final gatewayOrderId = response.orderId ?? _pendingGatewayOrderId;
    final gatewayPaymentId = response.paymentId;
    final signature = response.signature;

    if (localOrderId == null ||
        gatewayOrderId == null ||
        gatewayPaymentId == null ||
        signature == null ||
        signature.isEmpty) {
      debugPrint('CheckoutScreen: Missing required parameters for verification payload.');
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment received, but verification details were incomplete. Please check your order history.',
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
            Text('Cryptographically verifying payment with bank...'),
          ],
        ),
        backgroundColor: Color(0xFF166534),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Call Cloud Function to cryptographically verify signature
    final verificationResult = await _paymentService.verifyPaymentSignature(
      orderId: localOrderId,
      gatewayOrderId: gatewayOrderId,
      gatewayPaymentId: gatewayPaymentId,
      signature: signature,
    );

    if (!mounted) return;

    if (verificationResult.success && verificationResult.paymentStatus == 'paid') {
      if (_isNavigatedToSuccess) return;
      _isNavigatedToSuccess = true;

      final slotDate = _pendingSlot?.date ?? DeliverySlotHelper.getTomorrowSlotDate();
      final slot = _pendingSlot ??
          DeliverySlot(
            date: slotDate,
            timeRange: _selectedSlot,
            label: 'Early Morning Harvest Drop',
          );

      final paidFreshlyOrder = FreshlyOrder(
        orderId: localOrderId,
        items: widget.items,
        deliveryAddress: _currentAddress,
        deliveryLatitude: _selectedAddressModel?.latitude,
        deliveryLongitude: _selectedAddressModel?.longitude,
        slot: slot,
        paymentMethod: _selectedPayment,
        paymentStatus: PaymentStatus.paid,
        paymentGateway: PaymentGateway.razorpay,
        gatewayOrderId: gatewayOrderId,
        gatewayPaymentId: gatewayPaymentId,
        paidAt: verificationResult.paidAt ?? DateTime.now(),
        itemTotal: _itemTotal,
        deliveryFee: _deliveryFee,
        couponDiscount: widget.couponDiscount,
        grandTotal: _grandTotal,
        orderTime: DateTime.now(),
      );

      final paidCustomerOrder = CustomerOrder(
        orderId: localOrderId.startsWith('#') ? localOrderId : '#$localOrderId',
        orderDate: DateTime.now(),
        slotDate: slot.date,
        timeSlot: _selectedSlot,
        status: OrderStatus.placed,
        items: widget.items,
        itemTotal: _itemTotal,
        deliveryFee: _deliveryFee,
        discount: widget.couponDiscount,
        grandTotal: _grandTotal,
        paymentMethod: _selectedPayment,
        paymentStatus: PaymentStatus.paid,
        paymentGateway: PaymentGateway.razorpay,
        gatewayOrderId: gatewayOrderId,
        gatewayPaymentId: gatewayPaymentId,
        paidAt: verificationResult.paidAt ?? DateTime.now(),
        deliveryAddress: _currentAddress,
        deliveryLatitude: _selectedAddressModel?.latitude,
        deliveryLongitude: _selectedAddressModel?.longitude,
        timeline: [
          const OrderTimelineStep(
            status: OrderStatus.placed,
            time: 'Just now',
            title: 'Order Placed & Paid',
            subtitle: 'Paid via Razorpay',
            isCompleted: true,
            isCurrent: true,
          ),
          const OrderTimelineStep(
            status: OrderStatus.preparing,
            time: 'Sunrise Harvest',
            title: 'Farm Harvest & Quality Inspection',
            subtitle: 'Sunrise Organic Farm, Shadnagar Hub',
            isCompleted: false,
          ),
          OrderTimelineStep(
            status: OrderStatus.outForDelivery,
            time: _selectedSlot,
            title: 'Out for Delivery',
            subtitle: 'On the way with Taaza Rider',
            isCompleted: false,
          ),
          const OrderTimelineStep(
            status: OrderStatus.delivered,
            time: 'Doorstep Drop',
            title: 'Delivered',
            subtitle: 'Doorstep contactless handoff',
            isCompleted: false,
          ),
        ],
      );

      // Save verified paid order to Cloud Firestore & local cache
      await OrderRepository().placeOrder(paidCustomerOrder);

      // Only after verified payment, clear the cart
      await CartRepository().clearCart();

      if (!mounted) return;

      setState(() => _isPlacingOrder = false);

      // 2. Navigate to PaymentSuccessReceiptScreen representing animated receipt & verified payment
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessReceiptScreen(
            order: paidFreshlyOrder,
            gatewayPaymentId: gatewayPaymentId,
            gatewayOrderId: gatewayOrderId,
            amountPaid: _grandTotal,
          ),
        ),
      );
    } else {
      // Verification failed or pending
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            verificationResult.errorMessage ??
                'Payment verification could not be confirmed. If money was deducted, your order will update shortly.',
          ),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
      'CheckoutScreen: Razorpay Test payment error: '
      'code=${response.code}, message=${response.message}',
    );
    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    final isCancelled = response.code == Razorpay.PAYMENT_CANCELLED ||
        (response.message != null &&
            response.message!.toLowerCase().contains('cancel'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCancelled
              ? 'Payment cancelled. Your cart is still saved. You can try again.'
              : 'Payment could not be completed: ${response.message ?? "Please try again"}',
        ),
        backgroundColor:
            isCancelled ? const Color(0xFF64748B) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('CheckoutScreen: External wallet selected: ${response.walletName}');
    if (!mounted) return;
    setState(() => _isPlacingOrder = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double get _itemTotal {
    return widget.items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get _deliveryFee => _itemTotal >= AppConstants.freeDeliveryThreshold
      ? 0.0
      : AppConstants.standardDeliveryFee;

  double get _grandTotal {
    final total = _itemTotal + _deliveryFee - widget.couponDiscount;
    return total > 0 ? total : 0.0;
  }

  Future<void> _handleChangeAddress() async {
    final selected = await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(
        builder: (context) => SavedAddressesScreen(
          isStandalone: true,
          onAddressSelected: (addr) {
            Navigator.pop(context, addr);
          },
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedAddressModel = selected;
        _currentAddress = selected.formattedAddress;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return; // Prevent double taps

    if (_currentAddress == 'Select delivery address' ||
        _currentAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select or add a delivery address before placing order'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    final randomNum = 10000 + Random().nextInt(90000);
    final orderId = 'FRSH-$randomNum';
    final slotDate = DeliverySlotHelper.getTomorrowSlotDate();
    final slot = DeliverySlot(
      date: slotDate,
      timeRange: _selectedSlot,
      label: 'Early Morning Harvest Drop',
    );

    // ==========================================
    // 1. CASH ON DELIVERY FLOW (100% Preserved)
    // ==========================================
    if (_selectedPayment == PaymentMethod.cashOnDelivery) {
      try {
        final freshlyOrder = FreshlyOrder(
          orderId: orderId,
          items: widget.items,
          deliveryAddress: _currentAddress,
          deliveryLatitude: _selectedAddressModel?.latitude,
          deliveryLongitude: _selectedAddressModel?.longitude,
          slot: slot,
          paymentMethod: PaymentMethod.cashOnDelivery,
          paymentStatus: PaymentStatus.pending,
          paymentGateway: PaymentGateway.cod,
          itemTotal: _itemTotal,
          deliveryFee: _deliveryFee,
          couponDiscount: widget.couponDiscount,
          grandTotal: _grandTotal,
          orderTime: DateTime.now(),
        );

        final customerOrder = CustomerOrder(
          orderId: '#$orderId',
          orderDate: DateTime.now(),
          slotDate: slot.date,
          timeSlot: _selectedSlot,
          status: OrderStatus.placed,
          items: widget.items,
          itemTotal: _itemTotal,
          deliveryFee: _deliveryFee,
          discount: widget.couponDiscount,
          grandTotal: _grandTotal,
          paymentMethod: PaymentMethod.cashOnDelivery,
          paymentStatus: PaymentStatus.pending,
          paymentGateway: PaymentGateway.cod,
          deliveryAddress: _currentAddress,
          deliveryLatitude: _selectedAddressModel?.latitude,
          deliveryLongitude: _selectedAddressModel?.longitude,
          timeline: [
            const OrderTimelineStep(
              status: OrderStatus.placed,
              time: 'Just now',
              title: 'Order Placed & Confirmed',
              subtitle: 'Pay on Drop',
              isCompleted: true,
              isCurrent: true,
            ),
            const OrderTimelineStep(
              status: OrderStatus.preparing,
              time: 'Sunrise Harvest',
              title: 'Farm Harvest & Quality Inspection',
              subtitle: 'Sunrise Organic Farm, Shadnagar Hub',
              isCompleted: false,
            ),
            OrderTimelineStep(
              status: OrderStatus.outForDelivery,
              time: _selectedSlot,
              title: 'Out for Delivery',
              subtitle: 'On the way with Taaza Rider',
              isCompleted: false,
            ),
            const OrderTimelineStep(
              status: OrderStatus.delivered,
              time: 'Doorstep Drop',
              title: 'Delivered',
              subtitle: 'Doorstep contactless handoff',
              isCompleted: false,
            ),
          ],
        );

        // 1. Save to Cloud Firestore
        await OrderRepository().placeOrder(customerOrder);

        // 2. Clear user's Firestore cart ONLY after order is created successfully
        await CartRepository().clearCart();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(
              order: freshlyOrder,
            ),
          ),
        );
      } catch (e) {
        debugPrint('CheckoutScreen: COD _placeOrder error: $e');
        if (mounted) {
          final fallbackOrder = FreshlyOrder(
            orderId: orderId,
            items: widget.items,
            deliveryAddress: _currentAddress,
            slot: slot,
            paymentMethod: _selectedPayment,
            paymentStatus: PaymentStatus.pending,
            paymentGateway: PaymentGateway.cod,
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
                order: fallbackOrder,
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isPlacingOrder = false);
        }
      }
      return;
    }

    // ==========================================
    // 2. ONLINE PAYMENT FLOW (Razorpay Test Mode)
    // ==========================================
    try {
      final user = FirebaseAuth.instance.currentUser;
      final result = await _paymentService.createRazorpayOrder(
        orderId: orderId,
        items: widget.items,
        couponCode: widget.appliedCoupon,
        deliveryAddress: _currentAddress,
        deliveryLatitude: _selectedAddressModel?.latitude,
        deliveryLongitude: _selectedAddressModel?.longitude,
        slotDate: slot.date,
        timeSlot: _selectedSlot,
      );

      if (!result.success ||
          result.gatewayOrderId == null ||
          result.gatewayOrderId!.isEmpty) {
        if (!mounted) return;
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ??
                'Could not initialize payment. Please try again.'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      _pendingOrderId = orderId;
      _pendingGatewayOrderId = result.gatewayOrderId!;
      _pendingSlot = slot;
      _isNavigatedToSuccess = false;

      // Open Razorpay Checkout Sheet in Test Mode
      _paymentService.openCheckout(
        orderId: orderId,
        gatewayOrderId: result.gatewayOrderId!,
        amountInPaise: result.amountInPaise,
        keyId: result.keyId,
        customerName: user?.displayName ?? 'Valued Customer',
        customerPhone: user?.phoneNumber ?? '',
        customerEmail: user?.email ?? '',
      );
    } catch (e) {
      debugPrint('CheckoutScreen: Online payment initialization error: $e');
      if (mounted) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Payment gateway temporarily unavailable. Please try again.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
                        onTap: _handleChangeAddress,
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
                    onPressed: _isPlacingOrder ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      disabledBackgroundColor:
                          const Color(0xFF166534).withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isPlacingOrder
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
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
