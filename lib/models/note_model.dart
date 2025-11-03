import 'package:cloud_firestore/cloud_firestore.dart';

class NoteAttachment {
  final String name;
  final String url;
  final String type; // 'file', 'link', 'presentation'

  NoteAttachment({
    required this.name,
    required this.url,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'type': type,
  };

  factory NoteAttachment.fromJson(Map<String, dynamic> json) => NoteAttachment(
    name: json['name'] ?? '',
    url: json['url'] ?? '',
    type: json['type'] ?? 'file',
  );
}

class Note {
  final String id;
  final String title;
  final String subject;
  final String description;
  final String content;
  final String creatorUid;
  final String creatorName;
  final int downloads;
  final double rating;
  final List<NoteAttachment> attachments;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.content,
    required this.creatorUid,
    required this.creatorName,
    this.downloads = 0,
    this.rating = 0.0,
    this.attachments = const [],
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Note to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
      'description': description,
      'content': content,
      'creatorUid': creatorUid,
      'creatorName': creatorName,
      'downloads': downloads,
      'rating': rating,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create Note from Firestore document
  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final attachmentsList = (data['attachments'] as List?)?.map((a) =>
      NoteAttachment.fromJson(a as Map<String, dynamic>)
    ).toList() ?? [];

    final tagsList = (data['tags'] as List?)?.cast<String>() ?? [];

    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      creatorUid: data['creatorUid'] ?? '',
      creatorName: data['creatorName'] ?? 'Unknown',
      downloads: data['downloads'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      attachments: attachmentsList,
      tags: tagsList,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create a copy with updated fields
  Note copyWith({
    String? id,
    String? title,
    String? subject,
    String? description,
    String? content,
    String? creatorUid,
    String? creatorName,
    int? downloads,
    double? rating,
    List<NoteAttachment>? attachments,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      content: content ?? this.content,
      creatorUid: creatorUid ?? this.creatorUid,
      creatorName: creatorName ?? this.creatorName,
      downloads: downloads ?? this.downloads,
      rating: rating ?? this.rating,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
