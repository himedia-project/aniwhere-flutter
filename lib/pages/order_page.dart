import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/order_provider.dart'; // OrderProvider 임포트
import '../util/api_utils.dart';
import 'cart_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserInfo {
  final String name;
  final String email;

  UserInfo({
    required this.name,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'],
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

    if (args['cartItems'] is Future<List<CartItemDTO>>) {
      // cartItems가 Future<List<CartItemDTO>>일 경우
      cartItems = args['cartItems'];
    } else if (args['product'] != null) {
      // 단일 제품 정보가 전달된 경우
      final product = args['product'] as Map<String, dynamic>;
      cartItems = Future.value([
        CartItemDTO(
          cartItemId: 0, // 새로운 카트 아이템이므로 ID는 0 또는 적절한 값으로 초기화
          productId: product['productId'],
          productName: product['name'],
          price: product['price'],
          imageName: product['imageName'] ?? '', // 이미지 이름이 없을 경우 빈 문자열 처리
        ),
      ]);
    } else {
      // 기본값 설정 (예: 비어 있는 리스트)
      cartItems = Future.value([]);
    }
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
        try {
          final responseBody = response.body;
          print('Response body: $responseBody'); // 응답 본문 출력

          String orderId;

          // 응답 본문이 JSON 형식인지 확인
          if (responseBody.startsWith('{')) {
            final parsedResponse = json.decode(responseBody);
            orderId = parsedResponse['orderId'];
          } else {
            // 단순 텍스트 형식 처리
            orderId = responseBody.split(':').last.trim();
          }

          orderProvider.addOrder(Order(
            email: userInfo['email'] ?? '',
            paymentMethod: selectedPaymentMethod!,
            items: cartItemsList,
            totalPrice: 0, // 총 가격은 나중에 계산
          ));

          // 디버그: 주문이 성공적으로 처리되었음을 확인
          print('Order placed successfully, Order ID: $orderId');

          // 알림 대화상자 표시
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('주문 완료'),
              content: Text('결제가 완료되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 대화상자 닫기
                    Navigator.of(context).pushReplacementNamed('/home'); // 홈페이지로 이동
                  },
                  child: Text('돌아가기'),
                ),
              ],
            ),
          );
        } catch (e) {
          print('Error parsing response body: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('주문 처리 중 오류가 발생했습니다.')),
          );
        }
      } else {
        // 오류 처리
        print('Error: ${response.statusCode} - ${response.body}');
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
    final userInfo = context.read<UserProvider>().getUserInfo;

    return Scaffold(
      appBar: AppBar(
        title: Text('결제하기'),
        automaticallyImplyLeading: false,
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
            int totalPrice = items.fold(0, (sum, item) => sum + item.price);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 사용자 정보
                        Text('주문자 정보', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 8),
                        Text('이름: ${userInfo['name']}'),
                        Text('이메일: ${userInfo['email']}'),
                        SizedBox(height: 16),

                        // 주문 상품 정보
                        Text('주문 상품 정보', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              leading: Container(
                                width: 50, // 고정된 너비 설정
                                height: 50, // 고정된 높이 설정
                                child: CachedNetworkImage(
                                  imageUrl: item.getImageUrl(), // 이미지 URL 가져오기
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.error),
                                        ),
                                      ),
                                ),
                              ),
                              title: Text(item.productName),
                              subtitle: Text('${item.getPriceFormatted()} 원'),
                            );
                          },
                        ),
                        SizedBox(height: 16),

                        // 주문 요약
                        Text('주문 요약', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 8),
                        Text('총 주문금액: ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 원'),
                        SizedBox(height: 16),

                        // 결제 수단
                        Text('결제수단', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.9, // 화면 너비의 90%
                  padding: const EdgeInsets.all(16.0), // 패딩 추가
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.0), // 버튼 높이 조절
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () async {
                      await placeOrder(accessToken!);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, size: 24),
                        SizedBox(width: 10),
                        Text('주문 완료'),
                      ],
                    ),
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
