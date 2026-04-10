import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/done_store.dart';

class DoneCalendarScreen extends StatefulWidget {
  final DoneStore store;
  const DoneCalendarScreen({super.key, required this.store});

  @override
  State<DoneCalendarScreen> createState() => _DoneCalendarScreenState();
}

class _DoneCalendarScreenState extends State<DoneCalendarScreen> {
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_year, _month, 1);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sunday = 0

    final today = DateTime.now();
    final isCurrentMonth = today.year == _year && today.month == _month;

    final cells = <Widget>[];

    for (var i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final key = _dateKey(day);
      final score = _scores[key];
      final isToday = isCurrentMonth && today.day == day;

      cells.add(_DoneDayCell(day: day, score: score, isToday: isToday));
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 0.85,
      children: cells,
    );
  }
}

class _DoneDayCell extends StatelessWidget {
  final int day;
  final int? score;
  final bool isToday;

  const _DoneDayCell({required this.day, this.score, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: score != null ? AppColors.primaryVeryLight : null,
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
            Text(
              '$score',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
