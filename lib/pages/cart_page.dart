import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:aniwhere_flutter/util/api_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/common_bottom_navigation.dart';  // 이미지 캐싱을 위한 패키지 추가

class CartItemDTO {
  final int cartItemId;
  final int productId;
  final String productName;
  final int price;
  final String imageName;

  CartItemDTO({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageName,
  });

  factory CartItemDTO.fromJson(Map<String, dynamic> json) {
    return CartItemDTO(
      cartItemId: json['cartItemId'],
      productId: json['productId'],
      productName: utf8.decode(json['productName'].codeUnits),
      price: json['price'],
      imageName: json['imageName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cartItemId": cartItemId,
      "productId": productId,
      "productName": productName,
      "price": price,
      "imageName": imageName,
    };
  }

  // 이미지 URL을 반환하는 메서드 추가
  String getImageUrl() {
    return '${ApiUtils.baseUrl}/product/view/$imageName'; // API URL과 이미지 파일 이름을 결합
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartItemDTO>> futureCartItems;

  @override
  void initState() {
    super.initState();
    final accessToken = context.read<UserProvider>().getAccessToken;
    futureCartItems = getCartItems(accessToken!);
  }

  Future<List<CartItemDTO>> getCartItems(String accessToken) async {
    final response = await http.get(
      Uri.parse('${ApiUtils.baseUrl}/cart/item/list'), // API URL 수정
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => CartItemDTO.fromJson(item)).toList();
    } else {
      throw Exception('장바구니 아이템을 가져오는 데 실패했습니다.');
    }
  }

  Future<List<CartItemDTO>> addCartItem(String accessToken, int productId) async {
    final response = await http.post(
      Uri.parse('${ApiUtils.baseUrl}/cart/add'), // API URL 수정
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'productId': productId,
      }),
    );

    if (response.statusCode == 200) {
      return getCartItems(accessToken);
    } else {
      throw Exception('장바구니에 아이템 추가 실패');
    }
  }

  Future<List<CartItemDTO>> removeCartItem(String accessToken, int cartItemId) async {
    final response = await http.delete(
      Uri.parse('${ApiUtils.baseUrl}/cart/$cartItemId'), // API URL 수정
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return getCartItems(accessToken);
    } else {
      throw Exception('장바구니 아이템 삭제 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessToken = context.read<UserProvider>().getAccessToken;

    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
      ),
      body: FutureBuilder<List<CartItemDTO>>(
        future: futureCartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('장바구니가 비어 있습니다.'));
          } else {
            final cartItems = snapshot.data!;
            return ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: Container(
                    width: 50, // 고정된 너비 설정
                    height: 50, // 고정된 높이 설정
                    child: CachedNetworkImage(
                      imageUrl: item.getImageUrl(), // 이미지 URL 가져오기
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  title: Text(item.productName),
                  subtitle: Text('${item.price} 원'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await removeCartItem(accessToken!, item.cartItemId);
                      setState(() {
                        futureCartItems = getCartItems(accessToken!);
                      });
                    },
                  ),
                );

              },
            );
          }
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 2),
      floatingActionButton: Align(
        // alignment: Alignment.bottomCenter, // 하단 중앙에 배치
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // 좌우 간격
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [Container(
                height: 70, // 버튼의 높이
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100], // 배경색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // 둥근 모서리
                    ),
                    textStyle: TextStyle(fontSize: 20), // 텍스트 크기
                  ),
                  onPressed: () async {
                    // 주문하기 버튼 클릭 시 OrderPage로 이동
                    Navigator.pushNamed(context, '/order', arguments: {
                      'cartItems': futureCartItems,
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 24), // 장바구니 아이콘 추가
                      SizedBox(width: 10), // 아이콘과 텍스트 간격
                      Text('장바구니 목록 주문하기'),
                    ],
                  ),
                ),
              ),]
          ),
        ),
      ),
    );
  }
}
