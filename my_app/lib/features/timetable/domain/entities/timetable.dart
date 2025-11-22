import 'package:cloud_firestore/cloud_firestore.dart';

class MyTimetable {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime? updatedAt;

  const MyTimetable({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.updatedAt,
  });

  factory MyTimetable.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['updatedAt'];
    DateTime? updated;
    if (ts is Timestamp) {
      updated = ts.toDate();
    }
    return MyTimetable(
      id: id,
      title: (data['title'] ?? 'My Timetable') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      updatedAt: updated,
    );
  }
}
