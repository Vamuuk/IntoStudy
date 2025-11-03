import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    required String university,
    required String bio,
    required String avatarLetter,
    required String avatarColor,
    required List<String> interests,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'university': university,
        'bio': bio,
        'avatarLetter': avatarLetter,
        'avatarColor': avatarColor,
        'interests': interests,
        'points': 0,
        'notesShared': 0,
        'questionsAsked': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Check if guest mode
  bool isGuestMode() {
    return _auth.currentUser == null;
  }

  // Sign in anonymously (guest mode)
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      rethrow;
    }
  }

  // Increment notes shared count
  Future<void> incrementNotesShared(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'notesShared': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Increment questions asked count
  Future<void> incrementQuestionsAsked(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'questionsAsked': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Add points to user
  Future<void> addPoints(String uid, int points) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'points': FieldValue.increment(points),
      });
    } catch (e) {
      rethrow;
    }
  }
}
