import 'package:aniwhere_flutter/pages/branch_page.dart';
import 'package:aniwhere_flutter/pages/home_page.dart';
import 'package:aniwhere_flutter/pages/login_page.dart';
import 'package:aniwhere_flutter/pages/product_page.dart';
import 'package:aniwhere_flutter/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:aniwhere_flutter/pages/order_page.dart';
import 'package:aniwhere_flutter/pages/cart_page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:aniwhere_flutter/pages/search_result_page.dart';
import 'package:aniwhere_flutter/pages/orderhist_page.dart';
import 'package:aniwhere_flutter/pages/join_page.dart';
import 'package:aniwhere_flutter/pages/category_product_page.dart';
import 'package:aniwhere_flutter/pages/splash_screen.dart';
import 'package:aniwhere_flutter/pages/product_detail_page.dart';
import 'package:aniwhere_flutter/pages/tag_product_page.dart';
import 'package:aniwhere_flutter/providers/order_provider.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '64700a6255e1a4d6afd338b83bca917b');
  runApp(
    MultiProvider( // MultiProvider로 변경
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()), // OrderProvider 추가
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> printKeyHash() async {
  try {
    final keyHash = await KakaoSdk.origin;
    print("현재 사용 중인 키 해시: $keyHash");
  } catch (e) {
    print("키 해시를 가져오는 중 오류 발생: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aniwhere App',
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen()
        "/home": (context) => const HomePage(),
        "/login": (context) => const LoginPage(),
        "/join": (context) => const JoinPage(),
        "/search": (context) => const SearchResultPage(searchKeyword: ''),
        "/branch": (context) => const BranchPage(),
        "/product": (context) => const ProductPage(),
        "/tag": (context) => const ProductPage(),
        "/cart": (context) => const CartPage(),
        "/order": (context) => const OrderPage(),
        "/orderHist": (context) => const OrderHistPage(),
        "/category_products": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CategoryProductPage(
            categoryId: args['categoryId'],
            categoryName: args['categoryName'],
          );
        },
        "/mypage": (context) => const MyPage(),
        "/product_detail": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProductDetailPage(productId: args['productId']);
        },
        "/tag_products": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return TagProductPage(
            tagId: args['tagId'],
            tagName: args['tagName'],
          );
        },
      },
    );
  }
}


