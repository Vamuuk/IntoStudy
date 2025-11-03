import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String chatId;
  final String senderUid;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final Map<String, bool> readBy; // uid: isRead

  Message({
    required this.id,
    required this.chatId,
    required this.senderUid,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.readBy = const {},
  });

  bool isReadBy(String uid) {
    return readBy[uid] ?? false;
  }

  // Convert Message to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'senderUid': senderUid,
      'senderName': senderName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'readBy': readBy,
    };
  }

  // Create Message from Firestore document
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderUid: data['senderUid'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: Map<String, bool>.from(data['readBy'] ?? {}),
    );
  }

  // Create a copy with updated fields
  Message copyWith({
    String? id,
    String? chatId,
    String? senderUid,
    String? senderName,
    String? text,
    DateTime? createdAt,
    Map<String, bool>? readBy,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderUid: senderUid ?? this.senderUid,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      readBy: readBy ?? this.readBy,
    );
  }
}
