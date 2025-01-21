import 'package:flutter/material.dart';
import 'api_service.dart';
import 'order_item.dart';

class OrderScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('주문하기')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 주문 생성 로직
            final orderId = await apiService.createOrder('user@example.com', [
              OrderItem(productId: 1, productName: '지적재산권1', orderPrice: 1000),
            ]);
            print('주문 ID: $orderId');
          },
          child: Text('주문 생성'),
        ),
      ),
    );
  }
}
