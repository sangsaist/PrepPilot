class Task {
  final int? taskId;
  final String title;
  final DateTime date;
  final String? time;
  final int priority; // 1: Low, 2: Medium, 3: High
  final String status; // pending, in_progress, completed
  final String? linkedType;
  final int? linkedId;

  Task({
    this.taskId,
    required this.title,
    required this.date,
    this.time,
    required this.priority,
    required this.status,
    this.linkedType,
    this.linkedId,
  });

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'priority': priority,
      'status': status,
      'linked_type': linkedType,
      'linked_id': linkedId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['task_id'] as int?,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String?,
      priority: map['priority'] as int,
      status: map['status'] as String,
      linkedType: map['linked_type'] as String?,
      linkedId: map['linked_id'] as int?,
    );
  }

  Task copyWith({
    int? taskId,
    String? title,
    DateTime? date,
    String? time,
    int? priority,
    String? status,
    String? linkedType,
    int? linkedId,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      linkedType: linkedType ?? this.linkedType,
      linkedId: linkedId ?? this.linkedId,
    );
  }
}
