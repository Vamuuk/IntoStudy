import 'package:cloud_firestore/cloud_firestore.dart';
import 'chats_service.dart';

class DefaultChatsService {
  final ChatsService _chatsService = ChatsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user has any chats
  Future<bool> _userHasChats(String uid) async {
    final chats = await _firestore
        .collection('chats')
        .where('members', arrayContains: uid)
        .limit(1)
        .get();

    return chats.docs.isNotEmpty;
  }

  // Create default chats for new users
  Future<void> createDefaultChatsIfNeeded(String uid) async {
    try {
      // Check if user already has chats
      final hasChats = await _userHasChats(uid);
      if (hasChats) {
        return; // User already has chats, skip
      }

      // Create Web Technologies chat
      await _chatsService.createChat(
        name: 'Web Technologies',
        avatar: 'W',
        colorHex: '#4F46E5',
        members: [uid],
        isPublic: true,
      );

      // Create Mobile Development chat
      await _chatsService.createChat(
        name: 'Mobile Development',
        avatar: 'M',
        colorHex: '#10B981',
        members: [uid],
        isPublic: true,
      );
    } catch (e) {
      // Silently fail - don't block user flow
      // Error creating default chats: $e
    }
  }
}
