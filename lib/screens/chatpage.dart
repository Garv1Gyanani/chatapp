import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/chat_service.dart';
import 'package:chatapp/message.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user;

  ChatPage({Key? key, required this.user}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _receiverId;

  @override
  void initState() {
    super.initState();
    if (widget.user['id'] != null) {
      _receiverId = widget.user['id']; 
    } else {
      throw Exception('User ID is null. Check the user data passed to ChatPage.');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await _chatService.sendMessage(_receiverId, _messageController.text);
        _messageController.clear(); // Clear the message input after sending
      } catch (e) {
        // Handle the error (e.g., show a snackbar)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['name'] ?? 'Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessage(_chatService.getCurrentUserId()!, _receiverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading messages"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs.map((doc) {
                  return Message.fromMap(doc.data() as Map<String, dynamic>);
                }).toList() ?? [];

                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                return ListView.builder(
                  reverse: true, // Show the latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isSentByMe = message.senderId == _auth.currentUser?.uid;

                    return Align(
                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4.0,
                              spreadRadius: 1.0,
                              offset: Offset(2.0, 2.0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.message,
                              style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _formatTimestamp(message.timestamp),
                              style: TextStyle(fontSize: 10.0, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
