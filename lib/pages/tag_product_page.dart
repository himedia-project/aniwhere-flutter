import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../util/api_utils.dart';
import 'package:intl/intl.dart';

class TagProductPage extends StatefulWidget {
  final int tagId;
  final String tagName;

  const TagProductPage({
    super.key, 
    required this.tagId, 
    required this.tagName
  });

  @override
  State<TagProductPage> createState() => _TagProductPageState();
}

class _TagProductPageState extends State<TagProductPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTagProducts();
  }

  Future<void> fetchTagProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/tag/${widget.tagId}/product/list'),
      );

      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching tag products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.tagName}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
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
                              Text(
                                '₩${NumberFormat('#,###').format(product['price'] ?? 0)}',
                                style: const TextStyle(
                                  color: Color(0xFF6B8DD6),
                                  fontSize: 14,
                                ),
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
    );
  }
} 