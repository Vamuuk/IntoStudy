import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get notes collection reference
  CollectionReference get _notesCollection => _firestore.collection('notes');

  // Create a new note
  Future<String> createNote({
    required String title,
    required String subject,
    required String description,
    required String content,
    required String creatorUid,
    required String creatorName,
    List<NoteAttachment>? attachments,
    List<String>? tags,
  }) async {
    try {
      final now = DateTime.now();
      final noteData = {
        'title': title,
        'subject': subject,
        'description': description,
        'content': content,
        'creatorUid': creatorUid,
        'creatorName': creatorName,
        'downloads': 0,
        'rating': 0.0,
        'attachments': attachments?.map((a) => a.toJson()).toList() ?? [],
        'tags': tags ?? [],
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _notesCollection.add(noteData);

      // Update user statistics
      await _updateUserStats(creatorUid, incrementNotes: true);

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all notes (public feed)
  Stream<List<Note>> getAllNotes() {
    return _notesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  // Get notes by user UID
  Stream<List<Note>> getUserNotes(String uid) {
    return _notesCollection
        .where('creatorUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  // Get notes by subject
  Stream<List<Note>> getNotesBySubject(String subject) {
    return _notesCollection
        .where('subject', isEqualTo: subject)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  // Get single note by ID
  Future<Note?> getNoteById(String noteId) async {
    try {
      final doc = await _notesCollection.doc(noteId).get();
      if (doc.exists) {
        return Note.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update note
  Future<void> updateNote({
    required String noteId,
    String? title,
    String? subject,
    String? description,
    String? content,
    List<NoteAttachment>? attachments,
    List<String>? tags,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updateData['title'] = title;
      if (subject != null) updateData['subject'] = subject;
      if (description != null) updateData['description'] = description;
      if (content != null) updateData['content'] = content;
      if (attachments != null) updateData['attachments'] = attachments.map((a) => a.toJson()).toList();
      if (tags != null) updateData['tags'] = tags;

      await _notesCollection.doc(noteId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  // Delete note
  Future<void> deleteNote(String noteId, String creatorUid) async {
    try {
      await _notesCollection.doc(noteId).delete();

      // Update user statistics
      await _updateUserStats(creatorUid, incrementNotes: false);
    } catch (e) {
      rethrow;
    }
  }

  // Increment download count
  Future<void> incrementDownloads(String noteId) async {
    try {
      await _notesCollection.doc(noteId).update({
        'downloads': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update rating
  Future<void> updateRating(String noteId, double newRating) async {
    try {
      await _notesCollection.doc(noteId).update({
        'rating': newRating,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Rate note (calculates average)
  Future<void> rateNote(String noteId, double userRating) async {
    try {
      final doc = await _notesCollection.doc(noteId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final currentRating = (data['rating'] ?? 0.0).toDouble();
        final ratingCount = (data['ratingCount'] ?? 0) + 1;
        final newRating = ((currentRating * (ratingCount - 1)) + userRating) / ratingCount;

        await _notesCollection.doc(noteId).update({
          'rating': newRating,
          'ratingCount': ratingCount,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Search notes by title or description
  Stream<List<Note>> searchNotes(String query) {
    return _notesCollection
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  // Get user's note count
  Future<int> getUserNoteCount(String uid) async {
    try {
      final snapshot = await _notesCollection
          .where('creatorUid', isEqualTo: uid)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Private: Update user statistics
  Future<void> _updateUserStats(String uid, {required bool incrementNotes}) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'notesShared': FieldValue.increment(incrementNotes ? 1 : -1),
      });
    } catch (e) {
      // Silently fail - don't block the main operation
    }
  }
}
