import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/done_list_type.dart';
import '../models/done_store.dart';
import '../widgets/done_checklist_view.dart';
import '../widgets/done_timetable_view.dart';
import 'done_calendar_screen.dart';

class DoneScreen extends StatefulWidget {
  const DoneScreen({super.key});

  @override
  State<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen> {
  final _store = DoneStore();
  DoneListType _currentType = DoneListType.checklist;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _store.load();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _store.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  Widget _buildListView() {
    switch (_currentType) {
      case DoneListType.checklist:
        return DoneChecklistView(store: _store);
      case DoneListType.timetable:
        return DoneTimetableView(store: _store);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44, height: 44,
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
                    '한 일',
                    style: appStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DoneListType>(
                    value: _currentType,
                    isExpanded: true,
                    dropdownColor: AppColors.white,
                    icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textHint, size: 20),
                    style: appStyle(context, color: AppColors.textPrimary, fontSize: 14),
                    items: DoneListType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type.label,
                                style: appStyle(context, color: AppColors.textPrimary, fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _currentType = val);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _store.loaded
                    ? _buildListView()
                    : Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DoneCalendarScreen(store: _store)),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '달력',
                        style: appStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
