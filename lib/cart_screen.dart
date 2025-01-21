import 'package:flutter/material.dart';
import 'api_service.dart';
import 'cart_item.dart';
import 'cart_item_list.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService apiService = ApiService();
  List<CartItemList> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final email = 'user@example.com'; // 로그인한 사용자 이메일
    cartItems = await apiService.getCartItems(email);
    setState(() {});
  }

  Future<void> _addCartItem() async {
    CartItem newItem = CartItem(cartItemId: 0, email: 'user@example.com', productId: 1);
    cartItems = await apiService.addCartItem(newItem);
    setState(() {});
  }

  Future<void> _removeCartItem(int id) async {
    cartItems = await apiService.removeCartItem(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('장바구니')),
      body: cartItems.isEmpty
          ? Center(child: Text('장바구니가 비어 있습니다.'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            title: Text(item.productName),
            subtitle: Text('${item.price} 원'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeCartItem(item.cartItemId),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCartItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
