class OrderItem {
  final int productId; // Long을 int로 변경
  final String productName;
  final int orderPrice;

  OrderItem({required this.productId, required this.productName, required this.orderPrice});

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'orderPrice': orderPrice,
    };
  }
}
