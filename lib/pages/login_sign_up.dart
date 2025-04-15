import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:help_desk_ai_ui/pages/chat.dart';
import 'package:help_desk_ai_ui/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:help_desk_ai_ui/config.dart';
import 'package:help_desk_ai_ui/utils/error_parser.dart';


final String baseURL = Config.baseUrl.isNotEmpty ? Config.baseUrl : "localhost";


class LoginSignUpPage extends StatefulWidget {
  const LoginSignUpPage({super.key});

  @override
  State<LoginSignUpPage> createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;

  final String serviceURL = 'http://$baseURL:8080';

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _submit(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final endpoint = _isLogin ? "$serviceURL/token" : "$serviceURL/signup";
      final isForm = _isLogin;
      final headers = {
        "Content-Type": isForm
            ? "application/x-www-form-urlencoded"
            : "application/json"
      };
      final body = isForm
          ? {
              "username": usernameController.text.trim(),
              "password": passwordController.text.trim(),
            }
          : jsonEncode({
              "username": usernameController.text.trim(),
              "password": passwordController.text.trim(),
            });

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = _isLogin ? responseData['access_token'] : null;

        if (_isLogin && token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          print("✅ Token saved");
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showSnack("✅ Signup successful. You can now log in.");
          setState(() => _isLogin = true);
        }
      } else {
        final error = parseErrorMessage(jsonDecode(response.body));
        _showSnack("❌ $error");
      }
    } catch (e) {
      _showSnack("⚠️ Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // String parseErrorMessage(dynamic responseBody) {
  //   if (responseBody is List && responseBody.isNotEmpty) {
  //     return responseBody.map((e) => e["msg"] ?? "").whereType<String>().join('\n');
  //   }

  //   if (responseBody is Map && responseBody.containsKey("detail")) {
  //     final detail = responseBody["detail"];
  //     if (detail is String) return detail;
  //     if (detail is List) {
  //       return detail.map((e) => e["msg"] ?? "").whereType<String>().join('\n');
  //     }
  //   }

  //   return "Something went wrong. Please try again.";
  // }


  void _showSnack(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _header() {
    return Column(
      children: [
        Text(
          _isLogin ? "Welcome Back" : "Create Account",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(_isLogin ? "Login to continue" : "Signup to get started"),
      ],
    );
  }

  Widget _inputFields() {
    final inputStyle = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color(0xFFE3F2FD),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: usernameController,
          decoration: inputStyle.copyWith(
            hintText: "Username",
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: inputStyle.copyWith(
            hintText: "Password",
            prefixIcon: const Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _submit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_isLogin ? "Login" : "Sign Up"),
        ),
      ],
    );
  }

  Widget _toggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_isLogin ? "Don't have an account?" : "Already have an account?"),
        TextButton(
          onPressed: () => setState(() => _isLogin = !_isLogin),
          child: Text(
            _isLogin ? "Sign Up" : "Login",
            style: const TextStyle(color: Color(0xFF1976D2)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(),
            _inputFields(),
            _toggleMode(),
          ],
        ),
      ),
    );
  }
}
