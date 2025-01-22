import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../util/api_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/product/list'),
        headers: ApiUtils.getAuthHeaders(context),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products = data['data'];
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> _logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiUtils.baseUrl}/member/logout'),
      );

      if (response.statusCode == 200) {
        // 로그아웃 성공 시 UserProvider의 데이터 초기화
        context.read<UserProvider>().clearUserData();
        // 로그인 페이지로 이동
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류 발생: $e')),
      );
    }
  }
      /////////////로그인상태확인
  void _goToCartPage() {
    // 로그인 상태 확인
    final userProvider = context.read<UserProvider>();
    if (userProvider.isLoggedIn) {
      // 로그인된 경우 장바구니 페이지로 이동
      Navigator.pushNamed(context, '/cart');
    } else {
      // 로그인되지 않은 경우 로그인 페이지로 이동
      Navigator.pushNamed(context, '/login');
    }
  }
  ///////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('제품 목록'),
        actions: [
          IconButton(
            ///////////////////////////장바구니
            icon: const Icon(Icons.shopping_cart),
            onPressed: _goToCartPage, // 장바구니 페이지로 이동
          ),
          /////////////////////////////
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product['imageUrl'] ?? 'https://placeholder.com/300',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₩${NumberFormat('#,###').format(product['price'] ?? 0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
