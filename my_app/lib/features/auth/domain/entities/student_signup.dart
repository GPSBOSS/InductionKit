import 'package:cloud_firestore/cloud_firestore.dart';

class StudentSignupData {
  final String firstName;
  final String surname;
  final String otherNames;
  final String studentId;
  final String email;
  final String facultyName;
  final String course;

  StudentSignupData({
    required this.firstName,
    required this.surname,
    required this.otherNames,
    required this.studentId,
    required this.email,
    required this.facultyName,
    required this.course,
  });

  Map<String, dynamic> toStudentDoc(String uid) {
    return {
      'uid': uid,
      'firstName': firstName,
      'surname': surname,
      'otherNames': otherNames,
      'email': email,
      'studentId': studentId,
      'facultyName': facultyName,
      'course': course,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUserDoc(String uid) {
    return {
      'uid': uid,
      'email': email,
      'status': 'active',
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
  }
}
