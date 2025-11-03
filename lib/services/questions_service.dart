import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';

class QuestionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get questions collection reference
  CollectionReference get _questionsCollection => _firestore.collection('questions');

  // Create a new question
  Future<String> createQuestion({
    required String title,
    required String subject,
    required String difficulty,
    required int points,
    required String creatorUid,
    required String creatorName,
    String? description,
  }) async {
    try {
      final now = DateTime.now();
      final questionData = {
        'title': title,
        'subject': subject,
        'difficulty': difficulty,
        'points': points,
        'status': 'open',
        'creatorUid': creatorUid,
        'creatorName': creatorName,
        'description': description ?? '',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'answersCount': 0,
      };

      final docRef = await _questionsCollection.add(questionData);

      // Update user statistics
      await _updateUserStats(creatorUid, incrementQuestions: true);

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all questions (public feed)
  Stream<List<Question>> getAllQuestions() {
    return _questionsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
    });
  }

  // Get questions by user UID
  Stream<List<Question>> getUserQuestions(String uid) {
    return _questionsCollection
        .where('creatorUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
    });
  }

  // Get questions by subject
  Stream<List<Question>> getQuestionsBySubject(String subject) {
    return _questionsCollection
        .where('subject', isEqualTo: subject)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
    });
  }

  // Get questions by status
  Stream<List<Question>> getQuestionsByStatus(String status) {
    return _questionsCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
    });
  }

  // Get single question by ID
  Future<Question?> getQuestionById(String questionId) async {
    try {
      final doc = await _questionsCollection.doc(questionId).get();
      if (doc.exists) {
        return Question.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update question
  Future<void> updateQuestion({
    required String questionId,
    String? title,
    String? subject,
    String? difficulty,
    int? points,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updateData['title'] = title;
      if (subject != null) updateData['subject'] = subject;
      if (difficulty != null) updateData['difficulty'] = difficulty;
      if (points != null) updateData['points'] = points;
      if (status != null) updateData['status'] = status;

      await _questionsCollection.doc(questionId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  // Delete question
  Future<void> deleteQuestion(String questionId, String creatorUid) async {
    try {
      // Delete all answers first
      final answersSnapshot = await _questionsCollection
          .doc(questionId)
          .collection('answers')
          .get();

      for (var doc in answersSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the question
      await _questionsCollection.doc(questionId).delete();

      // Update user statistics
      await _updateUserStats(creatorUid, incrementQuestions: false);
    } catch (e) {
      rethrow;
    }
  }

  // Add answer to question
  Future<String> addAnswer({
    required String questionId,
    required String text,
    required String authorUid,
    required String authorName,
  }) async {
    try {
      final now = DateTime.now();
      final answerData = {
        'questionId': questionId,
        'text': text,
        'authorUid': authorUid,
        'authorName': authorName,
        'isAccepted': false,
        'createdAt': Timestamp.fromDate(now),
      };

      final docRef = await _questionsCollection
          .doc(questionId)
          .collection('answers')
          .add(answerData);

      // Increment answers count
      await _questionsCollection.doc(questionId).update({
        'answersCount': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(now),
      });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get answers for a question
  Stream<List<Answer>> getAnswers(String questionId) {
    return _questionsCollection
        .doc(questionId)
        .collection('answers')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Answer.fromFirestore(doc)).toList();
    });
  }

  // Accept an answer
  Future<void> acceptAnswer(String questionId, String answerId) async {
    try {
      // Unaccept all previous answers
      final answersSnapshot = await _questionsCollection
          .doc(questionId)
          .collection('answers')
          .where('isAccepted', isEqualTo: true)
          .get();

      for (var doc in answersSnapshot.docs) {
        await doc.reference.update({'isAccepted': false});
      }

      // Accept the new answer
      await _questionsCollection
          .doc(questionId)
          .collection('answers')
          .doc(answerId)
          .update({'isAccepted': true});

      // Update question status to answered
      await _questionsCollection.doc(questionId).update({
        'status': 'answered',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Close question
  Future<void> closeQuestion(String questionId) async {
    try {
      await _questionsCollection.doc(questionId).update({
        'status': 'closed',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user's question count
  Future<int> getUserQuestionCount(String uid) async {
    try {
      final snapshot = await _questionsCollection
          .where('creatorUid', isEqualTo: uid)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Private: Update user statistics
  Future<void> _updateUserStats(String uid, {required bool incrementQuestions}) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'questionsAsked': FieldValue.increment(incrementQuestions ? 1 : -1),
      });
    } catch (e) {
      // Silently fail - don't block the main operation
    }
  }
}
