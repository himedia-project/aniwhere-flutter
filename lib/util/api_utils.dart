import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

  static Future<bool> checkAdultVerification(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/member/adult'),
        headers: getAuthHeaders(context),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = responseData['errMsg'] ?? '성인 인증이 필요합니다.';
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Center(
              child: Text('❗성인 인증 필요'),
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        return false;
      }
    } catch (e) {
      print('Error checking adult verification: $e');
      return false;
    }
  }
} 