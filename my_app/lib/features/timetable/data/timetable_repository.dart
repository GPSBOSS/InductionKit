import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/timetable.dart';
import '../domain/entities/exam_item.dart';
import '../domain/entities/campus_event.dart';

class TimetableRepository {
  final _db = FirebaseFirestore.instance;

  Future<MyTimetable?> getTimetableForUser(String uid) async {
    // 1) Get student profile
    final studentDoc =
        await _db.collection('students').doc(uid).get();

    if (!studentDoc.exists) return null;

    final data = studentDoc.data()!;
    final course = (data['courseCode'] ?? '') as String;
    final year = (data['yearOfStudy'] ?? 0) as int;

    if (course.isEmpty || year == 0) {
      return null;
    }

    // 2) Find timetable for that course + year
    final snap = await _db
        .collection('timetables')
        .where('courseCode', isEqualTo: course)
        .where('yearOfStudy', isEqualTo: year)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final doc = snap.docs.first;
    return MyTimetable.fromMap(doc.id, doc.data());
  }

  Stream<List<ExamItem>> watchExams() {
    return _db
        .collection('exam_dates')
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ExamItem.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<List<CampusEvent>> watchUpcomingEvents() {
    return _db
        .collection('events')
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CampusEvent.fromMap(d.id, d.data()))
            .toList());
  }
}
