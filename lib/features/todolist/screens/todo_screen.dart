import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFF94A3B8), size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    '할 일',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Combo box + auto-reset
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // List type selector (combo box)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: const Color(0xFF334155)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TodoListType>(
                        value: _currentType,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF64748B), size: 20),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        items: TodoListType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _currentType = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Auto-reset checkbox
                  GestureDetector(
                    onTap: () =>
                        _store.setAutoReset(!_store.autoReset),
                    child: Row(
                      children: [
                        Icon(
                          _store.autoReset
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: _store.autoReset
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF475569),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '자동 리셋 (날짜 변경시 모든 항목 미완료)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // List content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _store.loaded
                    ? _buildListView()
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF60A5FA),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
