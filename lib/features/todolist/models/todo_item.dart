class TodoItem {
  final String id;
  String content;
  int importance; // 0-3
  bool completed;
  int? hour; // null for checklist, 0-23 for timetable

  TodoItem({
    required this.id,
    this.content = '',
    this.importance = 0,
    this.completed = false,
    this.hour,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'importance': importance,
        'completed': completed,
        'hour': hour,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
      importance: json['importance'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      hour: json['hour'] as int?,
    );
  }

  TodoItem copyWith({
    String? id,
    String? content,
    int? importance,
    bool? completed,
    int? Function()? hour,
  }) {
    return TodoItem(
      id: id ?? this.id,
      content: content ?? this.content,
      importance: importance ?? this.importance,
      completed: completed ?? this.completed,
      hour: hour != null ? hour() : this.hour,
    );
  }
}
