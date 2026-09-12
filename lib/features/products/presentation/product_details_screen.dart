import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_products_data.dart';
import '../domain/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final String? deliveryAddress;
  final int initialQuantity;
  final Function(String productId, int quantity)? onCartUpdated;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.deliveryAddress,
    this.initialQuantity = 0,
    this.onCartUpdated,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late int _quantity;
  bool _isFavorite = false;
  int _selectedVariantIndex = 0;

  final List<String> _variants = ['Standard Pack', 'Double Saver (2x)', 'Family Pack (4x)'];

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  double get _multiplier {
    if (_selectedVariantIndex == 1) return 1.9;
    if (_selectedVariantIndex == 2) return 3.6;
    return 1.0;
  }

  double get _unitPrice => widget.product.price * _multiplier;
  double get _totalPrice => _unitPrice * _quantity;

  void _handleAddToCart() {
    widget.onCartUpdated?.call(widget.product.id, _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B6E38),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added $_quantity × ${widget.product.name} to your basket',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Navigator.pop(context, _quantity);
  }

  List<Product> get _relatedProducts {
    return MockProductsData.allProducts
        .where((p) => p.id != widget.product.id && p.categoryId == widget.product.categoryId)
        .take(6)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.deliveryAddress ?? 'Flat 402, Oakwood, Shadnagar';
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                // Scrollable Content
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // 1. Large Top Hero Image & Navigation Buttons
                      SliverToBoxAdapter(
                        child: _buildHeroImageSection(product),
                      ),

                      // 2. Product Name, Rating, Price & Unit Row
                      SliverToBoxAdapter(
                        child: _buildHeaderInfo(product),
                      ),

                      // 3. Weight / Pack Variant Selector
                      SliverToBoxAdapter(
                        child: _buildPackSelector(),
                      ),

                      // 4. Quantity Stepper Row
                      SliverToBoxAdapter(
                        child: _buildQuantityStepperRow(),
                      ),

                      // 5. Fresh / Organic Quality Banner
                      SliverToBoxAdapter(
                        child: _buildQualityBanner(product),
                      ),

                      // 6. Delivery Information Card
                      SliverToBoxAdapter(
                        child: _buildDeliveryInfoCard(address),
                      ),

                      // 7. Product Description
                      SliverToBoxAdapter(
                        child: _buildDescriptionSection(product),
                      ),

                      // 8. Key Benefits Section
                      SliverToBoxAdapter(
                        child: _buildKeyBenefitsSection(product),
                      ),

                      // 9. Farm Origin & Storage Specs
                      SliverToBoxAdapter(
                        child: _buildOriginSpecs(product),
                      ),

                      // 10. "You May Also Like" Related Products
                      if (_relatedProducts.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildYouMayAlsoLikeSection(),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  ),
                ),

                // Sticky Bottom Bar with Total Price & Add to Cart
                _buildStickyBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Top Hero Image with Back, Favorite & Share Floating Buttons
  Widget _buildHeroImageSection(Product product) {
    return Stack(
      children: [
        // Large pastel image backdrop
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: product.bgColor,
            gradient: LinearGradient(
              colors: [
                product.bgColor,
                product.bgColor.withValues(alpha: 0.8),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'product_image_${product.id}',
              child: Text(
                product.emoji,
                style: const TextStyle(fontSize: 120),
              ),
            ),
          ),
        ),

        // Floating Top Bar: Back, Title, Favorite, Share
        Positioned(
          top: 12,
          left: 14,
          right: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              _buildCircleActionButton(
                key: const ValueKey('product_details_back_btn'),
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),

              // Right Action Buttons: Favorite & Share
              Row(
                children: [
                  _buildCircleActionButton(
                    key: const ValueKey('product_details_favorite_btn'),
                    icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    iconColor: _isFavorite ? const Color(0xFFE11D48) : const Color(0xFF1E293B),
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          content: Text(
                            _isFavorite ? 'Saved to your favorites' : 'Removed from favorites',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildCircleActionButton(
                    key: const ValueKey('product_details_share_btn'),
                    icon: Icons.share_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          content: Text(
                            'Freshly product link copied to clipboard',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Top Badges (Organic, Discount)
        Positioned(
          bottom: 12,
          left: 18,
          child: Row(
            children: [
              if (product.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B6E38),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B6E38).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    product.badge!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              if (product.discountPercentage > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${product.discountPercentage}% OFF',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircleActionButton({
    Key? key,
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF1E293B),
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: 21),
        ),
      ),
    );
  }

  /// 2. Product Title, Rating, Price & Unit
  Widget _buildHeaderInfo(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tag
          Text(
            product.categoryName.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B6E38),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),

          // Product Name
          Text(
            product.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Rating Pill & Unit
          Row(
            children: [
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 15, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Reviews Count
              Text(
                '(${product.reviewsCount} reviews)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),

              const Spacer(),

              // Weight/Unit Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  product.unit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${_unitPrice.toInt()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (product.originalPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  '₹${(product.originalPrice! * _multiplier).toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '(Taxes incl.)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Pack / Size Options
  Widget _buildPackSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Pack Size',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_variants.length, (index) {
              final isSelected = _selectedVariantIndex == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == _variants.length - 1 ? 0 : 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVariantIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEDF7EF) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _variants[index],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 4. Quantity Stepper Row
  Widget _buildQuantityStepperRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Morning delivery count',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Stepper Pill
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1B6E38), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B6E38).withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    key: const ValueKey('stepper_decrement_btn'),
                    onTap: _decrement,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Icon(
                        Icons.remove_rounded,
                        size: 18,
                        color: _quantity > 1 ? const Color(0xFF1B6E38) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  Text(
                    '$_quantity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  GestureDetector(
                    key: const ValueKey('stepper_increment_btn'),
                    onTap: _increment,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: Color(0xFF1B6E38),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 5. Fresh / Organic Quality Banner
  Widget _buildQualityBanner(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFDCFCE7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF16A34A).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF1B6E38),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  product.isOrganic ? Icons.eco_rounded : Icons.verified_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.isOrganic
                        ? '100% Certified Organic'
                        : 'Freshly Farm-Purity Guarantee',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF14532D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Harvested under 12 hours before arrival • No cold storage decay',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 6. Delivery Information Card
  Widget _buildDeliveryInfoCard(String address) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Row(
              children: [
                const Icon(Icons.wb_twilight_rounded, color: Color(0xFFEA580C), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morning Harvest Delivery',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Tomorrow by 6:30 AM – 7:30 AM',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B6E38),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ON TIME',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18, color: Color(0xFFF1F5F9)),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deliver to: $address',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 7. Short Product Description
  Widget _buildDescriptionSection(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Description',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.displayDescription,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// 8. Key Benefits Section
  Widget _buildKeyBenefitsSection(Product product) {
    final benefits = product.displayBenefits;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_outline_rounded, color: Color(0xFF1B6E38), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Key Benefits',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...benefits.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF1B6E38),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF334155),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// 9. Farm Origin & Storage Specs
  Widget _buildOriginSpecs(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Row(
        children: [
          Expanded(
            child: _buildSpecCard(
              title: 'Farm Origin',
              value: product.displayOrigin,
              icon: Icons.agriculture_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSpecCard(
              title: 'Shelf Life',
              value: product.displayShelfLife,
              icon: Icons.hourglass_top_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1B6E38)),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  /// 10. "You May Also Like" Horizontal List
  Widget _buildYouMayAlsoLikeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Text(
            'You May Also Like',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _relatedProducts.length,
            itemBuilder: (context, index) {
              final rel = _relatedProducts[index];
              return Container(
                width: 125,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: rel,
                          deliveryAddress: widget.deliveryAddress,
                          onCartUpdated: widget.onCartUpdated,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            rel.emoji,
                            style: const TextStyle(fontSize: 42),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        rel.unit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${rel.price.toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B6E38),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Sticky Bottom Bar
  Widget _buildStickyBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
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
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Price',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                '₹${_totalPrice.toInt()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),

          // Add to Cart Button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                key: const ValueKey('details_add_to_cart_btn'),
                onPressed: _handleAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B6E38),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Add to Cart',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
