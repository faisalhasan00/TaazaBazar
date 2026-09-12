import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../cart/domain/cart_item.dart';
import '../../products/data/mock_products_data.dart';
import '../domain/order_model.dart';
import 'order_success_screen.dart';

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
  late String _addressTag;
  int _selectedDateIndex = 0;
  int _selectedSlotIndex = 0;
  PaymentMethod _selectedPayment = PaymentMethod.cashOnDelivery;
  bool _isItemsExpanded = true;

  final List<String> _dates = [
    'Tomorrow (Sun, 13 Sep)',
    'Mon, 14 Sep',
    'Tue, 15 Sep',
  ];

  final List<Map<String, dynamic>> _slots = [
    {
      'title': '6:00 AM – 8:00 AM',
      'subtitle': 'Early Morning Harvest Drop',
      'icon': Icons.wb_twilight_rounded,
      'isPopular': true,
    },
    {
      'title': '8:00 AM – 10:00 AM',
      'subtitle': 'Morning Standard Slot',
      'icon': Icons.wb_sunny_rounded,
      'isPopular': false,
    },
    {
      'title': '5:00 PM – 7:00 PM',
      'subtitle': 'Evening Fresh Delivery',
      'icon': Icons.nights_stay_rounded,
      'isPopular': false,
    },
  ];

  final List<String> _availableAddresses = [
    'Flat 402, Green Valley Apartments, Indiranagar, Bengaluru, 560038',
    'Villa 12, Palm Meadows, Whitefield, Bengaluru, 560066',
    'A-204, Fortune Heights, HSR Layout Sector 2, Bengaluru, 560102',
  ];

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.deliveryAddress ?? _availableAddresses[0];
    _addressTag = 'HOME';
  }

  // Bill calculations
  double get _itemTotal {
    return widget.items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get _originalItemTotal {
    return widget.items.fold(0.0, (sum, item) => sum + item.originalSubtotal);
  }

  double get _productDiscount => _originalItemTotal - _itemTotal;

  double get _deliveryFee => _itemTotal >= 199 ? 0.0 : 25.0;

  double get _grandTotal {
    final total = _itemTotal + _deliveryFee - widget.couponDiscount;
    return total > 0 ? total : 0.0;
  }

  double get _totalSavings =>
      _productDiscount + widget.couponDiscount + (_deliveryFee == 0 ? 25.0 : 0.0);

  void _changeAddress() {
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
            ..._availableAddresses.map((addr) {
              final isSelected = _currentAddress == addr;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.location_on_rounded,
                  color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFF94A3B8),
                ),
                title: Text(
                  addr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFF1E293B),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1B6E38))
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

  void _placeOrder() {
    final randomId = Random().nextInt(90000) + 10000;
    final orderId = '#FRSH-$randomId';

    final slot = DeliverySlot(
      date: _dates[_selectedDateIndex],
      timeRange: _slots[_selectedSlotIndex]['title'],
      label: _slots[_selectedSlotIndex]['subtitle'],
      isPopular: _slots[_selectedSlotIndex]['isPopular'],
    );

    final placedOrder = FreshlyOrder(
      orderId: orderId,
      items: widget.items,
      deliveryAddress: _currentAddress,
      slot: slot,
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
        builder: (_) => OrderSuccessScreen(order: placedOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          key: const ValueKey('checkout_back_btn'),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
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
                // 1. Delivery Address Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: _buildAddressCard(),
                  ),
                ),

                // 2. Delivery Slot Selection
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: _buildSlotSelectionCard(),
                  ),
                ),

                // 3. Order Items Summary (Collapsible)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: _buildOrderItemsCard(),
                  ),
                ),

                // 4. Payment Method Selection
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: _buildPaymentMethodCard(),
                  ),
                ),

                // 5. Bill Details / Summary Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: _buildBillSummaryCard(),
                  ),
                ),

                // 6. Security & Purity Badge
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 16,
                          color: Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '100% Secure Checkout & Farm Purity Guaranteed',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Spacing for sticky bottom bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyPlaceOrderBar(),
    );
  }

  /// 1. Delivery Address Card with Change Address Action
  Widget _buildAddressCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B6E38).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _addressTag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B6E38),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Delivery Address',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                key: const ValueKey('checkout_change_address_btn'),
                onPressed: _changeAddress,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change Address',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B6E38),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF1B6E38),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentAddress,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Delivery Date/Time Slot Selection
  Widget _buildSlotSelectionCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF1B6E38),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Delivery Schedule',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_dates.length, (i) {
                final isSelected = _selectedDateIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDateIndex = i;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1B6E38).withValues(alpha: 0.12)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        _dates[i],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),
          Text(
            'Select Time Slot',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          // Time Slots List
          ...List.generate(_slots.length, (i) {
            final slot = _slots[i];
            final isSelected = _selectedSlotIndex == i;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSlotIndex = i;
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        slot['icon'] as IconData,
                        color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  slot['title'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                if (slot['isPopular'] as bool) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'POPULAR',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              slot['subtitle'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio<int>(
                        value: i,
                        groupValue: _selectedSlotIndex,
                        activeColor: const Color(0xFF1B6E38),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedSlotIndex = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 3. Order Items Summary Card
  Widget _buildOrderItemsCard() {
    final itemCount = widget.items.fold(0, (sum, i) => sum + i.quantity);

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
          InkWell(
            onTap: () {
              setState(() {
                _isItemsExpanded = !_isItemsExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF1B6E38),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Order Items ($itemCount)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isItemsExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),

          if (_isItemsExpanded) ...[
            const Divider(height: 20, color: Color(0xFFF1F5F9)),
            ...widget.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(
                      item.product.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            item.selectedPack,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
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
                    const SizedBox(width: 12),
                    Text(
                      '₹${item.subtotal.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// 4. Payment Method Section
  Widget _buildPaymentMethodCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payment_rounded,
                color: Color(0xFF1B6E38),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Method',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...PaymentMethod.values.map((method) {
            final isSelected = _selectedPayment == method;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                key: ValueKey('payment_method_${method.name}'),
                onTap: () {
                  setState(() {
                    _selectedPayment = method;
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(method.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              method.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio<PaymentMethod>(
                        value: method,
                        groupValue: _selectedPayment,
                        activeColor: const Color(0xFF1B6E38),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPayment = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 5. Bill Details / Price Summary Card
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
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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

          _buildSummaryRow(
            label: 'Item Total',
            value: '₹${_itemTotal.toInt()}',
            strikeValue: _originalItemTotal > _itemTotal ? '₹${_originalItemTotal.toInt()}' : null,
          ),
          const SizedBox(height: 8),

          _buildSummaryRow(
            label: 'Delivery Partner Fee',
            value: _deliveryFee == 0 ? 'FREE' : '₹${_deliveryFee.toInt()}',
            isFree: _deliveryFee == 0,
            strikeValue: _deliveryFee == 0 ? '₹25' : null,
          ),
          const SizedBox(height: 8),

          _buildSummaryRow(
            label: 'Handling & Eco-Packaging',
            value: 'FREE',
            isFree: true,
            strikeValue: '₹10',
          ),

          if (widget.couponDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              label: 'Coupon Discount (${widget.appliedCoupon ?? ""})',
              value: '-₹${widget.couponDiscount.toInt()}',
              isGreen: true,
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),

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
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
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
                fontWeight: isFree || isGreen ? FontWeight.w800 : FontWeight.w700,
                color: isFree || isGreen ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Sticky Bottom "Place Order" Bar
  Widget _buildStickyPlaceOrderBar() {
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
            // Left Total Column
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
                  Text(
                    '₹${_grandTotal.toInt()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right "Place Order" Button
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey('place_order_btn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6E38),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: const Color(0xFF1B6E38).withValues(alpha: 0.3),
                  ),
                  onPressed: _placeOrder,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Place Order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
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
}
