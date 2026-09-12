import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../splash/presentation/widgets/freshly_logo.dart';

/// Freshly Customer Home Screen
class HomeScreen extends StatefulWidget {
  final String? selectedSociety;
  final String? deliveryAddress;

  const HomeScreen({
    super.key,
    this.selectedSociety,
    this.deliveryAddress,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  int _selectedCategoryIndex = 0;
  final Map<String, int> _cartQuantities = {};

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Vegetables',
      'emoji': '🥬',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF166534),
      'bg': const Color(0xFFE8F5E9),
    },
    {
      'title': 'Fruits',
      'emoji': '🍎',
      'icon': Icons.apple_rounded,
      'color': const Color(0xFFDC2626),
      'bg': const Color(0xFFFEE2E2),
    },
    {
      'title': 'Dairy',
      'emoji': '🥛',
      'icon': Icons.local_drink_rounded,
      'color': const Color(0xFF2563EB),
      'bg': const Color(0xFFDBEAFE),
    },
    {
      'title': 'Eggs',
      'emoji': '🥚',
      'icon': Icons.egg_rounded,
      'color': const Color(0xFFD97706),
      'bg': const Color(0xFFFEF3C7),
    },
    {
      'title': 'Organic',
      'emoji': '🌿',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFF059669),
      'bg': const Color(0xFFD1FAE5),
    },
    {
      'title': 'Grocery',
      'emoji': '🛒',
      'icon': Icons.shopping_basket_rounded,
      'color': const Color(0xFF7C3AED),
      'bg': const Color(0xFFEDE9FE),
    },
  ];

  final List<Map<String, dynamic>> _popularProducts = [
    {
      'id': 'p1',
      'name': 'Fresh Tomato',
      'weight': '1 kg',
      'price': '₹40',
      'originalPrice': '₹55',
      'tag': 'Farm Harvest',
      'emoji': '🍅',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFFE11D48),
      'bgColor': const Color(0xFFFFE4E6),
    },
    {
      'id': 'p2',
      'name': 'Fresh Milk',
      'weight': '1 L',
      'price': '₹60',
      'originalPrice': '₹72',
      'tag': 'Fresh Dairy',
      'emoji': '🥛',
      'icon': Icons.local_drink_rounded,
      'color': const Color(0xFF0284C7),
      'bgColor': const Color(0xFFE0F2FE),
    },
    {
      'id': 'p3',
      'name': 'Organic Eggs',
      'weight': '6 pcs',
      'price': '₹75',
      'originalPrice': '₹90',
      'tag': 'Organic',
      'emoji': '🥚',
      'icon': Icons.egg_rounded,
      'color': const Color(0xFFD97706),
      'bgColor': const Color(0xFFFEF3C7),
    },
    {
      'id': 'p4',
      'name': 'Spinach',
      'weight': '250 g',
      'price': '₹30',
      'originalPrice': '₹40',
      'tag': 'Leafy Green',
      'emoji': '🥬',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFDCFCE7),
    },
    {
      'id': 'p5',
      'name': 'Crisp Desi Carrots',
      'weight': '500 g',
      'price': '₹38',
      'originalPrice': '₹50',
      'tag': 'Crunchy',
      'emoji': '🥕',
      'icon': Icons.local_florist_rounded,
      'color': const Color(0xFFEA580C),
      'bgColor': const Color(0xFFFFEDD5),
    },
    {
      'id': 'p6',
      'name': 'Royal Shimla Apples',
      'weight': '4 pcs',
      'price': '₹120',
      'originalPrice': '₹150',
      'tag': 'Sweet & Crisp',
      'emoji': '🍎',
      'icon': Icons.apple_rounded,
      'color': const Color(0xFFDC2626),
      'bgColor': const Color(0xFFFEE2E2),
    },
  ];

  void _incrementProduct(String id) {
    setState(() {
      _cartQuantities[id] = (_cartQuantities[id] ?? 0) + 1;
    });
  }

  void _decrementProduct(String id) {
    setState(() {
      final current = _cartQuantities[id] ?? 0;
      if (current <= 1) {
        _cartQuantities.remove(id);
      } else {
        _cartQuantities[id] = current - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final society = widget.selectedSociety ??
        (widget.deliveryAddress != null && widget.deliveryAddress!.isNotEmpty
            ? widget.deliveryAddress!
            : 'Prestige High Fields, Tower 4');

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header with Location, Brand & Notification + Search Bar
                SliverToBoxAdapter(
                  child: _buildHeader(society),
                ),

                // 2. Promotional Banner ("Freshness Delivered Daily")
                SliverToBoxAdapter(
                  child: _buildPromoBanner(),
                ),

                // 3. Categories ("Shop by Category")
                SliverToBoxAdapter(
                  child: _buildCategoriesSection(),
                ),

                // 4. Freshly Pass Feature Card
                SliverToBoxAdapter(
                  child: _buildFreshlyPassCard(),
                ),

                // 5. Popular Products Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Popular Near You',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '⚡ 15m',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'See All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Popular Products Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = _popularProducts[index];
                        return _buildProductCard(product);
                      },
                      childCount: _popularProducts.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 28),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// 1. Top Header: Branding, Delivery Location, Notification Bell & Search Bar
  Widget _buildHeader(String society) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Brand on Left, Location in Center/Left, Notification on Right
          Row(
            children: [
              // Freshly Brand Mini Leaf & Name
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FreshlyEmblem(size: 24),
                  const SizedBox(width: 5),
                  Text(
                    'Freshly',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0A5832),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 20,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 10),

              // Selected Delivery Location with Pin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: Color(0xFF15803D),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'DELIVER TO',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            society,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 15,
                          color: Color(0xFF0F172A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Notification Bell with Unread Dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF1E293B),
                        size: 19,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE11D48),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search Bar
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF0A5832),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search vegetables, milk, fruits...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    size: 14,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Promotional Banner ("Freshness Delivered Daily")
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0A5832),
              Color(0xFF147A46),
              Color(0xFF1E9B58),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A5832).withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Organic Shapes in Background
            Positioned(
              right: -15,
              bottom: -20,
              child: Opacity(
                opacity: 0.14,
                child: const FreshlyEmblem(size: 140),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Express Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flash_on_rounded,
                          color: Color(0xFFFDE047),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '100% FARM FRESH',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title: "Freshness Delivered Daily"
                  Text(
                    'Freshness Delivered Daily',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.4,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Subtitle
                  Text(
                    'Fresh vegetables, dairy & organic products at your doorstep.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // "Shop Now" Button
                  ElevatedButton(
                    key: const ValueKey('banner_shop_now_btn'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF0A5832),
                          content: Text(
                            'Browsing Daily Fresh Harvest...',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0A5832),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Shop Now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0A5832),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFF0A5832),
                        ),
                      ],
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

  /// 3. Categories Horizontal Rail ("Shop by Category")
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Category',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'View all',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Category Cards
        SizedBox(
          height: 94,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = index == _selectedCategoryIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                child: Container(
                  width: 68,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0A5832)
                              : (cat['bg'] as Color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0A5832)
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF0A5832)
                                        .withValues(alpha: 0.28),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            cat['emoji'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF0A5832)
                              : const Color(0xFF334155),
                        ),
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

  /// 4. Freshly Pass Feature Card
  Widget _buildFreshlyPassCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left VIP Emblem
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFEF3C7),
                    Color(0xFFFDE68A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFB45309),
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Middle Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save More with Freshly Pass',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Get better value with Weekly & Monthly plans.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // "View Plans" Action Button
            ElevatedButton(
              key: const ValueKey('view_plans_btn'),
              onPressed: () {
                setState(() {
                  _currentNavIndex = 3; // Switch to Pass tab
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A5832),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'View Plans',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 5. Individual Product Card in 2-Column Grid
  Widget _buildProductCard(Map<String, dynamic> product) {
    final id = product['id'] as String;
    final qty = _cartQuantities[id] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Produce Visual Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: (product['bgColor'] as Color).withValues(alpha: 0.6),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Emoji visual
                  Text(
                    product['emoji'] as String,
                    style: const TextStyle(fontSize: 44),
                  ),

                  // Tag (e.g. Farm Harvest, Organic)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Text(
                        product['tag'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: product['color'] as Color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product Info & Price
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  product['weight'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),

                // Price & Add Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prices
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['price'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0A5832),
                          ),
                        ),
                        Text(
                          product['originalPrice'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),

                    // Add Button / Counter
                    qty == 0
                        ? InkWell(
                            onTap: () => _incrementProduct(id),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF15803D),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ADD',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0A5832),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.add_rounded,
                                    size: 13,
                                    color: Color(0xFF0A5832),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A5832),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _decrementProduct(id),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 3,
                                    ),
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$qty',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _incrementProduct(id),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 3,
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 13,
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
          ),
        ],
      ),
    );
  }

  /// 6. Bottom Navigation Bar: Home | Categories | Orders | Pass | Profile
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: BottomNavigationBar(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              setState(() {
                _currentNavIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF0A5832),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.workspace_premium_outlined),
                activeIcon: Icon(Icons.workspace_premium_rounded),
                label: 'Pass',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
