import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ApiUtils {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static Map<String, String> getAuthHeaders(BuildContext context) {
    final token = context.read<UserProvider>().accessToken;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static String getImageUrl(String imagePath) {
    return '$baseUrl/product/view/$imagePath';
  }
} 