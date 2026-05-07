class StudySession {
  final String id;
  final String subjectId;
  final String topicId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final DateTime createdAt;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.createdAt,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      subjectId: json['subject_id'],
      topicId: json['topic_id'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      durationMinutes: json['duration_minutes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'topic_id': topicId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
    };
  }
}
