import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> isUsernameAvailable(String username) async {
    final snapshot = await _db
        .collection('users')
        .where('username', isEqualTo: username.trim())
        .get();
    return snapshot.docs.isEmpty;
  }

  Future<UserCredential> signUpWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

 Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
  Future<void> saveUserData(String uid, String username, String email) async {
    await _db.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'createdAt': Timestamp.now(),
    });
  }

  Future<DateTime> getAccountCreationDate(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final ts = doc['createdAt'] as Timestamp;
    return ts.toDate();
  }
  Future<String?> getCurrentUsername() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return null;

  final doc = await _db.collection('users').doc(uid).get();
  return doc.data()?['username'] ?? 'User';
}


  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          return 'Incorrect email or password';
        case 'invalid-email':
          return 'Please enter a valid email';
        default:
          return 'Login failed. Please try again';
      }
    } catch (_) {
      return 'Login failed. Please try again';
    }
  }
}
