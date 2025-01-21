class OrderHist {
  final int orderId;
  final String email;
  final String orderCode;
  final DateTime orderDate;
  final String orderStatus;
  final int totalPrice;

  OrderHist({
    required this.orderId,
    required this.email,
    required this.orderCode,
    required this.orderDate,
    required this.orderStatus,
    required this.totalPrice,
  });

  factory OrderHist.fromJson(Map<String, dynamic> json) {
    return OrderHist(
      orderId: json['orderId'],
      email: json['email'],
      orderCode: json['orderCode'],
      orderDate: DateTime.parse(json['orderDate']),
      orderStatus: json['orderStatus'],
      totalPrice: json['totalPrice'],
    );
  }
}
