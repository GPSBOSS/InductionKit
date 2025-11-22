import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/campus_facilities.dart';

class CampusFacilitiesRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<CampusFacilities>> fetchAllFacilities() async {
    final snap = await _db.collection('campus_facilities').get();

    return snap.docs
        .map((d) => CampusFacilities.fromMap(d.id, d.data()))
        .toList();
  }
}
