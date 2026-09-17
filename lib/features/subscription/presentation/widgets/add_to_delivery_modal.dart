import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../products/data/product_repository.dart';
import '../../../products/domain/product_model.dart';
import '../../data/subscription_repository.dart';

/// Modal bottom sheet allowing users to add any catalog product as a one-time item to their upcoming delivery
class AddToDeliveryModal extends StatefulWidget {
  final String subscriptionId;
  final VoidCallback? onItemAdded;

  const AddToDeliveryModal({
    super.key,
    required this.subscriptionId,
    this.onItemAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required String subscriptionId,
    VoidCallback? onItemAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToDeliveryModal(
        subscriptionId: subscriptionId,
        onItemAdded: onItemAdded,
      ),
    );
  }

  @override
  State<AddToDeliveryModal> createState() => _AddToDeliveryModalState();
}

class _AddToDeliveryModalState extends State<AddToDeliveryModal> {
  final TextEditingController _searchController = TextEditingController();
  final ProductRepository _productRepo = ProductRepository();
  final SubscriptionRepository _subRepo = SubscriptionRepository();

  String _searchQuery = '';
  String _selectedCategory = 'all';
  final Map<String, int> _quantities = {};
  bool _isAdding = false;

  static const _primaryColor = Color(0xFF166534);
  static const _textDark = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _errorColor = Color(0xFFDC2626);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    var list = _productRepo.cachedProducts;
    if (_selectedCategory != 'all') {
      list = list.where((p) => p.categoryId == _selectedCategory).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Future<void> _addItem(Product product, int quantity) async {
    setState(() => _isAdding = true);
    try {
      await _subRepo.addOneTimeToNextDelivery(
        widget.subscriptionId,
        product,
        quantity,
      );
      if (mounted) {
        widget.onItemAdded?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added $quantity x ${product.name} to your next delivery!',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: _primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item: $e'),
            backgroundColor: _errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _productRepo.cachedCategories;
    final products = _filteredProducts;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_shopping_cart, color: _primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add to Next Delivery',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        'One-time items will arrive with your morning basket',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: _textMuted),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search fresh vegetables, fruits, eggs...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, color: _textMuted, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Category filter chips
          if (categories.isNotEmpty)
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedCategory == 'all',
                      selectedColor: _primaryColor,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedCategory == 'all' ? Colors.white : _textMuted,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = 'all'),
                    ),
                  ),
                  ...categories.map((cat) {
                    final isSelected = _selectedCategory == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${cat.emoji} ${cat.name}'),
                        selected: isSelected,
                        selectedColor: _primaryColor,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : _textMuted,
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = cat.id),
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Products List
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty ? 'No products available' : 'No items match "$_searchQuery"',
                          style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final qty = _quantities[product.id] ?? 1;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: product.bgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                product.emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: _textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.unit,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${product.price.toStringAsFixed(0)}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: _primaryColor,
                                        ),
                                      ),
                                      if (product.originalPrice != null && product.originalPrice! > product.price) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '₹${product.originalPrice!.toStringAsFixed(0)}',
                                          style: GoogleFonts.plusJakartaSans(
                                            decoration: TextDecoration.lineThrough,
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Qty and Add Button
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        icon: const Icon(Icons.remove, size: 16),
                                        onPressed: qty > 1
                                            ? () => setState(() => _quantities[product.id] = qty - 1)
                                            : null,
                                      ),
                                      Text(
                                        '$qty',
                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () => setState(() => _quantities[product.id] = qty + 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isAdding ? null : () => _addItem(product, qty),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: Text('Add', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
