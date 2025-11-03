import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String university;
  final String bio;
  final String avatarLetter;
  final String avatarColor;
  final int notesShared;
  final int questionsAsked;
  final int points;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.university,
    this.bio = '',
    this.avatarLetter = 'A',
    this.avatarColor = '#4F46E5',
    this.notesShared = 0,
    this.questionsAsked = 0,
    this.points = 0,
    required this.createdAt,
  });

  // Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      university: data['university'] ?? '',
      bio: data['bio'] ?? '',
      avatarLetter: data['avatarLetter'] ?? 'A',
      avatarColor: data['avatarColor'] ?? '#4F46E5',
      notesShared: data['notesShared'] ?? 0,
      questionsAsked: data['questionsAsked'] ?? 0,
      points: data['points'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from map (for getUserProfile)
  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      university: data['university'] ?? '',
      bio: data['bio'] ?? '',
      avatarLetter: data['avatarLetter'] ?? 'A',
      avatarColor: data['avatarColor'] ?? '#4F46E5',
      notesShared: data['notesShared'] ?? 0,
      questionsAsked: data['questionsAsked'] ?? 0,
      points: data['points'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'university': university,
      'bio': bio,
      'avatarLetter': avatarLetter,
      'avatarColor': avatarColor,
      'notesShared': notesShared,
      'questionsAsked': questionsAsked,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create copy with modified fields
  UserProfile copyWith({
    String? email,
    String? name,
    String? university,
    String? bio,
    String? avatarLetter,
    String? avatarColor,
    int? notesShared,
    int? questionsAsked,
    int? points,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      university: university ?? this.university,
      bio: bio ?? this.bio,
      avatarLetter: avatarLetter ?? this.avatarLetter,
      avatarColor: avatarColor ?? this.avatarColor,
      notesShared: notesShared ?? this.notesShared,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      points: points ?? this.points,
      createdAt: createdAt,
    );
  }
}

// List of universities for dropdown selection
class University {
  static const List<String> list = [
    'Woosong University',
    'Seoul National University',
    'Korea University',
    'Yonsei University',
    'KAIST',
    'POSTECH',
    'Sungkyunkwan University',
    'Hanyang University',
    'Ewha Womans University',
    'Kyung Hee University',
    'Other',
  ];
}
