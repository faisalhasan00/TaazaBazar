import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/domain/cart_item.dart';
import '../../cart/presentation/cart_screen.dart';
import '../data/mock_products_data.dart';
import '../domain/product_model.dart';
import 'product_details_screen.dart';

class ProductListingScreen extends StatefulWidget {
  final FreshCategory category;
  final Map<String, int>? initialCartQuantities;
  final Function(String productId, int quantity)? onCartUpdated;

  const ProductListingScreen({
    super.key,
    required this.category,
    this.initialCartQuantities,
    this.onCartUpdated,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  late Map<String, int> _cartQuantities;
  String _selectedFilter = 'All';
  String _selectedSort = 'Popularity';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  void _openProductDetails(Product product) async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          product: product,
          initialQuantity: _cartQuantities[product.id] ?? 0,
          onCartUpdated: (id, q) {
            setState(() {
              if (q <= 0) {
                _cartQuantities.remove(id);
              } else {
                _cartQuantities[id] = q;
              }
            });
            widget.onCartUpdated?.call(id, q);
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
      widget.onCartUpdated?.call(product.id, result);
    }
  }

  final List<String> _filters = ['All', 'Organic', 'Under ₹50', 'Deals'];
  final List<String> _sortOptions = [
    'Popularity',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated'
  ];

  @override
  void initState() {
    super.initState();
    _cartQuantities = Map<String, int>.from(widget.initialCartQuantities ?? {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _incrementProduct(Product product) {
    setState(() {
      final current = _cartQuantities[product.id] ?? 0;
      _cartQuantities[product.id] = current + 1;
    });
    widget.onCartUpdated?.call(product.id, _cartQuantities[product.id]!);
  }

  void _decrementProduct(Product product) {
    setState(() {
      final current = _cartQuantities[product.id] ?? 0;
      if (current <= 1) {
        _cartQuantities.remove(product.id);
        widget.onCartUpdated?.call(product.id, 0);
      } else {
        _cartQuantities[product.id] = current - 1;
        widget.onCartUpdated?.call(product.id, current - 1);
      }
    });
  }

  int get _totalCartItemCount {
    int count = 2; // base count
    for (var qty in _cartQuantities.values) {
      count += qty;
    }
    return count;
  }

  double get _totalCartSubtotal {
    double total = 85.0; // base mock subtotal
    for (var entry in _cartQuantities.entries) {
      final prod = MockProductsData.allProducts.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => MockProductsData.allProducts.first,
      );
      total += prod.price * entry.value;
    }
    return total;
  }

  List<Product> get _filteredProducts {
    List<Product> list = MockProductsData.getProductsByCategory(widget.category.id);

    // Apply text search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    // Apply quick filters
    if (_selectedFilter == 'Organic') {
      list = list.where((p) => p.isOrganic).toList();
    } else if (_selectedFilter == 'Under ₹50') {
      list = list.where((p) => p.price <= 50).toList();
    } else if (_selectedFilter == 'Deals') {
      list = list.where((p) => p.originalPrice != null && p.originalPrice! > p.price).toList();
    }

    // Apply sorting
    if (_selectedSort == 'Price: Low to High') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'Price: High to Low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedSort == 'Highest Rated') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort Products By',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._sortOptions.map((opt) {
                  final isSelected = _selectedSort == opt;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSort = opt;
                      });
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            opt,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFF334155),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF1B6E38)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter by Category Tags',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _filters.map((f) {
                    final isSelected = _selectedFilter == f;
                    return ChoiceChip(
                      label: Text(
                        f,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1B6E38),
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF1B6E38) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedFilter = f;
                          });
                          Navigator.pop(context);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 1. Top App Bar with Back Button, Category Name & Search/Filter Icon
                    SliverToBoxAdapter(
                      child: _buildTopBar(),
                    ),

                    // 2. Search Field (if toggled)
                    if (_isSearching)
                      SliverToBoxAdapter(
                        child: _buildInlineSearchBar(),
                      ),

                    // 3. Filter and Sort Options Row
                    SliverToBoxAdapter(
                      child: _buildFilterAndSortRow(products.length),
                    ),

