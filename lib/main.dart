import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// String decodeUtf8Safe(String input) {
//   return String.fromCharCodes(input.runes);
// }

class Request {
  final String ticket;
  final String response;

  const Request({required this.ticket, required this.response});

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      ticket: json['ticket'],
      response: json['response'],
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
  late Future<List<Request>> futureRequests;
  String serviceURL = "http://localhost:8080/";

  Future<List<Request>> getRequests() async {
    final response = await http.get(
      Uri.parse('${serviceURL}requests'),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      return responseData.map((data) => Request.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load requests');
    }
  }

  void createRequest(String ticket) async {
    final response = await http.post(
      Uri.parse('${serviceURL}request'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(<String, String>{
        'ticket': ticket,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        futureRequests = getRequests();
        requestBox.clear();
      });
    } else {
      print("Error creating request: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    futureRequests = getRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Request>>(
            future: futureRequests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final request = snapshot.data![index];
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
                                      request.ticket,// utf8.decode();
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
                          // Agent response (left)
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
                );
              } else {
                return const Center(child: Text("No tickets yet."));
              }
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: const Border(
              top: BorderSide(color: Colors.black12),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: requestBox,
                  decoration: const InputDecoration(
                    hintText: 'Enter your ticket here',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
