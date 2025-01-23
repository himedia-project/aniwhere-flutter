import 'package:flutter/foundation.dart';
import '../pages/cart_page.dart'; // CartItemDTO가 정의된 파일로 수정

class Order {
  final String email;
  final String paymentMethod;
  final List<CartItemDTO> items; // CartItemDTO는 주문에 포함된 카트 아이템
  final int totalPrice;

  Order({
    required this.email,
    required this.paymentMethod,
    required this.items,
    required this.totalPrice,
  });
}

class OrderProvider with ChangeNotifier {
  List<Order> orders = [];

  void addOrder(Order order) {
    orders.add(order);
    notifyListeners();
  }

  List<Order> getOrderHistory() {
    return orders;
  }
}
