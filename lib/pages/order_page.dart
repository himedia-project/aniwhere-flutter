import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../order/order_item.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ApiService apiService = ApiService();
  String? orderId; // 주문 ID를 저장할 변수
  String? errorMessage; // 오류 메시지를 저장할 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('주문하기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  // 주문 생성 로직
                  final newOrderId =
                      await apiService.createOrder('user@example.com', [
                    OrderItem(
                        productId: 1, productName: '지적재산권1', orderPrice: 1000),
                  ]);
                  setState(() {
                    orderId = newOrderId.toString(); // 주문 ID 업데이트
                    errorMessage = null; // 오류 메시지 초기화
                  });
                  print('주문 ID: $newOrderId');
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString(); // 오류 메시지 업데이트
                  });
                }
              },
              child: Text('주문 생성'),
            ),
            SizedBox(height: 20),
            if (orderId != null) // 주문 ID가 있을 경우 표시
              Column(
                children: [
                  Text('주문 ID: $orderId', style: TextStyle(fontSize: 20)),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // 주문 취소 로직
                        await apiService.cancelOrder(int.parse(orderId!));
                        setState(() {
                          orderId = null; // 주문 ID 초기화
                          errorMessage = null; // 오류 메시지 초기화
                        });
                        print('주문 취소 성공');
                      } catch (e) {
                        setState(() {
                          errorMessage = e.toString(); // 오류 메시지 업데이트
                        });
                      }
                    },
                    child: Text('주문 취소'),
                  ),
                ],
              ),
            if (errorMessage != null) // 오류 메시지가 있을 경우 표시
              Text('오류: $errorMessage', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
