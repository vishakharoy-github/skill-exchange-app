import 'package:firebase_database/firebase_database.dart';

class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Send a message
  Future<void> sendMessage(
      String senderId,
      String receiverId,
      String message,
      ) async {
    final chatId = _getChatId(senderId, receiverId);

    // Generate a unique message ID
    final messageId = _database.child('chats').child(chatId).child('messages').push().key;

    // Add the message
    await _database.child('chats').child(chatId).child('messages').child(messageId!).set({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': ServerValue.timestamp,
      'read': false,
      'messageId': messageId,
    });

    // Update the chat with last message info
    await _database.child('chats').child(chatId).update({
      'lastMessage': message,
      'lastMessageTime': ServerValue.timestamp,
      'participants': {
        senderId: true,
        receiverId: true,
      },
    });
  }

  // Get messages for a chat
  Stream<DatabaseEvent> getMessages(String senderId, String receiverId) {
    final chatId = _getChatId(senderId, receiverId);
    return _database
        .child('chats')
        .child(chatId)
        .child('messages')
        .orderByChild('timestamp')
        .onValue;
  }

  // Get all chats for a user
  Stream<DatabaseEvent> getUserChats(String userId) {
    return _database
        .child('chats')
        .orderByChild('participants/$userId')
        .equalTo(true)
        .onValue;
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
      String senderId,
      String receiverId,
      ) async {
    final chatId = _getChatId(senderId, receiverId);

    final snapshot = await _database
        .child('chats')
        .child(chatId)
        .child('messages')
        .orderByChild('senderId')
        .equalTo(receiverId)
        .once();

    if (snapshot.snapshot.exists) {
      final Map<dynamic, dynamic> messages = snapshot.snapshot.value as Map;
      final updates = <String, dynamic>{};

      messages.forEach((messageId, messageData) {
        final message = messageData as Map<dynamic, dynamic>;
        if (message['read'] == false) {
          updates['chats/$chatId/messages/$messageId/read'] = true;
        }
      });

      if (updates.isNotEmpty) {
        await _database.update(updates);
      }
    }
  }

  // Helper method to generate consistent chat ID
  String _getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Helper method to convert DatabaseEvent to list of messages
  List<Map<String, dynamic>> convertMessagesSnapshot(DatabaseEvent event) {
    if (event.snapshot.value == null) return [];

    final Map<dynamic, dynamic> messagesMap = event.snapshot.value as Map;
    final List<Map<String, dynamic>> messages = [];

    messagesMap.forEach((messageId, messageData) {
      final Map<String, dynamic> message = Map<String, dynamic>.from(messageData as Map);
      message['id'] = messageId;
      messages.add(message);
    });

    // Sort by timestamp (newest first)
    messages.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

    return messages;
  }

  // Helper method to convert chats snapshot to list
  List<Map<String, dynamic>> convertChatsSnapshot(DatabaseEvent event) {
    if (event.snapshot.value == null) return [];

    final Map<dynamic, dynamic> chatsMap = event.snapshot.value as Map;
    final List<Map<String, dynamic>> chats = [];

    chatsMap.forEach((chatId, chatData) {
      final Map<String, dynamic> chat = Map<String, dynamic>.from(chatData as Map);
      chat['chatId'] = chatId;
      chats.add(chat);
    });

    // Sort by lastMessageTime (newest first)
    chats.sort((a, b) => (b['lastMessageTime'] ?? 0).compareTo(a['lastMessageTime'] ?? 0));

    return chats;
  }
}