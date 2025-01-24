import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';  // 숫자 포맷팅을 위한 패키지 추가
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';    // 검색 기록 저장을 위한 패키지 추가
import 'package:cached_network_image/cached_network_image.dart';  // 이미지 캐싱을 위한 패키지 추가

import '../util/api_utils.dart';
import '../pages/product_detail_page.dart';
import '../widgets/common_bottom_navigation.dart';
import '../pages/product_list_page.dart';

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
  int _currentBannerIndex = 0;    // 현재 배너 인덱스
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
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemBuilder: (context, index) {
              final product = products[index];
              final String imageUrl = product['uploadFileNames'] != null && 
                                    product['uploadFileNames'].isNotEmpty
                  ? '${ApiUtils.baseUrl}/product/view/${product['uploadFileNames'][0]}'
                  : '';
              return GestureDetector(
                onTap: () async {
                  if (product['adult'] == 'Y') {
                    final isAdultVerified = await ApiUtils.checkAdultVerification(context);
                    if (!isAdultVerified) return;
                  }
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        productId: product['id'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 8),
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
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error),
                                ),
                              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 8), // 좌우 여백 추가
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
        automaticallyImplyLeading: false,   // 뒤로 가기 버튼을 숨김
        title: Image.asset(
          'assets/logo.png',
          height: 45,
          fit: BoxFit.contain,    // 이미지가 영역에 맞게 확대/축소
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(),    // 검색 위임자를 사용
              );
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
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}

/**
 * 검색 위임자 클래스
 */
class ProductSearchDelegate extends SearchDelegate {
  final List<String> _searchHistory = [];
  static const String _searchHistoryKey = 'search_history';

  ProductSearchDelegate() {
    _loadSearchHistory();
  }

  // 검색 기록 로드
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();    // SharedPreferences는 비동기로 초기화
    final history = prefs.getStringList(_searchHistoryKey) ?? [];
    _searchHistory.clear();
    _searchHistory.addAll(history);
  }

  // 검색 기록 저장
  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchHistoryKey, _searchHistory);
  }

  // 새 검색어 추가
  void _addSearchTerm(String term) {
    if (term.isEmpty) return;
    
    // 이미 존재하는 검색어라면 제거
    _searchHistory.remove(term);
    // 최근 검색어를 맨 앞에 추가
    _searchHistory.insert(0, term);
    // 최대 10개까지만 저장
    if (_searchHistory.length > 10) {
      _searchHistory.removeLast();
    }
    _saveSearchHistory();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
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
    
    _addSearchTerm(query); // 검색 실행 시 기록 추가
    return ProductListPage(
      title: '검색 결과: $query',
      apiPath: '/product/list',
      queryParams: {'searchKeyword': query},
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        // suggestions 리스트를 builder 내부로 이동
        final suggestions = _searchHistory.where((term) => 
          term.toLowerCase().contains(query.toLowerCase())
        ).toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(suggestion),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _searchHistory.remove(suggestion);
                    _saveSearchHistory();
                  });
                },
              ),
              onTap: () {
                query = suggestion;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}

