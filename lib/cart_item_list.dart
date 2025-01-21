class CartItemList {
  final int cartItemId;
  final int productId; // 상품 ID
  final String productName; // 상품 이름
  final int price; // 가격
  final String imageName; // 이미지 이름

  CartItemList({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageName,
  });

  factory CartItemList.fromJson(Map<String, dynamic> json) {
    return CartItemList(
      cartItemId: json['cartItemId'],
      productId: json['productId'],
      productName: json['productName'],
      price: json['price'],
      imageName: json['imageName'],
    );
  }
}
