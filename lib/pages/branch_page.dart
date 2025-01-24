import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../util/api_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common_bottom_navigation.dart';

class BranchPage extends StatefulWidget {
  const BranchPage({super.key});

  @override
  State<BranchPage> createState() => _BranchPageState();
}

class _BranchPageState extends State<BranchPage> {
  Map<String, List<dynamic>> yearProducts = {
    '1999': [],
    '2001': [],
    '2002': [],
  };

  @override
  void initState() {
    super.initState();
    fetchAllYearProducts();
  }

  Future<void> fetchAllYearProducts() async {
    await Future.wait([
      fetchProductsByYear('1999'),
      fetchProductsByYear('2001'),
      fetchProductsByYear('2002'),
    ]);
  }

  Future<void> fetchProductsByYear(String year) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/product/list?releaseDate=$year'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          yearProducts[year] = responseData;
        });
      }
    } catch (e) {
      print('Error fetching $year products: $e');
    }
  }

  Widget _buildProductList(String year, List<dynamic> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '$year년 작품',
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
                  
                  Navigator.pushNamed(
                    context,
                    '/product_detail',
                    arguments: {'productId': product['id']},
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '연도별 작품',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductList('1999', yearProducts['1999']!),
            _buildProductList('2001', yearProducts['2001']!),
            _buildProductList('2002', yearProducts['2002']!),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 1),
    );
  }
} 