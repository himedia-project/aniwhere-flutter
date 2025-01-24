import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../util/api_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderItemDTO {
  final int productId;
  final String productName;
  final String imgUrl;

  OrderItemDTO({
    required this.productId,
    required this.productName,
    required this.imgUrl,
  });

  factory OrderItemDTO.fromJson(Map<String, dynamic> json) {
    return OrderItemDTO(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      imgUrl: json['imgUrl'] != null
          ? '${ApiUtils.baseUrl}/product/view/${json['imgUrl']}'
          : '', // 디폴트 이미지를 설정할 수도 있음
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "productName": productName,
      "imgUrl": imgUrl,
    };
  }
}


class OrderHistDTO {
  final int orderId;
  final String email;
  final DateTime orderDate;
  final String orderStatus;
  final int totalPrice;
  final String orderCode;
  final List<OrderItemDTO> orderItems;

  OrderHistDTO({
    required this.orderId,
    required this.email,
    required this.orderDate,
    required this.orderStatus,
    required this.totalPrice,
    required this.orderCode,
    required this.orderItems,
  });

  factory OrderHistDTO.fromJson(Map<String, dynamic> json) {
    return OrderHistDTO(
      orderId: json['orderId'] ?? 0,
      email: json['email'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      orderStatus: json['orderStatus'] ?? 'UNKNOWN',
      totalPrice: json['totalPrice'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderItems: (json['orderItems'] as List<dynamic>)
          .map((item) => OrderItemDTO.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "email": email,
      "orderDate": orderDate.toIso8601String(),
      "orderStatus": orderStatus,
      "totalPrice": totalPrice,
      "orderCode": orderCode,
      "orderItems": orderItems.map((item) => item.toJson()).toList(),
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
      String responseBody = utf8.decode(response.bodyBytes);
      List jsonResponse = json.decode(responseBody);
      return jsonResponse.map((order) => OrderHistDTO.fromJson(order)).toList();
    } else {
      String errorMsg = '주문 내역을 가져오는 데 실패했습니다.';
      if (response.statusCode == 401) {
        errorMsg = '인증 오류입니다. 다시 로그인 해주세요.';
      }
      throw Exception(errorMsg);
    }
  }

  Future<void> cancelOrder(int orderId, String accessToken) async {
    final response = await http.post(
      Uri.parse('${ApiUtils.baseUrl}/order/$orderId/cancel'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('주문이 취소되었습니다.')),
      );
      setState(() {
        orderHist = fetchOrderHistory(accessToken); // 주문 내역 새로 고침
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('주문 취소에 실패했습니다.')),
      );
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
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('주문 번호: ${order.orderCode}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('총 금액: ₩${order.totalPrice}'),
                        Text('주문 날짜: ${order.orderDate.toLocal().toString().split(' ')[0]}'),
                        Text('주문 상태: ${order.orderStatus}'),
                      ],
                    ),
                    onTap: () {
                      // 주문 클릭 시 얼럿 대화상자 표시
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('주문 상품 목록'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: order.orderItems.isNotEmpty
                                    ? order.orderItems.map((item) {
                                  return Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: item.imgUrl,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(item.productName,
                                        style: TextStyle(
                                          fontSize: 20
                                        ),),
                                      ),
                                    ],
                                  );
                                }).toList()
                                    : [Text('아이템이 없습니다.')],
                              ),
                            ),
                            actions: [
                              if (order.orderStatus == 'ORDER') // 주문 상태가 ORDER인 경우만 버튼 표시
                                TextButton(
                                  onPressed: () {
                                    final accessToken = context.read<UserProvider>().getAccessToken;
                                    if (accessToken != null) {
                                      cancelOrder(order.orderId, accessToken);
                                    }
                                  },
                                  child: Text('주문 취소'),
                                ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('닫기'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
