import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../util/api_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/common_bottom_navigation.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/member/info'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userInfo = jsonDecode(utf8.decode(response.bodyBytes));
        });
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  Future<void> _logout() async {
    // 확인 다이얼로그 표시
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 취소
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 확인
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    // 사용자가 확인을 선택한 경우에만 로그아웃 진행
    if (confirmLogout == true) {
      try {
        final response = await http.post(
          Uri.parse('${ApiUtils.baseUrl}/member/logout'),
        );

        if (response.statusCode == 200) {
          // 로그아웃 성공 시 UserProvider의 데이터 초기화
          context.read<UserProvider>().clearUserData();
          // 로그인 페이지로 이동
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('로그아웃 실패')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그아웃 중 오류 발생: $e')),
          );
        }
      }
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    
    // 로그인 체크
    if (!userProvider.isLoggedIn) {
      // 비동기로 처리하여 build 메서드가 즉시 반환될 수 있도록 함
      Future.microtask(() => 
        Navigator.pushReplacementNamed(context, '/login')
      );
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: const AssetImage('assets/profile.jpg'),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.name ?? '사용자',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userProvider.email ?? 'email@example.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // 주문 관련 메뉴
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '쇼핑 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.shopping_bag,
                    title: '주문 내역',
                    onTap: () => Navigator.pushNamed(context, '/orderHist'),
                  ),
                  _buildMenuItem(
                    icon: Icons.shopping_cart,
                    title: '장바구니 목록',
                    onTap: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  _buildMenuItem(
                    icon: Icons.local_shipping,
                    title: '배송지 관리',
                    onTap: () => Navigator.pushNamed(context, '/addresses'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // 고객 지원 메뉴
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '고객 지원',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.headset_mic,
                    title: '고객센터',
                    onTap: () => Navigator.pushNamed(context, '/customer-service'),
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: '공지사항',
                    onTap: () => Navigator.pushNamed(context, '/notices'),
                  ),
                  _buildMenuItem(
                    icon: Icons.question_answer,
                    title: '자주 묻는 질문',
                    onTap: () => Navigator.pushNamed(context, '/faq'),
                  ),
                ],
              ),
            ),
            
            // 로그아웃 버튼
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[200],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 3),
    );
  }
} 