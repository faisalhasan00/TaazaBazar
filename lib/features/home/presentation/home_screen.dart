import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/domain/cart_item.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../products/data/mock_products_data.dart';
import '../../products/domain/product_model.dart';
import '../../products/presentation/product_details_screen.dart';
import '../../products/presentation/product_listing_screen.dart';

/// Freshly Customer Mobile Home Screen matching reference UI design
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
  int _selectedPassPlan = 1; // 0: Weekly, 1: Monthly (default), 2: Quarterly
  final Map<String, int> _cartQuantities = {};

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'veg',
      'title': 'Vegetables',
      'emoji': '🥬',
      'bg': const Color(0xFFEDF7EF),
    },
    {
      'id': 'fruits',
      'title': 'Fruits',
      'emoji': '🍎',
      'bg': const Color(0xFFEDF7EF),
    },
    {
      'id': 'dairy',
      'title': 'Dairy',
      'emoji': '🥛',
      'bg': const Color(0xFFEDF7EF),
    },
    {
      'id': 'organic',
      'title': 'Organic',
      'emoji': '🌿',
      'bg': const Color(0xFFEDF7EF),
    },
    {
      'id': 'dairy',
      'title': 'Milk',
      'emoji': '🍶',
      'bg': const Color(0xFFEDF7EF),
    },
    {
      'id': 'eggs',
      'title': 'Eggs',
      'emoji': '🥚',
      'bg': const Color(0xFFEDF7EF),
    },
    {
      'id': 'grocery',
      'title': 'Grocery',
      'emoji': '🛒',
      'bg': const Color(0xFFEDF7EF),
    },
    {
      'id': 'more',
      'title': 'More',
      'emoji': '•••',
      'bg': const Color(0xFFEDF7EF),
      'isMore': true,
    },
  ];

  final List<Map<String, dynamic>> _freshDeals = [
    {
      'id': 'd1',
      'name': 'Tomato',
      'unitPrice': '₹25/kg',
      'emoji': '🍅',
      'color': const Color(0xFFE11D48),
      'bgColor': const Color(0xFFFFF1F2),
    },
    {
      'id': 'd2',
      'name': 'Milk',
      'unitPrice': '₹60/L',
      'emoji': '🥛',
      'color': const Color(0xFF0284C7),
      'bgColor': const Color(0xFFF0F9FF),
    },
    {
      'id': 'd3',
      'name': 'Spinach',
      'unitPrice': '₹20/bunch',
      'emoji': '🥬',
      'color': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
    },
    {
      'id': 'd4',
      'name': 'Carrot',
      'unitPrice': '₹38/kg',
      'emoji': '🥕',
      'color': const Color(0xFFEA580C),
      'bgColor': const Color(0xFFFFF7ED),
    },
    {
      'id': 'd5',
      'name': 'Eggs',
      'unitPrice': '₹65/6pcs',
      'emoji': '🥚',
      'color': const Color(0xFFD97706),
      'bgColor': const Color(0xFFFFFBEB),
    },
  ];

  void _incrementProduct(String id) {
    setState(() {
      _cartQuantities[id] = (_cartQuantities[id] ?? 0) + 1;
    });
  }

  int get _totalCartCount {
    int total = 2; // base mock from reference UI (2 items in cart)
    for (var count in _cartQuantities.values) {
      total += count;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final locationName = widget.selectedSociety ??
        (widget.deliveryAddress != null && widget.deliveryAddress!.isNotEmpty
            ? widget.deliveryAddress!
            : 'Shadnagar, Hyderabad');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: IndexedStack(
              index: _currentNavIndex,
              children: [
                // Tab 0: Home Screen (matching reference image)
                _buildHomeScreenContent(locationName),

                // Tab 1: Categories
                _buildCategoriesTabContent(),

                // Tab 2: Orders
                _buildOrdersTabContent(),

                // Tab 3: Freshly Pass (matching reference image styling)
                _buildPassTabContent(),

                // Tab 4: Profile
                _buildProfileTabContent(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Main Home Screen Content View
  Widget _buildHomeScreenContent(String locationName) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Header (Location, Notification, Cart & Search Bar)
        SliverToBoxAdapter(
          child: _buildHeader(locationName),
        ),

        // 2. Hero Promotional Banner ("Pure. Fresh. Organic.")
        SliverToBoxAdapter(
          child: _buildHeroBanner(),
        ),

        // 3. Categories (2x4 Grid of 8 items)
        SliverToBoxAdapter(
          child: _buildCategoriesGrid(),
        ),

        // 4. Fresh Deals Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fresh Deals',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E3A2F),
                    letterSpacing: -0.4,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentNavIndex = 1; // switch to Categories
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B6E38),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF1B6E38),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 5. Fresh Deals Horizontal Product Cards
        SliverToBoxAdapter(
          child: _buildFreshDealsRow(),
        ),

        // 6. Freshly Pass Prompt Card
        SliverToBoxAdapter(
          child: _buildHomePassMiniBanner(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  /// 1. Header: Location, Notification, Cart with Badge & Search Bar
  Widget _buildHeader(String locationName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Location on Left, Notification & Cart on Right
          Row(
            children: [
              // Green Location Pin
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F8F2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: Color(0xFF1B6E38),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Deliver to & Location Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deliver to',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Notification Bell Icon
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF1E293B),
                  size: 26,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(width: 14),

              // Shopping Cart with Green Badge Counter
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    key: const ValueKey('home_cart_btn'),
                    onPressed: () => _openCartScreen(locationName),
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFF1E293B),
                      size: 25,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B6E38),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_totalCartCount',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search Bar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search for vegetables, dairy, etc.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Hero Banner ("Pure. Fresh. Organic." with Wicker Harvest Basket)
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
      child: Container(
        height: 175,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF135E34),
              Color(0xFF1B7C45),
              Color(0xFF289656),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF135E34).withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background organic leaf breeze lines
              Positioned(
                left: 115,
                top: 45,
                child: Opacity(
                  opacity: 0.35,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: const Icon(
                      Icons.air_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),

              // Left Text & "Shop Now" Button
              Positioned(
                left: 20,
                top: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Multi-line Title
                    Text(
                      'Pure.\nFresh.\nOrganic.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.12,
                      ),
                    ),

                    // "Shop Now" Pill Button
                    ElevatedButton(
                      key: const ValueKey('banner_shop_now_btn'),
                      onPressed: () {
                        setState(() {
                          _currentNavIndex = 1; // Open categories
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF135E34),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Shop Now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF135E34),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right Produce Wicker Basket Visual
              Positioned(
                right: -10,
                top: -8,
                bottom: -8,
                width: 195,
                child: Center(
                  child: Image.asset(
                    'assets/images/farm_fresh_basket.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3. Categories: 2x4 Grid of 8 Soft Mint Cards
  Widget _buildCategoriesGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - 36) / 4;

          return Wrap(
            spacing: 12,
            runSpacing: 14,
            children: _categories.map((cat) {
              final isMore = cat['isMore'] == true;

              return SizedBox(
                width: cardWidth,
                child: GestureDetector(
                  onTap: () {
                    if (isMore) {
                      setState(() {
                        _currentNavIndex = 1; // switch to Categories tab
                      });
                    } else {
                      final catId = cat['id'] as String? ?? 'veg';
                      final categoryObj = MockProductsData.getCategoryById(catId) ??
                          MockProductsData.categories.first;
                      _navigateToProductListing(categoryObj);
                    }
                  },
                  child: Column(
                    children: [
                      // Square Soft Mint Card
                      Container(
                        width: cardWidth,
                        height: cardWidth,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8F2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: isMore
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDot(),
                                    const SizedBox(width: 4),
                                    _buildDot(),
                                    const SizedBox(width: 4),
                                    _buildDot(),
                                  ],
                                )
                              : Text(
                                  cat['emoji'] as String,
                                  style: TextStyle(
                                    fontSize: cardWidth * 0.46,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Label
                      Text(
                        cat['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFF1B6E38),
        shape: BoxShape.circle,
      ),
    );
  }

  void _openProductDetailsForDeal(Map<String, dynamic> item) async {
    final name = item['name'] as String;
    final product = MockProductsData.allProducts.firstWhere(
      (p) => p.name.toLowerCase().contains(name.toLowerCase()),
      orElse: () => Product(
        id: item['id'] as String,
        name: name,
        categoryId: 'veg',
        categoryName: 'Fresh Deals',
        unit: '1 kg',
        price: double.tryParse((item['unitPrice'] as String).replaceAll(RegExp(r'[^0-9.]'), '')) ?? 25,
        emoji: item['emoji'] as String,
        bgColor: item['bgColor'] as Color? ?? const Color(0xFFF0FDF4),
      ),
    );

    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          product: product,
          deliveryAddress: widget.deliveryAddress,
          initialQuantity: _cartQuantities[product.id] ?? 0,
          onCartUpdated: (id, q) {
            setState(() {
              if (q <= 0) {
                _cartQuantities.remove(id);
              } else {
                _cartQuantities[id] = q;
              }
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (result <= 0) {
          _cartQuantities.remove(product.id);
        } else {
          _cartQuantities[product.id] = result;
        }
      });
    }
  }

  /// 5. Fresh Deals Horizontal Card Row
  Widget _buildFreshDealsRow() {
    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _freshDeals.length,
        itemBuilder: (context, index) {
          final item = _freshDeals[index];
          final id = item['id'] as String;
          final qty = _cartQuantities[id] ?? 0;

          return Container(
            width: 125,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.1,
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
                // Centered Produce Visual (tappable to details)
                Expanded(
                  child: GestureDetector(
                    key: ValueKey('deal_img_$id'),
                    onTap: () => _openProductDetailsForDeal(item),
                    child: Center(
                      child: Text(
                        item['emoji'] as String,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Name (tappable to details)
                GestureDetector(
                  key: ValueKey('deal_title_$id'),
                  onTap: () => _openProductDetailsForDeal(item),
                  child: Text(
                    item['name'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // Price and Add (+) Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['unitPrice'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    // Circular Dark Green (+) Button
                    GestureDetector(
                      onTap: () => _incrementProduct(id),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: qty > 0
                              ? const Color(0xFF135E34)
                              : const Color(0xFF1B6E38),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B6E38)
                                  .withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: qty > 0
                              ? Text(
                                  '$qty',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 6. Freshly Pass Mini Banner inside Home Feed
  Widget _buildHomePassMiniBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 6),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentNavIndex = 3; // Switch to Pass screen
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0A4D2B),
                Color(0xFF126C3E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A4D2B).withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // VIP Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFFDE047),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Middle Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save More with Freshly Pass',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Get better value with Weekly & Monthly plans.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Pill Button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'View Plans',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0A4D2B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: FULL FRESHLY PASS SCREEN
  // ==========================================
  Widget _buildPassTabContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Top Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentNavIndex = 0; // Back to home
                    });
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: const Color(0xFF0F172A),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Freshly Pass',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFB45309),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'VIP SAVINGS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Hero Pass Banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0A5832),
                    Color(0xFF166534),
                    Color(0xFF1E824A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A5832).withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
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
                        child: Text(
                          'Save More with\nFreshly Pass',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.eco_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get better value with Weekly & Monthly plans and save up to ₹450 every month.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Plans Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
            child: Text(
              'Select Membership Plan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ),

        // Plan Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: [
                _buildPlanSelectionCard(
                  index: 0,
                  title: 'Weekly Pass',
                  duration: '7 Days Access',
                  price: '₹49',
                  perMonth: '₹7 / day',
                  tag: 'TRIAL PLAN',
                ),
                const SizedBox(height: 12),
                _buildPlanSelectionCard(
                  index: 1,
                  title: 'Monthly Pass',
                  duration: '30 Days Access',
                  price: '₹149',
                  perMonth: '₹5 / day',
                  tag: '⭐ BEST VALUE',
                  isPopular: true,
                ),
                const SizedBox(height: 12),
                _buildPlanSelectionCard(
                  index: 2,
                  title: 'Quarterly Pass',
                  duration: '90 Days Access',
                  price: '₹399',
                  perMonth: '₹4.4 / day',
                  tag: 'MAX SAVER',
                ),
              ],
            ),
          ),
        ),

        // Member Benefits Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
            child: Text(
              'Freshly Pass Benefits',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ),

        // Benefits Checklist
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1B6E38).withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    icon: Icons.delivery_dining_rounded,
                    title: 'Unlimited Free Delivery',
                    subtitle: 'Zero delivery fee on all vegetable & grocery orders',
                  ),
                  const Divider(height: 20, color: Color(0xFFD1E7D6)),
                  _buildBenefitRow(
                    icon: Icons.percent_rounded,
                    title: 'Extra 10% Member Cashback',
                    subtitle: 'Earn wallet coins back on every fresh delivery',
                  ),
                  const Divider(height: 20, color: Color(0xFFD1E7D6)),
                  _buildBenefitRow(
                    icon: Icons.access_time_filled_rounded,
                    title: 'Priority 15-Minute Delivery Slots',
                    subtitle: 'First harvest reservation during peak morning hours',
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom CTA Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1B6E38),
                      content: Text(
                        'Freshly Pass membership activated successfully!',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B6E38),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  'Activate Freshly Pass',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSelectionCard({
    required int index,
    required String title,
    required String duration,
    required String price,
    required String perMonth,
    required String tag,
    bool isPopular = false,
  }) {
    final isSelected = _selectedPassPlan == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPassPlan = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF1B6E38).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1B6E38) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Plan Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
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
                          color: isPopular
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isPopular
                                ? const Color(0xFF15803D)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    duration,
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

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1B6E38),
                  ),
                ),
                Text(
                  perMonth,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF1B6E38),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToProductListing(FreshCategory category) async {
    final result = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListingScreen(
          category: category,
          initialCartQuantities: _cartQuantities,
          onCartUpdated: (id, qty) {
            setState(() {
              if (qty <= 0) {
                _cartQuantities.remove(id);
              } else {
                _cartQuantities[id] = qty;
              }
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _cartQuantities.clear();
        _cartQuantities.addAll(result);
      });
    }
  }

  List<CartItem> _getCartItems() {
    if (_cartQuantities.isEmpty) {
      return [];
    }
    final List<CartItem> items = [];
    _cartQuantities.forEach((id, qty) {
      if (qty > 0) {
        final product = MockProductsData.allProducts.firstWhere(
          (p) => p.id == id,
          orElse: () => Product(
            id: id,
            name: 'Fresh Harvest Item',
            categoryId: 'veg',
            categoryName: 'Vegetables',
            unit: '1 kg',
            price: 40,
            emoji: '🥬',
          ),
        );
        items.add(CartItem(product: product, quantity: qty));
      }
    });
    return items;
  }

  void _openCartScreen(String locationName) async {
    final items = _getCartItems();
    final result = await Navigator.push<List<CartItem>>(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          initialItems: items.isEmpty ? null : items,
          deliveryAddress: locationName,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _cartQuantities.clear();
        for (var item in result) {
          if (item.quantity > 0) {
            _cartQuantities[item.product.id] = item.quantity;
          }
        }
      });
    }
  }

  // ==========================================
  // OTHER TABS (Categories, Orders, Profile)
  // ==========================================
  Widget _buildCategoriesTabContent() {
    return CategoriesScreen(
      cartQuantities: _cartQuantities,
      onCartUpdated: (id, qty) {
        setState(() {
          if (qty <= 0) {
            _cartQuantities.remove(id);
          } else {
            _cartQuantities[id] = qty;
          }
        });
      },
      onCategorySelected: (cat) => _navigateToProductListing(cat),
    );
  }

  Widget _buildOrdersTabContent() {
    return OrdersScreen(
      onStartShopping: () {
        setState(() {
          _currentNavIndex = 0;
        });
      },
    );
  }

  Widget _buildProfileTabContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B6E38),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Freshly Member',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '+91 98765 43210',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Color(0xFF1B6E38)),
            title: const Text('Saved Addresses'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1B6E38)),
            title: const Text('Freshly Pass Membership'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              setState(() {
                _currentNavIndex = 3;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF1B6E38)),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar: Home | Categories | Orders | Pass | Profile
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
            selectedItemColor: const Color(0xFF1B6E38),
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
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                activeIcon: Icon(Icons.description_rounded),
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
