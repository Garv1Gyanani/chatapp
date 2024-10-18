import 'package:chatapp/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
        data['uid'] = doc.id; // Add uid as the document ID
        return data; // Return the user data along with uid
      }).toList(); // Convert the iterable to a list
    });
  }

  // Send a message to a specific receiver
  Future<void> sendMessage(String receiverId, String message) async {
    final String? currentUserId = getCurrentUserId();
    if (currentUserId == null) return; // Ensure current user is logged in

    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Create a new Message object
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Sort the IDs to create a unique chatRoomId for both users
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Save the message to Firestore under the specific chat room
    await _firestore
        .collection("chatRooms") // Changed "chat_rooms" to "chatRooms" for consistency
        .doc(chatRoomId) // Create or reference the chat room
        .collection("messages") // Create a sub-collection for messages
        .add(newMessage.toMap());
  }

  // Get messages for a specific chat room
  Stream<QuerySnapshot> getMessage(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection("chatRooms") // Changed "chat_rooms" to "chatRooms" for consistency
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false) // Adjust order as needed
        .snapshots();
  }
}
