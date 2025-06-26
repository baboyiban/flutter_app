import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final apiUrl = dotenv.env['API_URL'];
    final url = Uri.parse('$apiUrl/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employee_id': int.tryParse(_idController.text.trim()),
          'password': _pwController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        widget.onLoginSuccess();
      } else {
        final data = jsonDecode(response.body);
        setState(() => _error = data['error'] ?? '로그인 실패');
      }
    } catch (e) {
      setState(() => _error = '네트워크 오류: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double fieldWidth = 240;
    const double borderRadius = 8;
    const double gap = 16;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 직원 ID 입력
            Container(
              width: fieldWidth,
              margin: const EdgeInsets.only(bottom: gap),
              decoration: BoxDecoration(
                color: AppColors.gray,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.black), // text-gray-400
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '직원 ID',
                  hintStyle: TextStyle(color: AppColors.darkGray),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            // 비밀번호 입력
            Container(
              width: fieldWidth,
              margin: const EdgeInsets.only(bottom: gap),
              decoration: BoxDecoration(
                color: AppColors.gray, // bg-gray-100
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _pwController,
                obscureText: true,
                style: const TextStyle(color: AppColors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '비밀번호',
                  hintStyle: TextStyle(color: AppColors.darkGray),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: gap),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            // 로그인 버튼
            Container(
              width: fieldWidth,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: _loading ? null : _login,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
