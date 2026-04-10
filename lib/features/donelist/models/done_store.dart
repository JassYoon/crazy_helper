import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'done_item.dart';
import 'done_list_type.dart';

class DoneStore extends ChangeNotifier {
  static const _checklistKey = 'done_checklist';
  static const _timetableKey = 'done_timetable';
  static const _lastDateKey = 'done_lastDate';
  static const _scoresKey = 'done_scores';

  List<DoneItem> _checklistItems = [];
  List<DoneItem> _timetableItems = [];
  bool _loaded = false;

  List<DoneItem> get checklistItems => _checklistItems;
  List<DoneItem> get timetableItems => _timetableItems;
  bool get loaded => _loaded;

  List<DoneItem> itemsFor(DoneListType type) {
    switch (type) {
      case DoneListType.checklist:
        return _checklistItems;
      case DoneListType.timetable:
        return _timetableItems;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _checklistItems = _decodeList(prefs.getString(_checklistKey));
    _timetableItems = _decodeList(prefs.getString(_timetableKey));

    // Date change — save previous day's score and clear items for new day
    final today = _todayStr();
    final lastDate = prefs.getString(_lastDateKey);
    if (lastDate != null && lastDate != today) {
      final prevScore = _calcScore(_checklistItems, _timetableItems);
      if (prevScore != null) {
        await _saveScoreForDate(prefs, lastDate, prevScore);
      }
      // Clear items for new day
      _checklistItems.clear();
      _timetableItems.clear();
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

  List<DoneItem> _decodeList(String? json) {
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => DoneItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(DoneListType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        type == DoneListType.checklist ? _checklistKey : _timetableKey;
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
    _checklistItems.add(DoneItem(
      id: _genId(),
      content: content,
    ));
    notifyListeners();
    _save(DoneListType.checklist);
  }

  void removeChecklistItem(int index) {
    _checklistItems.removeAt(index);
    notifyListeners();
    _save(DoneListType.checklist);
  }

  // ── Timetable operations ──

  void addTimetableItem(int hour, String content) {
    _timetableItems.add(DoneItem(
      id: _genId(),
      content: content,
      hour: hour,
    ));
    notifyListeners();
    _save(DoneListType.timetable);
  }

  void removeTimetableItem(String id) {
    _timetableItems.removeWhere((e) => e.id == id);
    notifyListeners();
    _save(DoneListType.timetable);
  }

  List<DoneItem> timetableItemsForHour(int hour) {
    return _timetableItems.where((e) => e.hour == hour).toList();
  }

  // ── Common operations ──

  void updateItem(DoneListType type, String id,
      {String? content, int? importance}) {
    final items = itemsFor(type);
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final item = items[idx];
    if (content != null) item.content = content;
    if (importance != null) item.importance = importance;
    notifyListeners();
    _save(type);
  }

  String _genId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_checklistItems.length + _timetableItems.length}';

  // ── Score operations ──

  /// Score = total importance sum of all items.
  int? _calcScore(List<DoneItem> checklist, List<DoneItem> timetable) {
    final allItems = [...checklist, ...timetable];
    if (allItems.isEmpty) return null;
    return allItems.fold<int>(0, (sum, e) => sum + e.importance);
  }

  /// Current day's score (live calculation).
  int? get todayScore => _calcScore(_checklistItems, _timetableItems);

  Future<void> _saveScoreForDate(SharedPreferences prefs, String date, int score) async {
    final scores = _loadScores(prefs);
    scores[date] = score;
    await prefs.setString(_scoresKey, jsonEncode(scores));
  }

  Map<String, int> _loadScores(SharedPreferences prefs) {
    final raw = prefs.getString(_scoresKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as int));
  }

  /// Save today's score manually.
  Future<void> saveTodayScore() async {
    final score = todayScore;
    if (score == null) return;
    final prefs = await SharedPreferences.getInstance();
    await _saveScoreForDate(prefs, _todayStr(), score);
  }

  /// Get all saved scores.
  Future<Map<String, int>> getScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = _loadScores(prefs);
    final ts = todayScore;
    if (ts != null) {
      scores[_todayStr()] = ts;
    }
    return scores;
  }
}
