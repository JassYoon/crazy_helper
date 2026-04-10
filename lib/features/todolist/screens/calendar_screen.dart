import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/todo_store.dart';

class CalendarScreen extends StatefulWidget {
  final TodoStore store;
  const CalendarScreen({super.key, required this.store});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _startYear = 2026;
  static const _startMonth = 4;

  late int _year;
  late int _month;
  Map<String, int> _scores = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _loadScores();
  }

  Future<void> _loadScores() async {
    await widget.store.saveTodayScore();
    final scores = await widget.store.getScores();
    if (mounted) setState(() => _scores = scores);
  }

  bool get _canGoPrev {
    if (_year > _startYear) return true;
    if (_year == _startYear && _month > _startMonth) return true;
    return false;
  }

  void _prevMonth() {
    if (!_canGoPrev) return;
    setState(() {
      _month--;
      if (_month < 1) {
        _month = 12;
        _year--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _month++;
      if (_month > 12) {
        _month = 1;
        _year++;
      }
    });
  }

  String _dateKey(int day) =>
      '$_year-${_month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                        color: AppColors.white,
                      ),
                      child: Icon(Icons.arrow_back, color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '달력',
                    style: appStyle(context, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            // Month navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _canGoPrev ? _prevMonth : null,
                    child: Icon(
                      Icons.chevron_left,
                      color: _canGoPrev ? AppColors.textPrimary : AppColors.textHint,
                      size: 28,
                    ),
                  ),
                  Text(
                    '$_year년 $_month월',
                    style: appStyle(context, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: Icon(Icons.chevron_right, color: AppColors.textPrimary, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Weekday headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: ['일', '월', '화', '수', '목', '금', '토']
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: appStyle(
                                context,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: d == '일'
                                    ? AppColors.error
                                    : d == '토'
                                        ? const Color(0xFF42A5F5)
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildCalendarGrid(),
              ),
            ),
            // Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendDot(AppColors.primary, '80~100'),
                  const SizedBox(width: 12),
                  _legendDot(AppColors.primaryLight, '50~79'),
                  const SizedBox(width: 12),
                  _legendDot(AppColors.star, '20~49'),
                  const SizedBox(width: 12),
                  _legendDot(AppColors.error.withValues(alpha: 0.7), '0~19'),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: appStyle(context, fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_year, _month, 1);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sunday = 0

    final today = DateTime.now();
    final isCurrentMonth = today.year == _year && today.month == _month;

    final cells = <Widget>[];

    // Empty cells before first day
    for (var i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final key = _dateKey(day);
      final score = _scores[key];
      final isToday = isCurrentMonth && today.day == day;

      cells.add(_DayCell(
        day: day,
        score: score,
        isToday: isToday,
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 0.85,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final int? score;
  final bool isToday;

  const _DayCell({required this.day, this.score, required this.isToday});

  Color? _scoreColor() {
    if (score == null) return null;
    if (score! >= 80) return AppColors.primary;
    if (score! >= 50) return AppColors.primaryLight;
    if (score! >= 20) return AppColors.star;
    return AppColors.error.withValues(alpha: 0.7);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _scoreColor();
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor?.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: AppColors.primaryDark, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? AppColors.primaryDark : AppColors.textPrimary,
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: 2),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: bgColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
