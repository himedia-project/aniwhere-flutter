import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
  
  static bool get isDevelopment => environment == 'local';
  static bool get isProduction => environment == 'prod';
  
  static String get apiBaseUrl {
    switch (environment) {
      case 'prod':
        return dotenv.env['API_URL_PROD'] ?? '';
      case 'local':
      default:
        return dotenv.env['API_URL_LOCAL'] ?? '';
    }
  }
  
  // 추가 환경 설정들...
  static Map<String, dynamic> get config {
    switch (environment) {
      case 'prod':
        return {
          'apiBaseUrl': apiBaseUrl,
          'timeout': const Duration(seconds: 30),
          'enableLogging': false,
        };
      case 'local':
      default:
        return {
          'apiBaseUrl': apiBaseUrl,
          'timeout': const Duration(seconds: 60),
          'enableLogging': true,
        };
    }
  }
} 