import 'dart:convert';

import 'package:aniwhere_flutter/util/api_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/services.dart';

import '../providers/user_provider.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    // 로그인 요청을 보내는 코드
    try {
      final response = await http.post(
        Uri.parse('${ApiUtils.baseUrl}/member/login'),
        // application/json으로 헤더 설정, ApiUtils.getAuthHeaders(context) 아니고!
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        context.read<UserProvider>().setUserData(
          email: data['email'],
          roles: List<String>.from(data['roles']),
          accessToken: data['accessToken'],
        );
        print("data: ${data.toString()}");
        // Navigate to HomePage using named route
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _loginWithKakao() async {
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
          _processKakaoLogin();
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');

          if (error is PlatformException && error.code == 'CANCELED') {
            return;
          }
          
          try {
            await UserApi.instance.loginWithKakaoAccount();
            print('카카오계정으로 로그인 성공');
            _processKakaoLogin();
          } catch (error) {
            print('카카오계정으로 로그인 실패 $error');
            _showErrorMessage('카카오 로그인에 실패했습니다.');
          }
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          _processKakaoLogin();
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
          _showErrorMessage('카카오 로그인에 실패했습니다.');
        }
      }
    } catch (e) {
      _showErrorMessage('카카오 로그인 중 오류가 발생했습니다.');
    }
  }

  Future<void> _processKakaoLogin() async {
    try {
      User user = await UserApi.instance.me();
      print('카카오 사용자 정보: ${user.toString()}');
      // 서버에 카카오 로그인 정보를 전송하고 JWT 토큰을 받아옴
      final response = await http.post(
        Uri.parse('${ApiUtils.baseUrl}/member/kakao/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': user.kakaoAccount?.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('카카오 로그인 성공: $data');
        context.read<UserProvider>().setUserData(
          email: data['email'],
          roles: List<String>.from(data['roles']),
          accessToken: data['accessToken'],
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorMessage('로그인에 실패했습니다.');
      }
    } catch (e) {
      _showErrorMessage('로그인 처리 중 오류가 발생했습니다.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ani-where',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: '이메일',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('로그인'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loginWithKakao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('카카오로 로그인'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // TODO: 회원가입 페이지로 이동
                },
                child: const Text('계정이 없으신가요? 회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

