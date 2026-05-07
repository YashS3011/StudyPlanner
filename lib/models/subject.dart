class Subject {
  final String id;
  final String name;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
