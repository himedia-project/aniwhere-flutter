import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../util/api_utils.dart';

class OrderHistDTO {
  final int orderId;
  final String email;
  final DateTime orderDate;
  final String orderStatus;  // 주문 상태
  final int totalPrice;
  final String orderCode;

  OrderHistDTO({
    required this.orderId,
    required this.email,
    required this.orderDate,
    required this.orderStatus, // 주문 상태
    required this.totalPrice,
    required this.orderCode,
  });

  factory OrderHistDTO.fromJson(Map<String, dynamic> json) {
    return OrderHistDTO(
      orderId: json['orderId'] ?? 0,
      email: json['email'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      orderStatus: json['orderStatus'] ?? 'UNKNOWN', // 주문 상태
      totalPrice: json['totalPrice'] ?? 0,
      orderCode: json['orderCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "email": email,
      "orderDate": orderDate.toIso8601String(),
      "orderStatus": orderStatus, // 주문 상태
      "totalPrice": totalPrice,
      "orderCode": orderCode,
    };
  }
}

class OrderHistPage extends StatefulWidget {
  const OrderHistPage({super.key});

  @override
  _OrderHistPageState createState() => _OrderHistPageState();
}

class _OrderHistPageState extends State<OrderHistPage> {
  late Future<List<OrderHistDTO>> orderHist;

  @override
  void initState() {
    super.initState();
    final accessToken = context.read<UserProvider>().getAccessToken;

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('토큰이 없습니다. 로그인 해주세요.')),
      );
      orderHist = Future.value([]);
      return;
    }

    orderHist = fetchOrderHistory(accessToken);
  }

  Future<List<OrderHistDTO>> fetchOrderHistory(String accessToken) async {
    final response = await http.get(
      Uri.parse('${ApiUtils.baseUrl}/order/hist/list'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((order) => OrderHistDTO.fromJson(order)).toList();
    } else {
      throw Exception('주문 내역을 가져오는 데 실패했습니다.');
    }
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('${ApiUtils.baseUrl}/auth/refresh'), // 리프레시 토큰 API 엔드포인트
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['accessToken']; // 새로운 액세스 토큰 반환
    } else {
      throw Exception('액세스 토큰 갱신 실패: ${response.statusCode}');
    }
  }

  Future<void> cancelOrder(int orderId, String accessToken) async {
    final response = await http.post(
      Uri.parse('${ApiUtils.baseUrl}/order/$orderId/cancel'), // POST 요청으로 상태 변경
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'order_rstatus': 'CANCEL'}), // 상태 변경 요청
    );

    if (response.statusCode != 200) {
      throw Exception('주문 취소에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
      ),
      body: FutureBuilder<List<OrderHistDTO>>(
        future: orderHist,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('주문 내역이 없습니다.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('주문 번호: ${order.orderCode}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('총 금액: ₩${order.totalPrice}'),
                      Text('주문 날짜: ${order.orderDate.toLocal().toString().split(' ')[0]}'),
                      Text('주문 상태: ${order.orderStatus}'),
                    ],
                  ),
                  trailing: order.orderStatus == 'ORDER' // 주문 상태가 'ORDER'인 경우에만 버튼 활성화
                      ? IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () async {
                      String? accessToken = context.read<UserProvider>().getAccessToken;
                      String? refreshToken = context.read<UserProvider>().getRefreshToken; // 리프레시 토큰 가져오기

                      if (accessToken == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('토큰이 없습니다. 로그인 해주세요.')),
                        );
                        return;
                      }

                      try {
                        await cancelOrder(order.orderId, accessToken);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('주문이 취소되었습니다.')),
                        );
                        setState(() {
                          orderHist = fetchOrderHistory(accessToken); // 새로고침
                        });
                      } catch (e) {
                        if (e.toString().contains('Expired')) {
                          try {
                            // 리프레시 토큰을 사용하여 새로운 액세스 토큰 요청
                            String newAccessToken = await refreshAccessToken(refreshToken!); // null 체크
                            context.read<UserProvider>().setAccessToken(newAccessToken); // 새 토큰 저장

                            // 새 액세스 토큰으로 주문 취소 시도
                            await cancelOrder(order.orderId, newAccessToken);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('주문이 취소되었습니다.')),
                            );

                            setState(() {
                              orderHist = fetchOrderHistory(newAccessToken); // 새로고침
                            });
                          } catch (refreshError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('리프레시 토큰 사용 실패: ${refreshError.toString()}')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('주문 취소 실패: ${e.toString()}')),
                          );
                        }
                      }
                    },
                  )
                      : null, // 취소 불가능한 경우 null 반환
                );
              },
            );
          }
        },
      ),
    );
  }
}
