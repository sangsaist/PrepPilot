class Activity {
  final int? activityId;
  final String type; // hackathon, cert, course
  final String name;
  final String platform;
  final DateTime deadline;
  final int progress; // 0-100
  final String? notes;

  Activity({
    this.activityId,
    required this.type,
    required this.name,
    required this.platform,
    required this.deadline,
    required this.progress,
    this.notes,
  });

  bool get isOverdue => deadline.isBefore(DateTime.now()) && progress < 100;

  Map<String, dynamic> toMap() {
    return {
      'activity_id': activityId,
      'type': type,
      'name': name,
      'platform': platform,
      'deadline': deadline.toIso8601String(),
      'progress': progress,
      'notes': notes,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      activityId: map['activity_id'] as int?,
      type: map['type'] as String,
      name: map['name'] as String,
      platform: map['platform'] as String,
      deadline: DateTime.parse(map['deadline'] as String),
      progress: map['progress'] as int,
      notes: map['notes'] as String?,
    );
  }

  Activity copyWith({
    int? activityId,
    String? type,
    String? name,
    String? platform,
    DateTime? deadline,
    int? progress,
    String? notes,
  }) {
    return Activity(
      activityId: activityId ?? this.activityId,
      type: type ?? this.type,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      deadline: deadline ?? this.deadline,
      progress: progress ?? this.progress,
      notes: notes ?? this.notes,
    );
  }
}
