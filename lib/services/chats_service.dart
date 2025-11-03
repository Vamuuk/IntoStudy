import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get chats collection reference
  CollectionReference get _chatsCollection => _firestore.collection('chats');

  // Generate random 5-character code
  String _generateChatCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excluding similar looking chars
    final random = Random();
    return List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Check if chat code already exists
  Future<bool> _isCodeUnique(String code) async {
    final snapshot = await _chatsCollection.where('chatCode', isEqualTo: code).limit(1).get();
    return snapshot.docs.isEmpty;
  }

  // Generate unique chat code
  Future<String> _generateUniqueChatCode() async {
    String code;
    bool isUnique = false;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      code = _generateChatCode();
      isUnique = await _isCodeUnique(code);
      attempts++;
    } while (!isUnique && attempts < maxAttempts);

    if (!isUnique) {
      // Fallback: add timestamp
      code = _generateChatCode();
    }

    return code;
  }

  // Create a new chat
  Future<String> createChat({
    required String name,
    required String avatar,
    required String colorHex,
    required List<String> members,
    bool isPublic = false,
  }) async {
    try {
      final now = DateTime.now();
      final chatCode = await _generateUniqueChatCode();

      final chatData = {
        'name': name,
        'avatar': avatar,
        'colorHex': colorHex,
        'members': members,
        'lastMessage': '',
        'lastMessageTime': Timestamp.fromDate(now),
        'createdAt': Timestamp.fromDate(now),
        'unreadCounts': {for (var uid in members) uid: 0},
        'isPublic': isPublic,
        'chatCode': chatCode,
      };

      final docRef = await _chatsCollection.add(chatData);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Join chat by code
  Future<Chat?> joinChatByCode(String code, String uid) async {
    try {
      final snapshot = await _chatsCollection
          .where('chatCode', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null; // Chat not found
      }

      final chatDoc = snapshot.docs.first;
      final chat = Chat.fromFirestore(chatDoc);

      // Check if already a member
      if (chat.members.contains(uid)) {
        return chat; // Already a member
      }

      // Check if chat is public
      if (!chat.isPublic) {
        throw Exception('This chat is private. You cannot join without an invitation.');
      }

      // Add user to members
      await addMember(chatDoc.id, uid);

      // Return updated chat
      final updatedDoc = await _chatsCollection.doc(chatDoc.id).get();
      return Chat.fromFirestore(updatedDoc);
    } catch (e) {
      rethrow;
    }
  }

  // Get chat by code (for validation)
  Future<Chat?> getChatByCode(String code) async {
    try {
      final snapshot = await _chatsCollection
          .where('chatCode', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return Chat.fromFirestore(snapshot.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  // Get chats for a user (real-time)
  Stream<List<Chat>> getUserChats(String uid) {
    return _chatsCollection
        .where('members', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();
    });
  }

  // Get single chat by ID
  Future<Chat?> getChatById(String chatId) async {
    try {
      final doc = await _chatsCollection.doc(chatId).get();
      if (doc.exists) {
        return Chat.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Send a message
  Future<String> sendMessage({
    required String chatId,
    required String senderUid,
    required String senderName,
    required String text,
  }) async {
    try {
      final now = DateTime.now();
      final messageData = {
        'chatId': chatId,
        'senderUid': senderUid,
        'senderName': senderName,
        'text': text,
        'createdAt': Timestamp.fromDate(now),
        'readBy': {senderUid: true}, // Sender has read their own message
      };

      // Add message to subcollection
      final docRef = await _chatsCollection
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // Get chat members
      final chatDoc = await _chatsCollection.doc(chatId).get();
      final chatData = chatDoc.data() as Map<String, dynamic>;
      final members = List<String>.from(chatData['members'] ?? []);
      final currentUnreadCounts = Map<String, int>.from(chatData['unreadCounts'] ?? {});

      // Increment unread count for all members except sender
      for (var uid in members) {
        if (uid != senderUid) {
          currentUnreadCounts[uid] = (currentUnreadCounts[uid] ?? 0) + 1;
        }
      }

      // Update chat with last message
      await _chatsCollection.doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': Timestamp.fromDate(now),
        'unreadCounts': currentUnreadCounts,
      });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get messages for a chat (real-time)
  Stream<List<Message>> getMessages(String chatId) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String uid) async {
    try {
      // Reset unread count for this user
      final chatDoc = await _chatsCollection.doc(chatId).get();
      final chatData = chatDoc.data() as Map<String, dynamic>;
      final unreadCounts = Map<String, int>.from(chatData['unreadCounts'] ?? {});
      unreadCounts[uid] = 0;

      await _chatsCollection.doc(chatId).update({
        'unreadCounts': unreadCounts,
      });

      // Mark all messages as read by this user
      final messagesSnapshot = await _chatsCollection
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        final messageData = doc.data();
        final readBy = Map<String, bool>.from(messageData['readBy'] ?? {});
        if (!readBy.containsKey(uid) || !readBy[uid]!) {
          readBy[uid] = true;
          await doc.reference.update({'readBy': readBy});
        }
      }
    } catch (e) {
      // Silently fail - don't block user experience
    }
  }

  // Update chat details
  Future<void> updateChat({
    required String chatId,
    String? name,
    String? avatar,
    String? colorHex,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (avatar != null) updateData['avatar'] = avatar;
      if (colorHex != null) updateData['colorHex'] = colorHex;

      if (updateData.isNotEmpty) {
        await _chatsCollection.doc(chatId).update(updateData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add member to chat
  Future<void> addMember(String chatId, String uid) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'members': FieldValue.arrayUnion([uid]),
        'unreadCounts.$uid': 0,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Remove member from chat
  Future<void> removeMember(String chatId, String uid) async {
    try {
      final chatDoc = await _chatsCollection.doc(chatId).get();
      final chatData = chatDoc.data() as Map<String, dynamic>;
      final unreadCounts = Map<String, int>.from(chatData['unreadCounts'] ?? {});
      unreadCounts.remove(uid);

      await _chatsCollection.doc(chatId).update({
        'members': FieldValue.arrayRemove([uid]),
        'unreadCounts': unreadCounts,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages first
      final messagesSnapshot = await _chatsCollection
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the chat
      await _chatsCollection.doc(chatId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get unread message count for user
  Future<int> getTotalUnreadCount(String uid) async {
    try {
      final snapshot = await _chatsCollection
          .where('members', arrayContains: uid)
          .get();

      int totalUnread = 0;
      for (var doc in snapshot.docs) {
        final chatData = doc.data() as Map<String, dynamic>;
        final unreadCounts = Map<String, int>.from(chatData['unreadCounts'] ?? {});
        totalUnread += unreadCounts[uid] ?? 0;
      }

      return totalUnread;
    } catch (e) {
      return 0;
    }
  }
}
