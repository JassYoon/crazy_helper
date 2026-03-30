import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/todo_list_type.dart';
import '../models/todo_store.dart';
import '../widgets/checklist_view.dart';
import '../widgets/timetable_view.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _store = TodoStore();
  TodoListType _currentType = TodoListType.checklist;

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
      case TodoListType.checklist:
        return ChecklistView(store: _store);
      case TodoListType.timetable:
        return TimetableView(store: _store);
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
                    '할 일',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TodoListType>(
                        value: _currentType,
                        isExpanded: true,
                        dropdownColor: AppColors.white,
                        icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textHint, size: 20),
                        style: appStyle(
                          context,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        items: TodoListType.values
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type.label,
                                    style: appStyle(
                                      context,
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _currentType = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _store.setAutoReset(!_store.autoReset),
                    child: Row(
                      children: [
                        Icon(
                          _store.autoReset ? Icons.check_box : Icons.check_box_outline_blank,
                          color: _store.autoReset ? AppColors.primary : AppColors.textHint,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '자동 리셋 (날짜 변경시 모든 항목 미완료)',
                          style: appStyle(
                            context,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
