import 'package:cloud_firestore/cloud_firestore.dart';

class CampusEvent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime startTime;
  final DateTime? endTime;

  const CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.startTime,
    this.endTime,
  });

  factory CampusEvent.fromMap(String id, Map<String, dynamic> data) {
    final startTs = data['startTime'] as Timestamp;
    final endField = data['endTime'];

    DateTime? end;
    if (endField is Timestamp) {
      end = endField.toDate();
    }

    return CampusEvent(
      id: id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      location: (data['location'] ?? '') as String,
      startTime: startTs.toDate(),
      endTime: end,
    );
  }
}
