class Project {
  final int? projectId;
  final String name;
  final String description;
  final String status; // active, completed, paused
  final String? repoUrl;

  Project({
    this.projectId,
    required this.name,
    required this.description,
    required this.status,
    this.repoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'name': name,
      'description': description,
      'status': status,
      'repo_url': repoUrl,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      projectId: map['project_id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      repoUrl: map['repo_url'] as String?,
    );
  }

  Project copyWith({
    int? projectId,
    String? name,
    String? description,
    String? status,
    String? repoUrl,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      repoUrl: repoUrl ?? this.repoUrl,
    );
  }
}
