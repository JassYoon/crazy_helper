class DoneItem {
  final String id;
  String content;
  int importance; // 1-5
  int? hour; // null for checklist, 0-23 for timetable

  DoneItem({
    required this.id,
    this.content = '',
    this.importance = 1,
    this.hour,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'importance': importance,
        'hour': hour,
      };

  factory DoneItem.fromJson(Map<String, dynamic> json) {
    return DoneItem(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
      importance: (json['importance'] as int? ?? 1).clamp(1, 5),
      hour: json['hour'] as int?,
    );
  }

  DoneItem copyWith({
    String? id,
    String? content,
    int? importance,
    int? Function()? hour,
  }) {
    return DoneItem(
      id: id ?? this.id,
      content: content ?? this.content,
      importance: importance ?? this.importance,
      hour: hour != null ? hour() : this.hour,
    );
  }
}
