import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:aniwhere_flutter/util/api_utils.dart';

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
  Map<String, dynamic> toJson(){
    return {
      "cartItemId":cartItemId,
      "productId":productId,
      "productName":productName,
      "price":price,
      "imageName":imageName
    };
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
                  title: Text(item.productName),
                  subtitle: Text('${item.price} 원'),
                  // leading: Image.network(item.imageName),
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

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 주문하기 버튼 클릭 시 OrderPage로 이동
          Navigator.pushNamed(context, '/order', arguments: {
            'cartItems': futureCartItems,
          });
        },
        child: Text('주문페이지')
      ),


      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     // 예시로 추가할 상품 ID를 설정합니다.
      //     int productIdToAdd = 1; // 실제 상품 ID로 변경하세요.
      //     await addCartItem(accessToken!, productIdToAdd);
      //     setState(() {
      //       futureCartItems = getCartItems(accessToken!);
      //     });
      //   },
      //   child: Icon(Icons.add),
      //   tooltip: '장바구니에 추가',
      // ),
    );
  }
}
