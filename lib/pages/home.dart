import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageWidget();
  }
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text('Help Desk AI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text("Chat with AI"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.help_outline),
              label: const Text("Support Docs"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Coming soon...")),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Signing Out?'),
                    content: const Text("Are you sure you want to sign out?"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Sign Out")),
                    ],
                  ),
                );

                if (confirm == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('access_token');

                  print("✅ Token removed");
                  Navigator.pushNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
