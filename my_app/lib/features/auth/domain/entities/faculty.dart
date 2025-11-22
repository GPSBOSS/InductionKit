class Faculty {
  final String name;
  final List<String> courses;

  const Faculty({
    required this.name,
    required this.courses,
  });

  factory Faculty.fromMap(Map<String, dynamic> data) {
    return Faculty(
      name: (data['name'] ?? '') as String,
      courses: (data['courses'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
