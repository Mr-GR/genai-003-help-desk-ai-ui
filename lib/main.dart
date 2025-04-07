import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Request {
  final String ticket;
  final String response;

  const Request({required this.ticket, required this.response});

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      ticket: json['ticket'],
      response: json['response'] ?? json['answer'], // works for both endpoints
    );
  }
}

void main() {
  runApp(const HelpDeskAIUIApp());
}

class HelpDeskAIUIApp extends StatelessWidget {
  const HelpDeskAIUIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelpDeskAIUIApp',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Help Desk AI'),
        ),
        body: const Center(
          child: HelpDeskAIUIAppWidget(),
        ),
      ),
    );
  }
}

class HelpDeskAIUIAppWidget extends StatefulWidget {
  const HelpDeskAIUIAppWidget({super.key});

  @override
  State<HelpDeskAIUIAppWidget> createState() => _HelpDeskAIUIAppWidgetState();
}

class _HelpDeskAIUIAppWidgetState extends State<HelpDeskAIUIAppWidget> {
  final _biggerFont = const TextStyle(fontSize: 18);
  final requestBox = TextEditingController();
  List<Request> requestHistory = [];
  String serviceURL = "http://localhost:8080/";
  String queryMode = "RAG";

  Future<void> createRequest(String ticket) async {
    final uri = Uri.parse('${serviceURL}${queryMode == "RAG" ? "request" : "ask"}');
    final body = queryMode == "RAG"
        ? {"ticket": ticket}
        : {"question": ticket};

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      final newRequest = Request.fromJson({
        ...responseData,
        'ticket': ticket,
      });

      setState(() {
        requestHistory.add(newRequest);
        requestBox.clear();
      });
    } else {
      print("Error (${response.statusCode}): ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: requestHistory.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: requestHistory.length,
                  itemBuilder: (context, index) {
                    final request = requestHistory[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 12.0),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      request.ticket,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const CircleAvatar(
                                  backgroundColor: Colors.blueGrey,
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
                                  backgroundColor: Colors.grey,
                                  child: Text('AI'),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      request.response,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
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
            color: Colors.grey[100],
            border: const Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: requestBox,
                  decoration: const InputDecoration(
                    hintText: 'Ask a question...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: queryMode,
                items: const [
                  DropdownMenuItem(value: "RAG", child: Text("RAG")),
                  DropdownMenuItem(value: "LLM", child: Text("LLM")),
                ],
                onChanged: (value) {
                  setState(() {
                    queryMode = value!;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.send),
                iconSize: 28,
                color: Colors.green,
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
    );
  }
}
