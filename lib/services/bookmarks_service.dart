import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Bookmark a note
  Future<void> bookmarkNote(String userId, String noteId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarkedNotes')
          .doc(noteId)
          .set({
        'noteId': noteId,
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Remove note bookmark
  Future<void> unbookmarkNote(String userId, String noteId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarkedNotes')
          .doc(noteId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Check if note is bookmarked
  Future<bool> isNoteBookmarked(String userId, String noteId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarkedNotes')
          .doc(noteId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get all bookmarked note IDs
  Stream<List<String>> getBookmarkedNoteIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarkedNotes')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // Bookmark a question
  Future<void> bookmarkQuestion(String userId, String questionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarkedQuestions')
          .doc(questionId)
          .set({
        'questionId': questionId,
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Remove question bookmark
  Future<void> unbookmarkQuestion(String userId, String questionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarkedQuestions')
          .doc(questionId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Check if question is bookmarked
  Future<bool> isQuestionBookmarked(String userId, String questionId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarkedQuestions')
          .doc(questionId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get all bookmarked question IDs
  Stream<List<String>> getBookmarkedQuestionIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarkedQuestions')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
