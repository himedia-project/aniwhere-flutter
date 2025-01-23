import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../util/api_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? productDetail;
  List<dynamic> tags = [];

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
    fetchProductTags();
  }

  Future<void> fetchProductDetail() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/product/${widget.productId}/detail'),
      );

      if (response.statusCode == 200) {
        setState(() {
          productDetail = jsonDecode(utf8.decode(response.bodyBytes));
        });
      }
    } catch (e) {
      print('Error fetching product detail: $e');
    }
  }

  Future<void> fetchProductTags() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/product/${widget.productId}/tag/list'),
      );

      if (response.statusCode == 200) {
        setState(() {
          tags = jsonDecode(utf8.decode(response.bodyBytes));
        });
      }
    } catch (e) {
      print('Error fetching product tags: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (productDetail == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String imageUrl = productDetail!['uploadFileNames'] != null &&
            productDetail!['uploadFileNames'].isNotEmpty
        ? '${ApiUtils.baseUrl}/product/view/${productDetail!['uploadFileNames'][0]}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(productDetail!['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 11,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.error)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        productDetail!['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (productDetail!['adult'] == 'Y')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '19금',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₩${NumberFormat('#,###').format(productDetail!['price'])}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF6B8DD6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#${tag['name']}',
                          style: const TextStyle(
                            color: Color(0xFF6B8DD6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '작품 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.category_outlined, size: 20, color: Color(0xFF6B8DD6)),
                      const SizedBox(width: 8),
                      Text(
                        '카테고리: ${productDetail!['categoryName']}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.business_outlined, size: 20, color: Color(0xFF6B8DD6)),
                      const SizedBox(width: 8),
                      Text(
                        '제작사: ${productDetail!['manufacturer']}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.video_library_outlined, size: 20, color: Color(0xFF6B8DD6)),
                      const SizedBox(width: 8),
                      Text(
                        '총 화수: ${productDetail!['totalEpisode']}화',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF6B8DD6)),
                      const SizedBox(width: 8),
                      Text(
                        '방영일: ${productDetail!['releaseDate']}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '줄거리',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(productDetail!['story'] ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 장바구니 추가 로직 구현
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('장바구니에 추가되었습니다')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6B8DD6),
                  side: const BorderSide(color: Color(0xFF6B8DD6)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('장바구니'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 구매하기 로직 구현
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8DD6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('구매하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 