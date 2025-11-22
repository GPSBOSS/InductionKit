class CampusFacilities {
  final String id;
  final String name;
  final String description;
  final String category;      // e.g. 'food', 'study', 'admin', 'sports', 'parking', 'lab', 'other'
  final double lat;
  final double lng;
  final String openingHours;
  final String? imageName;

  const CampusFacilities({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.lat,
    required this.lng,
    required this.openingHours,
    this.imageName,
  });

  factory CampusFacilities.fromMap(String id, Map<String, dynamic> m) {
    final latRaw = m['lat'];
    final lngRaw = m['lon'];

    if (latRaw == null || lngRaw == null) {
      throw StateError('Document "$id" is missing lat or lng');
    }

    return CampusFacilities(
      id: id,
      name: (m['name'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      category: (m['category'] ?? 'other') as String,
      lat: (latRaw as num).toDouble(),
      lng: (lngRaw as num).toDouble(),
      openingHours: (m['openingHours'] ?? 'Not specified') as String,
      imageName: m['imageName'] as String?,
    );
  }
}
