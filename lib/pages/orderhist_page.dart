import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_service.dart';
import '../order/order_hist.dart';

class OrderhistPage extends StatefulWidget {
  const OrderhistPage({super.key});

  @override
  _OrderhistPageState createState() => _OrderhistPageState();
}

class _OrderhistPageState extends State<OrderhistPage> {
  late ApiService apiService;
  List<OrderHist>? orderHistory;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false);
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    try {
      final List<OrderHist> history = await apiService.getOrderHistory('user@example.com');
      setState(() {
        orderHistory = history;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('구매내역'),
      ),
      body: Center(
        child: errorMessage != null
            ? Text('오류: $errorMessage', style: TextStyle(color: Colors.red))
            : orderHistory == null
            ? CircularProgressIndicator()
            : ListView.builder(
          itemCount: orderHistory!.length,
          itemBuilder: (context, index) {
            final order = orderHistory![index];
            return ListTile(
              title: Text('주문 ID: ${order.orderId}'),
              subtitle: Text('주문 상태: ${order.orderStatus}\n총 가격: ${order.totalPrice}원'),
              trailing: ElevatedButton(
                onPressed: () async {
                  try {
                    await apiService.cancelOrder(order.orderId);
                    setState(() {
                      orderHistory!.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('주문이 취소되었습니다.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('주문 취소 실패: $e')),
                    );
                  }
                },
                child: Text('취소'),
              ),
            );
          },
        ),
      ),
    );
  }
}
