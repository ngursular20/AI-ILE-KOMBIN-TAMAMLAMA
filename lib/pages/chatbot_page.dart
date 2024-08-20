import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage(String message) async {
    setState(() {
      _messages.insert(0, {'sender': 'user', 'message': message});
    });

    try {
      final response = await http.post(
        Uri.parse('http://89.252.140.157:2600/chatbot'),
        body: json.encode({'input': message}),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final botResponse = data['response'];

        setState(() {
          _messages.insert(0, {'sender': 'bot', 'message': botResponse});
        });
      } else {
        setState(() {
          _messages.insert(0, {
            'sender': 'bot',
            'message': 'Üzgünüm, bu soruya cevap vermek için eğitilmedim!'
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.insert(0, {
          'sender': 'bot',
          'message': 'Üzgünüm, bu soruya cevap vermek için eğitilmedim!'
        });
      });
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 141, 140, 142),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
        ),
        title: Text('Sohbet Botu'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['sender'] == 'user';
                final color =
                    isUserMessage ? Colors.deepPurple[100] : Colors.grey[300];
                final alignment = isUserMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Align(
                    alignment: alignment,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        message['message'] ?? '',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        InputDecoration(hintText: 'Mesajınızı yazın...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
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
