import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? email;
  List<String> roles = [];
  String? accessToken;

  void setUserData({
    required String email,
    required List<String> roles,
    required String accessToken,
  }) {
    this.email = email;
    this.roles = roles;
    this.accessToken = accessToken;
    notifyListeners();
  }

  void clearUserData() {
    email = null;
    roles = [];
    accessToken = null;
    notifyListeners();
  }
} 