import 'package:chatapp/appdrawar.dart';
import 'package:chatapp/chatpage.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChatApp',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search action
            },
          ),
        ],
        elevation: 8,
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading users"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        // Filter out the current user from the list
        final currentUserEmail = _auth.currentUser?.email;
        final filteredUsers = snapshot.data!.where((user) {
          return user['email'] != currentUserEmail; // Remove current user from the list
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return _buildUserTile(user, context);
            },
          ),
        );
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.tealAccent[400],
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          user['email'] ?? 'No email',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.message, color: Colors.teal),
          onPressed: () {
            // Debugging: Print the user data
            print('Navigating to ChatPage with user: $user');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  user: {
                    'id': user['uid'], // Assuming this is the correct field for the document ID
                    'email': user['email'],
                    'name': user['name'],
                    'phone': user['phone'],
                  },
                ),
              ),
            );
          },
        ),
        tileColor: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
