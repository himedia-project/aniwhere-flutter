import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/order_provider.dart'; // OrderProvider 임포트
import '../util/api_utils.dart';
import 'cart_page.dart'; // CartItem 클래스가 정의된 파일로 수정

class UserInfo {
  final String name;
  final String phone;
  final String email;

  UserInfo({
    required this.name,
    required this.phone,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Future<List<CartItemDTO>> cartItems;
  String? selectedPaymentMethod; // 선택된 결제 수단

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    cartItems = args['cartItems'];
  }

  Future<void> placeOrder(String accessToken) async {
    final userInfo = context.read<UserProvider>().getUserInfo;
    final orderProvider = context.read<OrderProvider>();

    if (selectedPaymentMethod != null) {
      // 카트 아이템 정보를 가져오기
      List<CartItemDTO> cartItemsList = await cartItems;

      // 주문 요청을 위한 데이터 생성
      final orderData = {
        "cartItems": cartItemsList.map((item) => {
          "productId": item.productId,
          // 필요한 경우 수량 추가
        }).toList(),
      };

      // API 호출
      final response = await http.post(
        Uri.parse('${ApiUtils.baseUrl}/order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        // 주문이 성공적으로 처리된 경우
        final responseBody = json.decode(response.body);
        final orderId = responseBody['orderId']; // JSON에서 orderId를 가져옵니다.
        orderProvider.addOrder(Order(
          email: userInfo['email'] ?? '',
          paymentMethod: selectedPaymentMethod!,
          items: cartItemsList,
          totalPrice: 0, // 총 가격은 나중에 계산
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('주문이 완료되었습니다. 주문 ID: $orderId')),
        );
      } else {
        // 오류 처리
        print('Error: ${response.statusCode} - ${response.body}'); // 응답 코드와 본문 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('주문 처리 중 오류가 발생했습니다.')),
        );
      }

    } else {
      // 결제 수단 선택 안 함
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('결제 수단을 선택하세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessToken = context.read<UserProvider>().getAccessToken;
    final userInfo = context.read<UserProvider>().getUserInfo; // 사용자 정보 가져오기

    return Scaffold(
      appBar: AppBar(
        title: Text('결제하기'),
      ),
      body: FutureBuilder<List<CartItemDTO>>(
        future: cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('장바구니가 비어 있습니다.'));
          } else {
            final items = snapshot.data!;
            int totalPrice = items.fold(0, (sum, item) => sum + item.price) + 3000; // 배송비 3000원 추가

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 사용자 정보
                        Text('주문자 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 8),
                        Text('이메일: ${userInfo['email']}'), // 사용자 이메일
                        SizedBox(height: 16),

                        // 주문 상품 정보
                        Text('주문 상품 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              title: Text(item.productName),
                              subtitle: Text('${item.price} 원'),
                            );
                          },
                        ),
                        SizedBox(height: 16),

                        // 주문 요약
                        Text('주문 요약', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 8),
                        Text('총 주문금액: $totalPrice 원'),
                        SizedBox(height: 16),

                        // 결제 수단
                        Text('결제수단', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('신용카드'),
                                value: '신용카드',
                                groupValue: selectedPaymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPaymentMethod = value;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('가상계좌'),
                                value: '가상계좌',
                                groupValue: selectedPaymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPaymentMethod = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 주문 완료 버튼
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await placeOrder(accessToken!);
                    },
                    child: Text('주문 완료'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
