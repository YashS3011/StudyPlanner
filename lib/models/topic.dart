enum TopicStatus {
  notStarted,
  inProgress,
  completed;

  String get value {
    switch (this) {
      case TopicStatus.notStarted:
        return 'not_started';
      case TopicStatus.inProgress:
        return 'in_progress';
      case TopicStatus.completed:
        return 'completed';
    }
  }

  static TopicStatus fromString(String status) {
    switch (status) {
      case 'in_progress':
        return TopicStatus.inProgress;
      case 'completed':
        return TopicStatus.completed;
      default:
        return TopicStatus.notStarted;
    }
  }

  String get displayName {
    switch (this) {
      case TopicStatus.notStarted:
        return 'Not Started';
      case TopicStatus.inProgress:
        return 'In Progress';
      case TopicStatus.completed:
        return 'Completed';
    }
  }
}

class Topic {
  final String id;
  final String subjectId;
  final String name;
  final int estimatedMinutes;
  final TopicStatus status;
  final DateTime createdAt;

  Topic({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.estimatedMinutes,
    required this.status,
    required this.createdAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      subjectId: json['subject_id'],
      name: json['name'],
      estimatedMinutes: json['estimated_minutes'] ?? 30,
      status: TopicStatus.fromString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'name': name,
      'estimated_minutes': estimatedMinutes,
      'status': status.value,
    };
  }

  Topic copyWith({
    TopicStatus? status,
  }) {
    return Topic(
      id: id,
      subjectId: subjectId,
      name: name,
      estimatedMinutes: estimatedMinutes,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
