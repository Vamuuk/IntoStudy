import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat {
  final String id;
  final String name;
  final String avatar;
  final String colorHex;
  final List<String> members; // UIDs of members
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;
  final Map<String, int> unreadCounts; // uid: unread count
  final bool isPublic; // true = public, false = private
  final String chatCode; // 5-character code for joining

  Chat({
    required this.id,
    required this.name,
    required this.avatar,
    required this.colorHex,
    required this.members,
    this.lastMessage = '',
    required this.lastMessageTime,
    required this.createdAt,
    this.unreadCounts = const {},
    this.isPublic = false,
    required this.chatCode,
  });

  Color get color {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4F46E5);
    }
  }

  int getUnreadCount(String uid) {
    return unreadCounts[uid] ?? 0;
  }

  // Convert Chat to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
      'colorHex': colorHex,
      'members': members,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'unreadCounts': unreadCounts,
      'isPublic': isPublic,
      'chatCode': chatCode,
    };
  }

  // Create Chat from Firestore document
  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      name: data['name'] ?? 'Chat',
      avatar: data['avatar'] ?? 'C',
      colorHex: data['colorHex'] ?? '#4F46E5',
      members: List<String>.from(data['members'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      isPublic: data['isPublic'] ?? false,
      chatCode: data['chatCode'] ?? '',
    );
  }

  // Create a copy with updated fields
  Chat copyWith({
    String? id,
    String? name,
    String? avatar,
    String? colorHex,
    List<String>? members,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    Map<String, int>? unreadCounts,
    bool? isPublic,
    String? chatCode,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      colorHex: colorHex ?? this.colorHex,
      members: members ?? this.members,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      isPublic: isPublic ?? this.isPublic,
      chatCode: chatCode ?? this.chatCode,
    );
  }
}
