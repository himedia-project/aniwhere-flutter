import 'dart:convert';
import 'package:http/http.dart' as http;
import '../cart/cart_item.dart';
import '../cart/cart_item_list.dart';
import '../order/order_item.dart';
import '../order/order_hist.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8080/api'; // API URL

  // 주문 생성
  Future<int?> createOrder(String email, List<OrderItem> orderItems) async {
    final response = await http.post(
      Uri.parse('$baseUrl/order'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cartItems': orderItems.map((item) => item.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['orderId'];
    } else {
      throw Exception('주문 생성 실패');
    }
  }

  // 장바구니 목록 조회
  Future<List<CartItemList>> getCartItems(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/cart/item/list'),
        headers: {'Authorization': 'Bearer your_token_here'});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CartItemList.fromJson(json)).toList();
    } else {
      throw Exception('장바구니 아이템 조회 실패');
    }
  }

  // 장바구니에 상품 추가
  Future<List<CartItemList>> addCartItem(CartItem cartItem) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token_here',
      },
      body: jsonEncode(cartItem.toJson()),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CartItemList.fromJson(json)).toList();
    } else {
      throw Exception('장바구니에 아이템 추가 실패');
    }
  }

  // 장바구니 상품 삭제
  Future<List<CartItemList>> removeCartItem(int id) async {
    // Long을 int로 변경
    final response = await http.delete(Uri.parse('$baseUrl/cart/$id'),
        headers: {'Authorization': 'Bearer your_token_here'});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CartItemList.fromJson(json)).toList();
    } else {
      throw Exception('장바구니 아이템 삭제 실패');
    }
  }

  // 주문 내역 조회
  Future<List<OrderHist>> getOrderHistory(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/order/hist/list'),
      headers: {'Authorization': 'Bearer your_token_here'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OrderHist.fromJson(json)).toList();
    } else {
      throw Exception('구매내역 조회 실패');
    }
  }

  // 주문 취소
  Future<void> cancelOrder(int orderId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/order/$orderId/cancel'),
      headers: {'Authorization': 'Bearer your_token_here'},
    );

    if (response.statusCode == 200) {
      // 주문 취소 성공
    } else {
      throw Exception('주문 취소 실패');
    }
  }
}
