import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:help_desk_ai_ui/pages/chat.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  final String serviceURL = "http://localhost:8080/login";

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(serviceURL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['access_token'];
        print("✅ Login successful: $token");

        Navigator.pushReplacementNamed(context, '/chat');
      } else {
        final error = jsonDecode(response.body)['detail'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Login failed: $error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _header() {
    return const Column(
      children: [
        Text("Welcome Back", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("Enter your credentials to login"),
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    final inputStyle = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
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
  onPressed: _isLoading ? null : () => _login(context),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1976D2), 
    foregroundColor: Colors.black,         
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(vertical: 16),
    textStyle: const TextStyle(            
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
  child: _isLoading
      ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
        )
      : const Text("Login"),
        ),
      ],
    );
  }

  Widget _forgotPassword() {
    return TextButton(
      onPressed: () {},
      child: const Text("Forgot password?", style: TextStyle(color: Color(0xFF1976D2))),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? Try as Guest"),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/chat');
          },
          child: const Text("Chat Now", style: TextStyle(color: Color(0xFF1976D2))),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/chat': (context) => const ChatPage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        primaryColor: const Color(0xFF1976D2),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(),
              _inputField(context),
              _forgotPassword(),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }
}
