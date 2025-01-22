import 'package:aniwhere_flutter/pages/home_page.dart';
import 'package:aniwhere_flutter/pages/login_page.dart';
import 'package:aniwhere_flutter/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:aniwhere_flutter/pages/order_page.dart';
import 'package:aniwhere_flutter/pages/cart_page.dart';
import 'package:provider/provider.dart';
import 'package:aniwhere_flutter/pages/orderhist_page.dart';

void main() {
  runApp(
      ChangeNotifierProvider(     // ChangeNotifierProvider란?
        create: (_) => UserProvider(),
        child: const MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aniwhere App',
      initialRoute: "/login",
      routes: {
        "/home": (context) => const HomePage(),
        "/login": (context) => const LoginPage(),
        "/cart": (context) => const CartPage(),
        "/order": (context) => const OrderPage(),
        "/order_history": (context) => const OrderhistPage(),
      },
    );
  }
}


