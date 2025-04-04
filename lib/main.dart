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
      final List<dynamic> responseData = json.decode(response.body);
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
      children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: requestBox,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter Service Request',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              iconSize: 40,
              color: Colors.green,
              splashColor: Colors.purple,
              onPressed: () {
                if (requestBox.text.isNotEmpty) {
                  createRequest(requestBox.text);
                }
              },
            ),
          ),
        ]),
        Expanded(
          child: FutureBuilder<List<Request>>(
            future: futureRequests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final request = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 12.0),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text("Ticket: ${request.ticket}",
                              style: _biggerFont),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Response: ${request.response}",
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
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
      ],
    );
  }
}
