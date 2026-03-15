class FileIndex {
  final int? fileId;
  final String linkedType; // activity, project, task
  final int linkedId;
  final String label;
  final String localUri;
  final String fileType; // image, pdf, doc, other
  final String createdAt;

  FileIndex({
    this.fileId,
    required this.linkedType,
    required this.linkedId,
    required this.label,
    required this.localUri,
    required this.fileType,
    required this.createdAt,
  });

  String get fileName => localUri.split('/').last;

  Map<String, dynamic> toMap() {
    return {
      'file_id': fileId,
      'linked_type': linkedType,
      'linked_id': linkedId,
      'label': label,
      'local_uri': localUri,
      'file_type': fileType,
      'created_at': createdAt,
    };
  }

  factory FileIndex.fromMap(Map<String, dynamic> map) {
    return FileIndex(
      fileId: map['file_id'] as int?,
      linkedType: map['linked_type'] as String,
      linkedId: map['linked_id'] as int,
      label: map['label'] as String,
      localUri: map['local_uri'] as String,
      fileType: map['file_type'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  FileIndex copyWith({
    int? fileId,
    String? linkedType,
    int? linkedId,
    String? label,
    String? localUri,
    String? fileType,
    String? createdAt,
  }) {
    return FileIndex(
      fileId: fileId ?? this.fileId,
      linkedType: linkedType ?? this.linkedType,
      linkedId: linkedId ?? this.linkedId,
      label: label ?? this.label,
      localUri: localUri ?? this.localUri,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
