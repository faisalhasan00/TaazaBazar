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
}
