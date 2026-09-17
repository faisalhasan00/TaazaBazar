import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/data/cart_repository.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../deals/data/deal_repository.dart';
import '../../deals/domain/deal_model.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../subscription/presentation/subscriptions_hub_screen.dart';
import '../../products/data/product_repository.dart';
import '../../products/domain/product_model.dart';
import '../../products/presentation/product_details_screen.dart';
import '../../products/presentation/product_listing_screen.dart';
import '../../products/presentation/product_search_screen.dart';
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
  final _productRepo = ProductRepository();
  int _currentNavIndex = 0;
  final Map<String, int> _cartQuantities = {};

  List<FreshCategory> _categories = [];
  List<Map<String, dynamic>> _freshDeals = [];
  StreamSubscription<List<FreshCategory>>? _categoriesSub;
  StreamSubscription<List<DealModel>>? _dealsSub;

  List<Map<String, dynamic>> get _displayCategories {
    if (_categories.isEmpty) return [];
    final List<Map<String, dynamic>> list = _categories.map((c) => <String, dynamic>{
      'id': c.id,
      'title': c.name,
      'emoji': c.emoji,
      'bg': c.bgColor,
    }).toList();
    if (list.length >= 7) {
      list.add(<String, dynamic>{
        'id': 'more',
        'title': 'More',
        'emoji': '•••',
        'bg': const Color(0xFFEDF7EF),
        'isMore': true,
      });
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _categories = List.from(_productRepo.cachedCategories);
    _categoriesSub = _productRepo.getCategoriesStream().listen((list) {
      if (mounted) {
        setState(() {
          _categories = list;
        });
      }
    });

    _dealsSub = DealRepository().getDealsStream().listen((deals) {
      if (mounted) {
        setState(() {
          _freshDeals = deals.map((d) => d.toHomeScreenMap()).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _categoriesSub?.cancel();
    _dealsSub?.cancel();
    super.dispose();
  }

  void _incrementProduct(String id) {
    setState(() {
      _cartQuantities[id] = (_cartQuantities[id] ?? 0) + 1;
    });
    final product = _productRepo.getProductById(id);
    if (product != null) {
      CartRepository().addItem(product);
    }
  }

  void _navigateToCategory(String categoryId, String title) {
    if (categoryId == 'more') {
      setState(() => _currentNavIndex = 1);
      return;
    }
    final category = _productRepo.getCategoryById(categoryId) ??
        _productRepo.cachedCategories.firstWhere(
          (c) => c.id == categoryId || c.name.toLowerCase().contains(title.toLowerCase()),
          orElse: () => _productRepo.cachedCategories.isNotEmpty
              ? _productRepo.cachedCategories[0]
              : _productRepo.cachedCategories.first,
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
    final product = _productRepo.getProductById(productId) ??
        (_productRepo.cachedProducts.isNotEmpty
            ? _productRepo.cachedProducts[0]
            : _productRepo.cachedProducts.first);

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
        return const SubscriptionsHubScreen();
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
            onSearchTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductSearchScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // 2. Hero Promotional Banner
          HomeHeroBanner(
            onShopNowTap: () => setState(() => _currentNavIndex = 1),
          ),
          const SizedBox(height: 20),

          // 3. Category Selector Grid
          if (_displayCategories.isNotEmpty) ...[
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
              categories: _displayCategories,
              onCategoryTap: _navigateToCategory,
            ),
            const SizedBox(height: 20),
          ],

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
