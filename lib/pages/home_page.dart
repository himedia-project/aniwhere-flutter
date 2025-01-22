import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

import '../util/api_utils.dart';
import '../pages/search_result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> mdPickProducts = [];
  List<dynamic> adultProducts = [];
  List<dynamic> newProducts = [];
  List<dynamic> categories = [];
  final List<String> bannerImages = [
    'assets/banner1.jpg',
    'assets/banner2.jpg',
    'assets/banner3.jpg',
    'assets/banner4.jpg',
    'assets/banner5.jpg',
  ];
  int _currentBannerIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    fetchAllProducts();
    fetchCategories();
    // 배너 자동 슬라이드 타이머 설정
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (mounted) {
        final nextPage = (_currentBannerIndex + 1) % bannerImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchAllProducts() async {
    await Future.wait([
      fetchMdPickProducts(),
      fetchAdultProducts(),
      fetchNewProducts(),
    ]);
  }

  Future<void> fetchMdPickProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/product/list?mdPick=Y'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          mdPickProducts = responseData;
        });
      }
    } catch (e) {
      print('Error fetching MD Pick products: $e');
    }
  }

  Future<void> fetchAdultProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/product/list?adult=Y'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          adultProducts = responseData;
        });
      }
    } catch (e) {
      print('Error fetching adult products: $e');
    }
  }

  Future<void> fetchNewProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/product/list?isNew=Y'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          newProducts = responseData;
        });
      }
    } catch (e) {
      print('Error fetching new products: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/category/list'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        print('Fetched categories: $responseData');
        setState(() {
          categories = responseData;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
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

  Widget _buildProductList(String title, List<dynamic> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final String imageUrl = product['uploadFileNames'] != null && 
                                    product['uploadFileNames'].isNotEmpty
                  ? '${ApiUtils.baseUrl}/product/view/${product['uploadFileNames'][0]}'
                  : '';
              return Container(
                width: 200,
                margin: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₩${NumberFormat('#,###').format(product['price'] ?? 0)}',
                      style: const TextStyle(
                        color: Color(0xFF6B8DD6),
                        fontSize: 14,
                      ),
                    ),
                    if (product['adult'] == 'Y')
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '19금',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    print('Building categories: $categories');
    final List<Color> categoryColors = [
      const Color(0xFFFF6B6B),  // 빨간색 계열 (기존 첫번째)
      const Color(0xFFFFBE0B),  // 노란색 계열
      const Color(0xFF4ECDC4),  // 청록색 계열 (기존 두번째)
      const Color(0xFF845EC2),  // 보라색 계열
      const Color(0xFF4CAF50),  // 초록색 계열
      const Color(0xFFFF9A8B),  // 연한 핑크
      const Color(0xFFFF7B54),  // 주황색 계열
      const Color(0xFF00B4D8),  // 하늘색
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                // 색상 인덱스를 순환하여 사용
                final colorIndex = index % categoryColors.length;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/category_products',
                        arguments: {
                          'categoryId': category['categoryId'],
                          'categoryName': category['name'],
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColors[colorIndex],
                      foregroundColor: Colors.white,  // 텍스트 색상을 흰색으로 변경
                      elevation: 3,  // 그림자 효과 추가
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      category['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,  // 텍스트를 굵게 설정
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aniwhere',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              Navigator.pushNamed(context, '/branch');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: (){
              Navigator.pushNamed(context, '/cart');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/mypage');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 11,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: bannerImages.length,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentBannerIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        bannerImages[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        bannerImages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentBannerIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildCategories(),
            _buildProductList('MD Pick`s 이번 주 추천!', mdPickProducts),
            _buildProductList('어른들의 세계', adultProducts),
            _buildProductList('New 신작 작품들!', newProducts),
          ],
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('검색어를 입력해주세요'),
      );
    }
    
    return SearchResultPage(searchKeyword: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('검색어를 입력하세요'),
    );
  }
}

