import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? email;
  String? name;
  List<String> roles = [];
  String? accessToken;

  void setUserData({
    required String email,
    required String name,
    required List<String> roles,
    required String accessToken,
  }) {
    this.email = email;
    this.name = name;
    this.roles = roles;
    this.accessToken = accessToken;
    notifyListeners();
  }

  void clearUserData() {
    email = null;
    name = null;
    roles = [];
    accessToken = null;
    notifyListeners();
  }
} 