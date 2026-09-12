import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Freshly Home Screen
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

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Vegetables',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF166534),
      'bg': const Color(0xFFDCFCE7),
    },
    {
      'title': 'Fruits',
      'icon': Icons.apple_rounded,
      'color': const Color(0xFFDC2626),
      'bg': const Color(0xFFFEE2E2),
    },
    {
      'title': 'Milk & Dairy',
      'icon': Icons.local_drink_rounded,
      'color': const Color(0xFF2563EB),
      'bg': const Color(0xFFDBEAFE),
    },
    {
      'title': 'Eggs',
      'icon': Icons.egg_rounded,
      'color': const Color(0xFFEA580C),
      'bg': const Color(0xFFFFEDD5),
    },
    {
      'title': 'Organic',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFF059669),
      'bg': const Color(0xFFD1FAE5),
    },
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Farm Fresh Spinach (Palak)',
      'weight': '250 g',
      'price': '₹24',
      'originalPrice': '₹35',
      'tag': 'Organic',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF166534),
    },
    {
      'name': 'Crisp Desi Carrots',
      'weight': '500 g',
      'price': '₹38',
      'originalPrice': '₹50',
      'tag': 'Fresh Harvest',
      'icon': Icons.local_florist_rounded,
      'color': const Color(0xFFEA580C),
    },
    {
      'name': 'A2 Pure Cow Milk',
      'weight': '1 L',
      'price': '₹72',
      'originalPrice': '₹85',
      'tag': 'Farm Dairy',
      'icon': Icons.local_drink_rounded,
      'color': const Color(0xFF2563EB),
    },
    {
      'name': 'Free Range Country Eggs',
      'weight': '6 pcs',
      'price': '₹68',
      'originalPrice': '₹80',
      'tag': 'Organic',
      'icon': Icons.egg_rounded,
      'color': const Color(0xFFD97706),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final society = widget.selectedSociety ?? 'Prestige High Fields';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Custom App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location & Profile Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGreen,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.bolt_rounded,
                                              size: 13,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '15 MINS',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primary,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Delivering to',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          society,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: AppColors.text,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Profile Avatar
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border,
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
                              const Icon(
                                Icons.search_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Search fresh veggies, fruits, dairy...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.mic_none_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero Promo Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 6.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(
                              Icons.eco_rounded,
                              size: 140,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18.0,
                              vertical: 18.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '100% FARM FRESH',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Morning Harvest\nat Your Doorstep',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Up to 30% off on first 3 orders',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Categories Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Explore Categories',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          'See All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.freshGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Horizontal Rail
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 94,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (cat['bg'] as Color),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      cat['icon'] as IconData,
                                      size: 26,
                                      color: isSelected
                                          ? Colors.white
                                          : (cat['color'] as Color),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat['title'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Fresh Deals / Popular Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Daily Fresh Harvest',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          'View all',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.freshGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Product Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = _products[index % _products.length];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image & Tag Area
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGreen
                                        .withValues(alpha: 0.4),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(19),
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        product['icon'] as IconData,
                                        size: 48,
                                        color: product['color'] as Color,
                                      ),
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            product['tag'] as String,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Product Info
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] as String,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      product['weight'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['price'] as String,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              Text(
                                                product['originalPrice']
                                                    as String,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color: AppColors.textMuted,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.lightGreen,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AppColors.freshGreen,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            'ADD',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
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
                      },
                      childCount: _products.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Deals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
