import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../util/api_utils.dart';
import '../widgets/common_bottom_navigation.dart';

class ProductListPage extends StatefulWidget {
  final String title;
  final String apiPath;
  final Map<String, String> queryParams;

  const ProductListPage({
    super.key,
    required this.title,
    required this.apiPath,
    this.queryParams = const {},
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final queryString = widget.queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final url =
          '${ApiUtils.baseUrl}${widget.apiPath}${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          products = responseData;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('검색 결과가 없습니다.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final String imageUrl = product['uploadFileNames'] !=
                                null &&
                            product['uploadFileNames'].isNotEmpty
                        ? '${ApiUtils.baseUrl}/product/view/${product['uploadFileNames'][0]}'
                        : '';

                    return GestureDetector(
                      onTap: () async {
                        if (product['adult'] == 'Y') {
                          final isAdultVerified =
                              await ApiUtils.checkAdultVerification(context);
                          if (!isAdultVerified) return;
                        }

                        Navigator.pushNamed(
                          context,
                          '/product_detail',
                          arguments: {'productId': product['id']},
                        );
                      },
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₩${NumberFormat('#,###').format(product['price'] ?? 0)}',
                                        style: const TextStyle(
                                          color: Color(0xFF6B8DD6),
                                          fontSize: 14,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 20,
                                        ),
                                        color: const Color(0xFF6B8DD6),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          if (product['adult'] == 'Y') {
                                            final isAdultVerified =
                                                await ApiUtils
                                                    .checkAdultVerification(
                                                        context);
                                            if (!isAdultVerified) return;
                                          }

                                          try {
                                            final response = await http.post(
                                              Uri.parse(
                                                  '${ApiUtils.baseUrl}/cart/add'),
                                              headers: ApiUtils.getAuthHeaders(
                                                  context),
                                              body: jsonEncode({
                                                'productId': product['id'],
                                              }),
                                            );

                                            if (response.statusCode == 200) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content:
                                                        Text('장바구니에 추가되었습니다')),
                                              );
                                            } else {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        '장바구니 추가에 실패했습니다')),
                                              );
                                            }
                                          } catch (e) {
                                            print('Error adding to cart: $e');
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      '장바구니 추가 중 오류가 발생했습니다')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  if (product['adult'] == 'Y')
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: -1),
    );
  }
}