                    // 4. Products 2-Column Grid
                    if (products.isEmpty)
                      SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = products[index];
                              return _buildProductCard(product);
                            },
                            childCount: products.length,
                          ),
                        ),
                      ),
                  ],
                ),

                // 5. Floating Cart Indicator Banner
                if (_cartQuantities.isNotEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildFloatingCartIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Top App Bar: Back Button, Category Title, Search & Cart Icon
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Back Button
          IconButton(
            key: const ValueKey('product_listing_back_btn'),
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF0F172A),
            onPressed: () => Navigator.pop(context, _cartQuantities),
          ),

          // Category Emoji & Title
          Text(
            widget.category.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ),

          // Search Toggle Icon
          IconButton(
            key: const ValueKey('listing_search_icon'),
            icon: Icon(
              _isSearching ? Icons.search_off_rounded : Icons.search_rounded,
              color: const Color(0xFF334155),
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),

          // Cart with Green Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF1E293B),
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
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
                    '$_totalCartItemCount',
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
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  /// 2. Inline Search Bar
  Widget _buildInlineSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search in ${widget.category.name}...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                child: const Icon(Icons.cancel, color: Color(0xFF94A3B8), size: 18),
              ),
          ],
        ),
      ),
    );
  }

  /// 3. Filter and Sort Options Row
  Widget _buildFilterAndSortRow(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Sort Action Pills
          Row(
            children: [
              // Filter Button
              GestureDetector(
                onTap: _showFilterModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _selectedFilter != 'All'
                        ? const Color(0xFF1B6E38)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedFilter != 'All'
                          ? const Color(0xFF1B6E38)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: _selectedFilter != 'All'
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedFilter == 'All' ? 'Filter' : _selectedFilter,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _selectedFilter != 'All'
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Sort Button
              GestureDetector(
                onTap: _showSortModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.swap_vert_rounded,
                        size: 16,
                        color: Color(0xFF334155),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedSort == 'Popularity' ? 'Sort' : _selectedSort,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Item Count Label
              Text(
                '$count items',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Horizontal Quick Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _filters.map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = f;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1B6E38).withValues(alpha: 0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1B6E38)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        f,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF1B6E38)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Product Card in 2-Column Grid
  Widget _buildProductCard(Product product) {
    final qty = _cartQuantities[product.id] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Image / Visual with Badge & Organic Tag (tappable to details)
          Expanded(
            flex: 5,
            child: GestureDetector(
              key: ValueKey('product_card_img_${product.id}'),
              onTap: () => _openProductDetails(product),
              child: Stack(
                children: [
                  // Background Soft Color Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: product.bgColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                    ),
                    child: Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 52),
                      ),
                    ),
                  ),

                  // Top Left Badge (e.g. POPULAR, 20% OFF)
                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B6E38),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.badge!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    )
                  else if (product.discountPercentage > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.discountPercentage}% OFF',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Top Right Rating Pill
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${product.rating}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Content
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Name & Weight (tappable to details)
                  GestureDetector(
                    key: ValueKey('product_card_title_${product.id}'),
                    onTap: () => _openProductDetails(product),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.unit,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price & Interactive Add / Stepper Button Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price & Original Strikethrough Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.originalPrice != null &&
                              product.originalPrice! > product.price)
                            Text(
                              '₹${product.originalPrice!.toInt()}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '₹${product.price.toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),

                      // Add / Quantity Stepper
                      qty == 0
                          ? GestureDetector(
                              key: ValueKey('add_btn_${product.id}'),
                              onTap: () => _incrementProduct(product),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF1B6E38),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ADD',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1B6E38),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(
                                      Icons.add_rounded,
                                      size: 14,
                                      color: Color(0xFF1B6E38),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B6E38),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1B6E38).withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _decrementProduct(product),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      child: Icon(
                                        Icons.remove_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$qty',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _incrementProduct(product),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      child: Icon(
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
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Floating Cart Indicator Banner
  Widget _buildFloatingCartIndicator() {
    int count = 0;
    for (var q in _cartQuantities.values) {
      count += q;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF135E34),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF135E34).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count ${count == 1 ? 'item' : 'items'} added',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '₹${_totalCartSubtotal.toInt()} total',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            key: const ValueKey('listing_view_cart_btn'),
            onPressed: () async {
              final List<CartItem> items = [];
              _cartQuantities.forEach((id, qty) {
                if (qty > 0) {
                  final product = MockProductsData.allProducts.firstWhere(
                    (p) => p.id == id,
                    orElse: () => MockProductsData.allProducts[0],
                  );
                  items.add(CartItem(product: product, quantity: qty));
                }
              });

              final result = await Navigator.push<List<CartItem>>(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    initialItems: items.isEmpty ? null : items,
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF135E34),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Cart',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF135E34),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: Color(0xFF135E34),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State for Search / Filter
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'No products found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try changing your search or filter options.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
