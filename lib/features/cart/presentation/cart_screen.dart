import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../checkout/presentation/checkout_screen.dart';
import '../../coupons/data/coupon_repository.dart';
import '../../location/data/address_repository.dart';
import '../../location/domain/models/delivery_address.dart';
import '../../location/presentation/saved_addresses_screen.dart';
import '../data/cart_repository.dart';
import '../domain/cart_item.dart';
import 'widgets/cart_bill_details.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/coupon_section.dart';
import 'widgets/delivery_address_card.dart';
import 'widgets/empty_cart_view.dart';

/// Premium Cart Screen for Freshly customer mobile app composed of micro-feature widgets
class CartScreen extends StatefulWidget {
  final List<CartItem>? initialItems;
  final String? deliveryAddress;

  const CartScreen({
    super.key,
    this.initialItems,
    this.deliveryAddress,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartRepo = CartRepository();
  late List<CartItem> _items;
  StreamSubscription<List<CartItem>>? _cartSubscription;
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCoupon;
  double _couponDiscount = 0.0;
  final String _selectedDeliverySlot = '6:00 AM – 8:00 AM';
  late String _currentAddress;

  @override
  void initState() {
    super.initState();
    final defaultAddr = AddressRepository().getDefaultAddress();
    _currentAddress = widget.deliveryAddress ??
        defaultAddr?.formattedAddress ??
        'Select delivery address';

    if (widget.initialItems != null) {
      _items = List.from(widget.initialItems!);
      _cartRepo.setInitialCache(_items);
    } else {
      _items = List.from(_cartRepo.cachedCartItems);
    }

    if (widget.initialItems == null) {
      _cartSubscription = _cartRepo.getCartStream().listen((list) {
        if (mounted) {
          setState(() {
            _items = List.from(list);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _couponController.dispose();
    super.dispose();
  }

  double get _itemTotal {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get _deliveryFee {
    return _itemTotal >= AppConstants.freeDeliveryThreshold || _items.isEmpty
        ? 0.0
        : AppConstants.standardDeliveryFee;
  }

  double get _grandTotal {
    final total = _itemTotal + _deliveryFee - _couponDiscount;
    return total > 0 ? total : 0.0;
  }

  void _incrementItem(int index) {
    final item = _items[index];
    setState(() {
      item.quantity++;
    });
    _cartRepo.updateQuantity(item.product.id, item.quantity);
  }

  void _decrementItem(int index) {
    final item = _items[index];
    if (item.quantity > 1) {
      setState(() {
        item.quantity--;
      });
      _cartRepo.updateQuantity(item.product.id, item.quantity);
    } else {
      _removeItem(index);
    }
  }

  void _removeItem(int index) {
    final removed = _items[index];
    setState(() {
      _items.removeAt(index);
    });
    _cartRepo.removeItem(removed.product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${removed.product.name} from cart'),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearCart() {
    setState(() {
      _items.clear();
      _appliedCoupon = null;
      _couponDiscount = 0.0;
    });
    _cartRepo.clearCart();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final coupon = await CouponRepository().getCouponByCode(code);
    if (coupon != null && coupon.isValidFor(_itemTotal)) {
      final discount = coupon.calculateDiscount(_itemTotal);
      setState(() {
        _appliedCoupon = coupon.code;
        _couponDiscount = discount;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Coupon ${coupon.code} applied: ₹${discount.toInt()} discount!'),
          backgroundColor: const Color(0xFF166534),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (coupon != null && !coupon.isValidFor(_itemTotal)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum order value of ₹${coupon.minOrder.toInt()} required for ${coupon.code}'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid coupon code. Try FRESH50 or TAAZA100'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponDiscount = 0.0;
      _couponController.clear();
    });
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
        _currentAddress = selected.formattedAddress;
      });
    }
  }

  void _proceedToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          items: _items,
          appliedCoupon: _appliedCoupon,
          couponDiscount: _couponDiscount,
          deliveryAddress: _currentAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _items.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('cart_back_button'),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Cart',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          if (!isEmpty)
            IconButton(
              key: const ValueKey('clear_cart_btn'),
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Color(0xFFDC2626),
              ),
              tooltip: 'Clear Cart',
              onPressed: _clearCart,
            ),
        ],
      ),
      body: isEmpty
          ? EmptyCartView(
              onStartShopping: () => Navigator.of(context).pop(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Delivery Address Card
                  DeliveryAddressCard(
                    address: _currentAddress,
                    slot: _selectedDeliverySlot,
                    onChangeAddress: _handleChangeAddress,
                  ),
                  const SizedBox(height: 16),

                  // 2. Items List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items in Cart',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${_items.length} items',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Cart Items
                  ...List.generate(_items.length, (idx) {
                    final item = _items[idx];
                    return CartItemTile(
                      item: item,
                      onIncrement: () => _incrementItem(idx),
                      onDecrement: () => _decrementItem(idx),
                      onRemove: () => _removeItem(idx),
                    );
                  }),
                  const SizedBox(height: 8),

                  // 4. Add More Items Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      key: const ValueKey('add_more_items_btn'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(
                        'Add More Items',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF166534),
                        side: const BorderSide(color: Color(0xFF166534)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Coupons & Offers
                  CouponSection(
                    controller: _couponController,
                    appliedCoupon: _appliedCoupon,
                    couponDiscount: _couponDiscount,
                    onApply: _applyCoupon,
                    onRemove: _removeCoupon,
                  ),
                  const SizedBox(height: 20),

                  // 6. Bill Details
                  CartBillDetails(
                    itemTotal: _itemTotal,
                    deliveryFee: _deliveryFee,
                    couponDiscount: _couponDiscount,
                    grandTotal: _grandTotal,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                  ),
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
                          'TOTAL TO PAY',
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
                          key: const ValueKey('proceed_to_checkout_btn'),
                          onPressed: _proceedToCheckout,
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
                                'Proceed to Checkout',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
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
