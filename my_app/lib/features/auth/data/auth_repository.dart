import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/faculty.dart';
import '../domain/entities/student_signup.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  // ---------- Faculties / courses ----------

  Future<List<Faculty>> fetchFaculties() async {
    final snap = await _db.collection('faculties').orderBy('name').get();
    return snap.docs
        .map((d) => Faculty.fromMap(d.data()))
        .toList();
  }

  // ---------- Auth ----------

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpStudent({
    required String email,
    required String password,
    required StudentSignupData data,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'User creation failed.',
      );
    }

    final uid = user.uid;

    // minimal "users" collection
    await _db.collection('users').doc(uid).set(
          data.toUserDoc(uid),
        );

    // detailed "students" collection
    await _db.collection('students').doc(uid).set(
          data.toStudentDoc(uid),
        );

    return cred;
  }

  Future<void> updateLastLogin(String uid) async {
    final payload = {
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('users').doc(uid).set(
          payload,
          SetOptions(merge: true),
        );

    await _db.collection('students').doc(uid).set(
          payload,
          SetOptions(merge: true),
        );
  }
}
