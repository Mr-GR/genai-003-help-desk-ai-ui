import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:help_desk_ai_ui/pages/chat.dart';
import 'package:help_desk_ai_ui/pages/home.dart';
import 'package:help_desk_ai_ui/pages/login_sign_up.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const HelpDeskAIUIApp());
}

class HelpDeskAIUIApp extends StatelessWidget {
  const HelpDeskAIUIApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'HelpDesk AI',
    theme: ThemeData(
      primaryColor: const Color(0xFF1976D2),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE3F2FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => const LoginSignUpPage(),
      '/home': (context) => const HomePage(),
      '/chat': (context) => const ChatPage(),
    },
  );
  }
}
