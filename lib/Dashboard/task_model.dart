class Task {
  final String id;
  final String title;
  final bool completed;
  final String userId;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.completed,
    required this.userId,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] as String,
      completed: json['completed'] as bool,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    String? userId,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
