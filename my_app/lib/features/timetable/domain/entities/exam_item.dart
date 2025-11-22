import 'package:cloud_firestore/cloud_firestore.dart';

class ExamItem {
  final String id;
  final String title;
  final String type;       // "exam", "deadline", etc.
  final String module;
  final String venue;
  final String notes;
  final DateTime date;

  const ExamItem({
    required this.id,
    required this.title,
    required this.type,
    required this.module,
    required this.venue,
    required this.notes,
    required this.date,
  });

  factory ExamItem.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['date'] as Timestamp;
    return ExamItem(
      id: id,
      title: (data['title'] ?? '') as String,
      type: (data['type'] ?? 'exam') as String,
      module: (data['module'] ?? '') as String,
      venue: (data['venue'] ?? '') as String,
      notes: (data['notes'] ?? '') as String,
      date: ts.toDate(),
    );
  }
}
