import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String title;
  final String subject;
  final String difficulty; // Easy, Medium, Hard
  final int points;
  final String status; // open, answered, closed
  final String creatorUid;
  final String creatorName;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int answersCount;

  Question({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.points,
    this.status = 'open',
    required this.creatorUid,
    required this.creatorName,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.answersCount = 0,
  });

  // Convert Question to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
      'difficulty': difficulty,
      'points': points,
      'status': status,
      'creatorUid': creatorUid,
      'creatorName': creatorName,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'answersCount': answersCount,
    };
  }

  // Create Question from Firestore document
  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      difficulty: data['difficulty'] ?? 'Medium',
      points: data['points'] ?? 15,
      status: data['status'] ?? 'open',
      creatorUid: data['creatorUid'] ?? '',
      creatorName: data['creatorName'] ?? 'Unknown',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answersCount: data['answersCount'] ?? 0,
    );
  }

  // Create a copy with updated fields
  Question copyWith({
    String? id,
    String? title,
    String? subject,
    String? difficulty,
    int? points,
    String? status,
    String? creatorUid,
    String? creatorName,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? answersCount,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
      status: status ?? this.status,
      creatorUid: creatorUid ?? this.creatorUid,
      creatorName: creatorName ?? this.creatorName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answersCount: answersCount ?? this.answersCount,
    );
  }
}

class Answer {
  final String id;
  final String questionId;
  final String text;
  final String authorUid;
  final String authorName;
  final bool isAccepted;
  final DateTime createdAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.text,
    required this.authorUid,
    required this.authorName,
    this.isAccepted = false,
    required this.createdAt,
  });

  // Convert Answer to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'text': text,
      'authorUid': authorUid,
      'authorName': authorName,
      'isAccepted': isAccepted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create Answer from Firestore document
  factory Answer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Answer(
      id: doc.id,
      questionId: data['questionId'] ?? '',
      text: data['text'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      isAccepted: data['isAccepted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
