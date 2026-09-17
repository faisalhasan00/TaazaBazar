import '../../products/domain/product_model.dart';

/// Cart Item model representing a product in customer's cart
class CartItem {
  final Product product;
  int quantity;
  final String selectedPack;

  CartItem({
    required this.product,
    this.quantity = 1,
    String? selectedPack,
  }) : selectedPack = selectedPack ?? product.unit;

  double get itemPrice => product.price;

  double? get originalItemPrice => product.originalPrice;

  double get subtotal => itemPrice * quantity;

  double get originalSubtotal => (originalItemPrice ?? itemPrice) * quantity;

  double get totalSavings => originalSubtotal - subtotal;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedPack,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedPack: selectedPack ?? this.selectedPack,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'emoji': product.emoji,
      'quantity': quantity,
      'selectedPack': selectedPack,
      'product': product.toMap(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, [Product? fallbackProduct]) {
    final prodMap = map['product'] as Map<String, dynamic>?;
    final prod = prodMap != null
        ? Product.fromMap(prodMap, map['productId']?.toString() ?? prodMap['id']?.toString())
        : (fallbackProduct ??
            Product(
              id: map['productId']?.toString() ?? '',
              name: map['name']?.toString() ?? '',
              categoryId: map['categoryId']?.toString() ?? 'all',
              categoryName: map['categoryName']?.toString() ?? 'General',
              price: (map['price'] as num?)?.toDouble() ?? 0.0,
              unit: map['selectedPack']?.toString() ?? '1 kg',
              emoji: map['emoji']?.toString() ?? '🛒',
            ));

    return CartItem(
      product: prod,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      selectedPack: map['selectedPack']?.toString(),
    );
  }
}
