import 'package:flutter/material.dart';
import 'cart_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '장바구니 앱',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CartScreen(),
    );
  }
}
