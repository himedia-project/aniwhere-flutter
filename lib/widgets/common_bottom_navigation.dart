import 'package:flutter/material.dart';

class CommonBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const CommonBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    // 상세 페이지 등 네비게이션에 속하지 않는 페이지의 경우 0으로 설정하되
    // 선택된 것처럼 보이지 않게 처리
    final effectiveIndex = currentIndex < 0 ? 0 : currentIndex;
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: effectiveIndex,
      selectedItemColor: currentIndex < 0 ? Colors.grey : const Color(0xFF6B8DD6),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: '지점',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: '장바구니',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
      onTap: (index) {
        if (index == currentIndex) return; // 현재 페이지면 아무 동작하지 않음
        
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/branch');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/cart');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/mypage');
            break;
        }
      },
    );
  }
} 