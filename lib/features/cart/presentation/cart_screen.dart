import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../checkout/presentation/checkout_screen.dart';
import '../../products/data/mock_products_data.dart';
import '../../products/presentation/product_details_screen.dart';
import '../domain/cart_item.dart';

/// Premium Cart Screen for Freshly customer mobile app
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
  late List<CartItem> _items;
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCoupon;
  double _couponDiscount = 0.0;
  String? _couponError;
  bool _noContactDelivery = false;
  final String _selectedDeliverySlot = 'Tomorrow, 6:00 AM – 8:00 AM';

  // Standard Mock Address
  late String _currentAddress;

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.deliveryAddress ??
        'Flat 402, Green Valley Apartments, Indiranagar, Bengaluru, 560038';

    if (widget.initialItems != null) {
      _items = List.from(widget.initialItems!);
    } else {
      // Default realistic Indian fresh cart items
      _items = [
        CartItem(
          product: MockProductsData.allProducts.firstWhere(
            (p) => p.name.contains('Tomato'),
            orElse: () => MockProductsData.allProducts[0],
          ),
          quantity: 2,
          selectedPack: '1 kg',
        ),
        CartItem(
          product: MockProductsData.allProducts.firstWhere(
            (p) => p.name.contains('Milk'),
            orElse: () => MockProductsData.allProducts[1],
          ),
          quantity: 1,
          selectedPack: '1 L',
        ),
        CartItem(
          product: MockProductsData.allProducts.firstWhere(
            (p) => p.name.contains('Egg'),
            orElse: () => MockProductsData.allProducts[2],
          ),
          quantity: 1,
          selectedPack: '6 pcs',
        ),
        CartItem(
          product: MockProductsData.allProducts.firstWhere(
            (p) => p.name.contains('Spinach') || p.name.contains('Palak'),
            orElse: () => MockProductsData.allProducts[3],
          ),
          quantity: 1,
          selectedPack: '250 g',
        ),
      ];
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  // Bill calculations
  int get _totalItemCount {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  double get _itemTotal {
    double total = 0;
    for (var item in _items) {
      total += item.subtotal;
    }
    return total;
  }

  double get _originalItemTotal {
    double total = 0;
    for (var item in _items) {
      total += item.originalSubtotal;
    }
    return total;
  }

  double get _productDiscount => _originalItemTotal - _itemTotal;

  double get _deliveryFee {
    if (_itemTotal >= 199 || _items.isEmpty) {
      return 0.0; // Free delivery over ₹199
    }
    return 25.0;
  }

  double get _grandTotal {
    if (_items.isEmpty) return 0.0;
    final total = _itemTotal + _deliveryFee - _couponDiscount;
    return total > 0 ? total : 0.0;
  }

  double get _totalSavings =>
      _productDiscount + _couponDiscount + (_deliveryFee == 0 ? 25.0 : 0.0);

  // Cart operations
  void _incrementItem(int index) {
    setState(() {
      _items[index].quantity++;
    });
  }

  void _decrementItem(int index) {
    setState(() {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _removeItem(index);
      }
    });
  }

  void _removeItem(int index) {
    final removed = _items[index];
    setState(() {
      _items.removeAt(index);
      if (_items.isEmpty) {
        _appliedCoupon = null;
        _couponDiscount = 0.0;
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Removed ${removed.product.name} from cart',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFF4ADE80),
          onPressed: () {
            setState(() {
              _items.insert(index, removed);
            });
          },
        ),
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Cart?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to remove all items from your Freshly cart?',
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _items.clear();
                _appliedCoupon = null;
                _couponDiscount = 0.0;
              });
            },
            child: Text(
              'Clear',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyCouponCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return;

    setState(() {
      _couponError = null;
      if (cleanCode == 'FRESH50') {
        if (_itemTotal >= 199) {
          _appliedCoupon = 'FRESH50';
          _couponDiscount = 50.0;
          _couponController.text = 'FRESH50';
        } else {
          _couponError = 'Cart value must be at least ₹199 to apply FRESH50';
        }
      } else if (cleanCode == 'ORGANIC10') {
        _appliedCoupon = 'ORGANIC10';
        _couponDiscount = (_itemTotal * 0.10).roundToDouble();
        _couponController.text = 'ORGANIC10';
      } else if (cleanCode == 'FRESHPASS') {
        _appliedCoupon = 'FRESHPASS';
        _couponDiscount = 25.0;
        _couponController.text = 'FRESHPASS';
      } else {
        _couponError = 'Invalid promo code. Try FRESH50 or ORGANIC10';
      }
    });

    if (_appliedCoupon != null) {
      FocusScope.of(context).unfocus();
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponDiscount = 0.0;
      _couponController.clear();
      _couponError = null;
    });
  }

  void _proceedToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          items: _items,
          deliveryAddress: _currentAddress,
          appliedCoupon: _appliedCoupon,
          couponDiscount: _couponDiscount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCartEmpty = _items.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          key: const ValueKey('cart_back_button'),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).maybePop(_items),
        ),
        title: Row(
          children: [
            Text(
              'My Cart',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            if (!isCartEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6E38).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_totalItemCount ${_totalItemCount == 1 ? 'item' : 'items'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B6E38),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!isCartEmpty)
            IconButton(
              key: const ValueKey('clear_cart_btn'),
              tooltip: 'Clear Cart',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFF64748B),
                size: 22,
              ),
              onPressed: _clearCart,
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: isCartEmpty ? _buildEmptyCartView() : _buildCartContent(),
          ),
        ),
      ),
      bottomNavigationBar: isCartEmpty ? null : _buildStickyCheckoutBar(),
    );
  }

  /// Empty Cart State matching Freshly Aesthetics
  Widget _buildEmptyCartView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Clean layered basket visual with soft floating rings
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEDF7EF),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B6E38).withValues(alpha: 0.08),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 105,
                    height: 105,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '🛒',
                    style: TextStyle(fontSize: 54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Title
          Text(
            'Your cart is empty',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Looks like you haven’t added anything to your cart yet. Explore fresh produce, milk & daily essentials from local organic farms.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Start Shopping CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const ValueKey('start_shopping_btn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B6E38),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: const Color(0xFF1B6E38).withValues(alpha: 0.3),
              ),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Start Shopping',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Popular Fresh Suggestions when empty
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
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Fresh Essentials',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickAddChip(
                      name: 'A2 Cow Milk',
                      price: '₹70',
                      emoji: '🥛',
                      onAdd: () {
                        setState(() {
                          _items.add(
                            CartItem(
                              product: MockProductsData.allProducts.firstWhere(
                                (p) => p.name.contains('Milk'),
                              ),
                              quantity: 1,
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildQuickAddChip(
                      name: 'Organic Eggs',
                      price: '₹75',
                      emoji: '🥚',
                      onAdd: () {
                        setState(() {
                          _items.add(
                            CartItem(
                              product: MockProductsData.allProducts.firstWhere(
                                (p) => p.name.contains('Egg'),
                              ),
                              quantity: 1,
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddChip({
    required String name,
    required String price,
    required String emoji,
    required VoidCallback onAdd,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B6E38),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.add_circle_rounded,
                color: Color(0xFF1B6E38),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Full Cart Content View
  Widget _buildCartContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Savings Ribbon Banner (if any)
        if (_totalSavings > 0)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are saving ₹${_totalSavings.toInt()} on this farm order!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 2. Delivery Address & Morning Slot Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: _buildDeliveryAddressCard(),
          ),
        ),

        // 3. Cart Items Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items in Cart',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  '${_items.length} ${_items.length == 1 ? 'variety' : 'varieties'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Cart Items List Cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildCartItemCard(index),
                );
              },
              childCount: _items.length,
            ),
          ),
        ),

        // 5. “+ Add More Items” Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: _buildAddMoreItemsButton(),
          ),
        ),

        // 6. Promo Code / Coupons Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPromoCodeSection(),
          ),
        ),

        // 7. Delivery Instructions Toggle
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildDeliveryInstructionsCard(),
          ),
        ),

        // 8. Bill Details / Price Summary Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: _buildBillSummaryCard(),
          ),
        ),

        // 9. Cancellation & Purity Policy Note
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: Color(0xFF1B6E38),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '100% Freshness Guarantee • Free replacement or instant refund if not satisfied at delivery door.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom space for sticky bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 30),
        ),
      ],
    );
  }

  /// 2. Delivery Address Card
  Widget _buildDeliveryAddressCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Delivery icon + title + change button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6E38).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF1B6E38),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivering to Home',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                key: const ValueKey('change_address_btn'),
                onPressed: _showChangeAddressDialog,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B6E38),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Slot info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wb_twilight_rounded,
                  color: Color(0xFF16A34A),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Morning Slot: $_selectedDeliverySlot',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3A2F),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChangeAddressDialog() {
    final List<String> mockAddresses = [
      'Flat 402, Green Valley Apartments, Indiranagar, Bengaluru',
      'Villa 12, Palm Meadows, Whitefield, Bengaluru',
      'A-204, Fortune Heights, HSR Layout Sector 2, Bengaluru',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Delivery Address',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...mockAddresses.map((addr) {
              final isSelected = _currentAddress == addr;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.location_on_rounded,
                  color: isSelected
                      ? const Color(0xFF1B6E38)
                      : const Color(0xFF94A3B8),
                ),
                title: Text(
                  addr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF1B6E38)
                        : const Color(0xFF1E293B),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF1B6E38))
                    : null,
                onTap: () {
                  setState(() {
                    _currentAddress = addr;
                  });
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 4. Individual Cart Item Card
  Widget _buildCartItemCard(int index) {
    final item = _items[index];
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Visual emoji/image in soft container
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: product),
                ),
              );
            },
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: product.bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  product.emoji,
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details: Name, Unit, and Prices
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 3),

                // Selected Unit / Pack
                Text(
                  item.selectedPack,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),

                // Price Row
                Row(
                  children: [
                    Text(
                      '₹${item.subtotal.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B6E38),
                      ),
                    ),
                    if (item.originalItemPrice != null &&
                        item.originalItemPrice! > item.itemPrice) ...[
                      const SizedBox(width: 6),
                      Text(
                        '₹${item.originalSubtotal.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Quantity Stepper & Remove Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Remove Icon
              GestureDetector(
                key: ValueKey('remove_item_${product.id}'),
                onTap: () => _removeItem(index),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),

              // Green Stepper Control
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6E38),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B6E38).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      key: ValueKey('cart_decrement_${product.id}'),
                      onTap: () => _decrementItem(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.transparent,
                        child: const Icon(
                          Icons.remove_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${item.quantity}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      key: ValueKey('cart_increment_${product.id}'),
                      onTap: () => _incrementItem(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.transparent,
                        child: const Icon(
                          Icons.add_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
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

  /// 5. “+ Add More Items” Button
  Widget _buildAddMoreItemsButton() {
    return InkWell(
      key: const ValueKey('add_more_items_btn'),
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1B6E38).withValues(alpha: 0.5),
            style: BorderStyle.solid,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: Color(0xFF1B6E38),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add More Fresh Items',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B6E38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 6. Promo Code Section
  Widget _buildPromoCodeSection() {
    final hasApplied = _appliedCoupon != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                color: Color(0xFF1B6E38),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Coupons & Offers',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (hasApplied) ...[
            // Applied coupon tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF16A34A),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Code "$_appliedCoupon" Applied',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF14532D),
                          ),
                        ),
                        Text(
                          'You saved ₹${_couponDiscount.toInt()} with this coupon',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('remove_coupon_btn'),
                    onPressed: _removeCoupon,
                    child: Text(
                      'Remove',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Promo input field
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _couponError != null
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: TextField(
                      key: const ValueKey('coupon_text_field'),
                      controller: _couponController,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    key: const ValueKey('apply_coupon_btn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B6E38),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _applyCouponCode(_couponController.text),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_couponError != null) ...[
              const SizedBox(height: 6),
              Text(
                _couponError!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Quick coupon suggestions chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCouponChip(
                    code: 'FRESH50',
                    desc: '₹50 OFF on ₹199+',
                    onTap: () => _applyCouponCode('FRESH50'),
                  ),
                  const SizedBox(width: 8),
                  _buildCouponChip(
                    code: 'ORGANIC10',
                    desc: '10% OFF all items',
                    onTap: () => _applyCouponCode('ORGANIC10'),
                  ),
                  const SizedBox(width: 8),
                  _buildCouponChip(
                    code: 'FRESHPASS',
                    desc: 'Free Delivery',
                    onTap: () => _applyCouponCode('FRESHPASS'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponChip({
    required String code,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Text(
              code,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B6E38),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '• $desc',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 7. Delivery Instructions Toggle Card
  Widget _buildDeliveryInstructionsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.doorbell_outlined,
            color: Color(0xFF1B6E38),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No-Contact Morning Delivery',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Leave package cleanly at the doorstep',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _noContactDelivery,
            activeColor: const Color(0xFF1B6E38),
            onChanged: (val) {
              setState(() {
                _noContactDelivery = val;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 8. Bill Details / Price Summary Card
  Widget _buildBillSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),

          // Item Total
          _buildBillRow(
            label: 'Item Total',
            value: '₹${_itemTotal.toInt()}',
            strikeValue: _originalItemTotal > _itemTotal
                ? '₹${_originalItemTotal.toInt()}'
                : null,
          ),
          const SizedBox(height: 8),

          // Delivery Fee
          _buildBillRow(
            label: 'Delivery Partner Fee',
            value: _deliveryFee == 0 ? 'FREE' : '₹${_deliveryFee.toInt()}',
            isFree: _deliveryFee == 0,
            strikeValue: _deliveryFee == 0 ? '₹25' : null,
          ),
          const SizedBox(height: 8),

          // Handling & Eco-packaging
          _buildBillRow(
            label: 'Handling & Eco-Packaging',
            value: 'FREE',
            isFree: true,
            strikeValue: '₹10',
          ),

          // Discount if applied
          if (_couponDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              label: 'Coupon Discount (${_appliedCoupon ?? ""})',
              value: '-₹${_couponDiscount.toInt()}',
              isGreen: true,
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '₹${_grandTotal.toInt()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B6E38),
                ),
              ),
            ],
          ),

          if (_totalSavings > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    color: Color(0xFF16A34A),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Total Savings: ₹${_totalSavings.toInt()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillRow({
    required String label,
    required String value,
    String? strikeValue,
    bool isFree = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (strikeValue != null) ...[
              Text(
                strikeValue,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight:
                    isFree || isGreen ? FontWeight.w800 : FontWeight.w700,
                color: isFree || isGreen
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Sticky Bottom Proceed to Checkout Bar
  Widget _buildStickyCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Left Column: Total to Pay
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL TO PAY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '₹${_grandTotal.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right Button: Proceed to Checkout
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey('proceed_to_checkout_btn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6E38),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: const Color(0xFF1B6E38).withValues(alpha: 0.3),
                  ),
                  onPressed: _proceedToCheckout,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Proceed to Checkout',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Interactive Order Placement Modal Bottom Sheet
  Widget _buildCheckoutConfirmationSheet(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Success Harvest Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Order Placed Successfully!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Your fresh farm harvest will be delivered to $_currentAddress on $_selectedDeliverySlot.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Summary Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Amount to Pay on Delivery:',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                Text(
                  '₹${_grandTotal.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B6E38),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B6E38),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _items.clear();
                });
              },
              child: Text(
                'Continue Shopping',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
