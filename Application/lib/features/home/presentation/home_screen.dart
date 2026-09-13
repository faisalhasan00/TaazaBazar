import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../pass/presentation/freshly_pass_screen.dart';
import '../../products/data/mock_products_data.dart';
import '../../products/presentation/product_details_screen.dart';
import '../../products/presentation/product_listing_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'widgets/fresh_deals_section.dart';
import 'widgets/home_bottom_nav.dart';
import 'widgets/home_category_grid.dart';
import 'widgets/home_header.dart';
import 'widgets/home_hero_banner.dart';
import 'widgets/pass_card_banner.dart';

/// Freshly Customer Mobile Home Screen composing modular micro-features
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
      'id': 'milk',
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
      'id': 'v_tomato',
      'title': 'Tomato',
      'price': '₹25/kg',
      'originalPrice': '₹35',
      'emoji': '🍅',
      'bgColor': const Color(0xFFFFF1F2),
    },
    {
      'id': 'd_cow_milk',
      'title': 'Milk',
      'price': '₹60/L',
      'originalPrice': '₹68',
      'emoji': '🥛',
      'bgColor': const Color(0xFFF0F9FF),
    },
    {
      'id': 'v_spinach',
      'title': 'Spinach',
      'price': '₹20/bunch',
      'originalPrice': '₹28',
      'emoji': '🥬',
      'bgColor': const Color(0xFFF0FDF4),
    },
    {
      'id': 'v_carrot',
      'title': 'Carrot',
      'price': '₹38/kg',
      'originalPrice': '₹48',
      'emoji': '🥕',
      'bgColor': const Color(0xFFFFF7ED),
    },
    {
      'id': 'e_brown_eggs',
      'title': 'Eggs',
      'price': '₹65/6pcs',
      'originalPrice': '₹75',
      'emoji': '🥚',
      'bgColor': const Color(0xFFFFFBEB),
    },
  ];

  void _incrementProduct(String id) {
    setState(() {
      _cartQuantities[id] = (_cartQuantities[id] ?? 0) + 1;
    });
  }

  void _navigateToCategory(String categoryId, String title) {
    if (categoryId == 'more') {
      setState(() => _currentNavIndex = 1);
      return;
    }
    final category = MockProductsData.categories.firstWhere(
      (c) => c.id == categoryId || c.name.toLowerCase().contains(title.toLowerCase()),
      orElse: () => MockProductsData.categories[0],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListingScreen(
          category: category,
        ),
      ),
    );
  }

  void _openProductDetails(String productId) {
    final product = MockProductsData.allProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => MockProductsData.allProducts[0],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    );
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
        child: _buildBody(locationName),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
      floatingActionButton: _currentNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openCart,
              backgroundColor: const Color(0xFF166534),
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
              label: Text(
                'View Cart',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(String locationName) {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeTab(locationName);
      case 1:
        return CategoriesScreen(
          onCategorySelected: (category) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductListingScreen(category: category),
              ),
            );
          },
        );
      case 2:
        return OrdersScreen(
          onStartShopping: () => setState(() => _currentNavIndex = 0),
        );
      case 3:
        return const FreshlyPassScreen();
      case 4:
        return ProfileScreen(
          onNavigateToOrders: () => setState(() => _currentNavIndex = 2),
          onNavigateToPass: () => setState(() => _currentNavIndex = 3),
        );
      default:
        return _buildHomeTab(locationName);
    }
  }

  Widget _buildHomeTab(String locationName) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Address & Search
          HomeHeader(
            selectedSociety: locationName,
            onAddressTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Delivery address: $locationName'),
                  backgroundColor: const Color(0xFF166534),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onSearchTap: () => setState(() => _currentNavIndex = 1),
          ),
          const SizedBox(height: 12),

          // 2. Hero Promotional Banner
          HomeHeroBanner(
            onShopNowTap: () => setState(() => _currentNavIndex = 1),
          ),
          const SizedBox(height: 20),

          // 3. Category Selector Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Explore Categories',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 12),
          HomeCategoryGrid(
            categories: _categories,
            onCategoryTap: _navigateToCategory,
          ),
          const SizedBox(height: 20),

          // 4. Fresh Deals Section
          FreshDealsSection(
            deals: _freshDeals,
            cartQuantities: _cartQuantities,
            onIncrement: _incrementProduct,
            onProductTap: _openProductDetails,
          ),
          const SizedBox(height: 20),

          // 5. Freshly Pass Mini Banner
          PassCardBanner(
            onViewPlans: () => setState(() => _currentNavIndex = 3),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
