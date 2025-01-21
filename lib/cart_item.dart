class CartItem {
  final int cartItemId;
  final String email;
  final int productId;

  CartItem({required this.cartItemId, required this.email, required this.productId});

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'email': email,
      'productId': productId,
    };
  }
}
