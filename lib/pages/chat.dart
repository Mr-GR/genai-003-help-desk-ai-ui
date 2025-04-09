import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:help_desk_ai_ui/pages/login_sign_up.dart';
import 'package:help_desk_ai_ui/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Request {
  final String ticket;
  final String response;

  const Request({required this.ticket, required this.response});

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      ticket: json['ticket'],
      response: json['response'] ?? json['answer'],
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatPageWidget();
  }
}

class ChatPageWidget extends StatefulWidget {
  const ChatPageWidget({super.key});

  @override
  State<ChatPageWidget> createState() => _ChatPageWidgetState();
}

class _ChatPageWidgetState extends State<ChatPageWidget> {
  final requestBox = TextEditingController();
  List<Request> requestHistory = [];
  String serviceURL = "http://localhost:8080/";
  String queryMode = "RAG";
  bool _isLoading = false;

  Future<void> createRequest(String ticket) async {
    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('${serviceURL}${queryMode == "RAG" ? "request" : "ask"}');
    final body = queryMode == "RAG" ? {"ticket": ticket} : {"question": ticket};

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token", 
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        final newRequest = Request.fromJson({...responseData, 'ticket': ticket});

        setState(() {
          requestHistory.add(newRequest);
          requestBox.clear();
        });
      } else {
        print("❌ Error (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text('Help Desk AI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: requestHistory.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: requestHistory.length,
                    itemBuilder: (context, index) {
                      final request = requestHistory[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1976D2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(request.ticket),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const CircleAvatar(
                                    backgroundColor: Color.fromARGB(255, 177, 177, 177),
                                    foregroundColor: Colors.black,
                                    child: Text('U'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color.fromARGB(255, 177, 177, 177),
                                    foregroundColor: Colors.black,
                                    child: Text('AI'),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(request.response),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(child: Text("No tickets yet.")),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              border: const Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: requestBox,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: queryMode,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            queryMode = value!;
                          });
                        },
                  items: const [
                    DropdownMenuItem(value: "RAG", child: Text("RAG")),
                    DropdownMenuItem(value: "LLM", child: Text("LLM")),
                  ],
                ),
                const SizedBox(width: 8),
                _isLoading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        iconSize: 28,
                        color: const Color.fromARGB(255, 0, 2, 0),
                        onPressed: () {
                          if (requestBox.text.isNotEmpty) {
                            createRequest(requestBox.text);
                          }
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
