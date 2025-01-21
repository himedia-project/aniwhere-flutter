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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('제품 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: GridView.builder(     // 그리드 뷰
        padding: const EdgeInsets.all(16),    // 전체 패딩 16
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(      // 그리드 뷰의 레이아웃을 설정
          crossAxisCount: 2,        // 가로로 2개의 열
          childAspectRatio: 0.75,   // 가로 세로 비율 3:4
          crossAxisSpacing: 16,     // 가로 간격 16
          mainAxisSpacing: 16,      // 세로 간격 16
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            clipBehavior: Clip.antiAlias,   // 카드의 모서리를 둥글게 만들어줌
            elevation: 4,                 // 그림자 효과
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,     // 자식 위젯을 왼쪽 정렬
              children: [
                AspectRatio(              // 이미지의 가로 세로 비율을 유지하면서 크기를 조정
                  aspectRatio: 1,         // 가로 세로 비율 1:1
                  child: Image.network(
                    product['imageUrl'] ?? 'https://placeholder.com/300',
                    fit: BoxFit.cover,    // 이미지가 꽉 차게 보이도록 설정
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
                        // overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),    // 높이 4만큼 여백 추가
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

