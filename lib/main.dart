import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aniwhere_flutter/pages/home_page.dart';
import 'package:aniwhere_flutter/pages/login_page.dart';
import 'package:aniwhere_flutter/pages/order_page.dart';
import 'package:aniwhere_flutter/pages/cart_page.dart';
import 'package:aniwhere_flutter/pages/orderhist_page.dart'; // 추가된 주문 내역 화면
import '../api/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()), // ApiService를 provider로 등록
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aniwhere App',
      initialRoute: "/",
      routes: {
        "/": (context) => const HomePage(),
        "/login": (context) => const LoginPage(),
        "/cart": (context) => const CartScreen(),
        "/order": (context) => const OrderScreen(),
        "/order_history": (context) => const OrderhistPage(), // 주문 내역 화면 라우트 추가
      },
    );
  }
}
