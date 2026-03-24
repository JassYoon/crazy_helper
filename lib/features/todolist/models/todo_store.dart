import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_item.dart';
import 'todo_list_type.dart';

class TodoStore extends ChangeNotifier {
  static const _checklistKey = 'todo_checklist';
  static const _timetableKey = 'todo_timetable';
  static const _autoResetKey = 'todo_autoReset';
  static const _lastDateKey = 'todo_lastDate';

  List<TodoItem> _checklistItems = [];
  List<TodoItem> _timetableItems = [];
  bool _autoReset = false;
  bool _loaded = false;

  List<TodoItem> get checklistItems => _checklistItems;
  List<TodoItem> get timetableItems => _timetableItems;
  bool get autoReset => _autoReset;
  bool get loaded => _loaded;

  List<TodoItem> itemsFor(TodoListType type) {
    switch (type) {
      case TodoListType.checklist:
        return _checklistItems;
      case TodoListType.timetable:
        return _timetableItems;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _checklistItems = _decodeList(prefs.getString(_checklistKey));
    _timetableItems = _decodeList(prefs.getString(_timetableKey));
    _autoReset = prefs.getBool(_autoResetKey) ?? false;

    // Auto-reset check
    final today = _todayStr();
    final lastDate = prefs.getString(_lastDateKey);
    if (_autoReset && lastDate != null && lastDate != today) {
      for (final item in _checklistItems) {
        item.completed = false;
      }
      for (final item in _timetableItems) {
        item.completed = false;
      }
      await _saveAll(prefs);
    }
    await prefs.setString(_lastDateKey, today);

    _loaded = true;
    notifyListeners();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<TodoItem> _decodeList(String? json) {
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(TodoListType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        type == TodoListType.checklist ? _checklistKey : _timetableKey;
    final items = itemsFor(type);
    await prefs.setString(
        key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveAll(SharedPreferences prefs) async {
    await prefs.setString(_checklistKey,
        jsonEncode(_checklistItems.map((e) => e.toJson()).toList()));
    await prefs.setString(_timetableKey,
        jsonEncode(_timetableItems.map((e) => e.toJson()).toList()));
  }

  // ── Checklist operations ──

  void addChecklistItem(String content) {
    _checklistItems.add(TodoItem(
      id: _genId(),
      content: content,
    ));
    notifyListeners();
    _save(TodoListType.checklist);
  }

  void removeChecklistItem(int index) {
    _checklistItems.removeAt(index);
    notifyListeners();
    _save(TodoListType.checklist);
  }

  // ── Timetable operations ──

  void addTimetableItem(int hour, String content) {
    _timetableItems.add(TodoItem(
      id: _genId(),
      content: content,
      hour: hour,
    ));
    notifyListeners();
    _save(TodoListType.timetable);
  }

  void removeTimetableItem(String id) {
    _timetableItems.removeWhere((e) => e.id == id);
    notifyListeners();
    _save(TodoListType.timetable);
  }

  List<TodoItem> timetableItemsForHour(int hour) {
    return _timetableItems.where((e) => e.hour == hour).toList();
  }

  // ── Common operations ──

  void updateItem(TodoListType type, String id,
      {String? content, int? importance, bool? completed}) {
    final items = itemsFor(type);
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final item = items[idx];
    if (content != null) item.content = content;
    if (importance != null) item.importance = importance;
    if (completed != null) item.completed = completed;
    notifyListeners();
    _save(type);
  }

  void toggleCompleted(TodoListType type, String id) {
    final items = itemsFor(type);
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    items[idx].completed = !items[idx].completed;
    notifyListeners();
    _save(type);
  }

  void bulkToggleCompleted(TodoListType type) {
    final items = itemsFor(type);
    if (items.isEmpty) return;
    final allDone = items.every((e) => e.completed);
    for (final item in items) {
      item.completed = !allDone;
    }
    notifyListeners();
    _save(type);
  }

  void setAutoReset(bool value) async {
    _autoReset = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoResetKey, value);
    notifyListeners();
  }

  String _genId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_checklistItems.length + _timetableItems.length}';
}
