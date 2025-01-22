import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../util/api_utils.dart';

class SearchResultPage extends StatefulWidget {
  final String searchKeyword;

  const SearchResultPage({super.key, required this.searchKeyword});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List<dynamic> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults();
  }

  Future<void> fetchSearchResults() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiUtils.baseUrl}/product/list?searchKeyword=${Uri.encodeComponent(widget.searchKeyword)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          searchResults = responseData;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching search results: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final String imageUrl = product['uploadFileNames'] != null && 
                          product['uploadFileNames'].isNotEmpty
        ? '${ApiUtils.baseUrl}/product/view/${product['uploadFileNames'][0]}'
        : '';

    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.error)),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product['name'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '₩${NumberFormat('#,###').format(product['price'] ?? 0)}',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 14,
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
        title: Text('검색 결과: ${widget.searchKeyword}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
              ? const Center(child: Text('검색 결과가 없습니다.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) => _buildProductCard(searchResults[index]),
                ),
    );
  }
} 