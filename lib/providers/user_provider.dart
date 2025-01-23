import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? email;
  String? name;
  List<String> roles = [];
  String? accessToken;
  String? refreshToken;

  // 사용자 데이터 설정
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

  // 사용자 데이터 초기화
  void clearUserData() {
    email = null;
    name = null;
    roles = [];
    accessToken = null;
    notifyListeners();
  }

  // 로그인 상태 확인
  bool get isLoggedIn => accessToken != null;

  // 액세스 토큰 가져오기
  String? get getAccessToken => accessToken;

  // 리프레시 토큰 가져오기
  String? get getRefreshToken => refreshToken; // 리프레시 토큰 가져오는 메서드 추가

  void setAccessToken(String? token){
    accessToken = token;
    notifyListeners();
  }

  // 리프레시 토큰 설정
  void setRefreshToken(String? token) {
    refreshToken = token; // 리프레시 토큰 설정
    notifyListeners();
  }

  // 사용자 정보 가져오기
  Map<String, String?> get getUserInfo => {
    'email': email,
  };

}
