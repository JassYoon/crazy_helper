import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../models/todo_list_type.dart';
import '../models/todo_store.dart';
import 'star_rating.dart';

class TimetableView extends StatefulWidget {
  final TodoStore store;

  const TimetableView({super.key, required this.store});

  @override
  State<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<TimetableView> {
  TodoStore get _store => widget.store;

  // 06:00 ~ 05:00 (next day) order
  static const _hourOrder = [
    6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
    18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5,
  ];

  String _formatHour(int h) {
    return '${h.toString().padLeft(2, '0')}:00';
  }

  void _addItemAtHour(int hour) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          '${_formatHour(hour)} 할 일 추가',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: '할 일 입력...',
            hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF60A5FA)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onSubmitted: (val) => Navigator.of(ctx).pop(val),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('추가',
                style: TextStyle(color: Color(0xFF60A5FA))),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.trim().isNotEmpty) {
      _store.addTimetableItem(hour, result.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _store.timetableItems;
    final allDone = allItems.isNotEmpty && allItems.every((e) => e.completed);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 56,
                child: Text(
                  '시간',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  '할 일',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Bulk complete
              GestureDetector(
                onTap: allItems.isEmpty
                    ? null
                    : () =>
                        _store.bulkToggleCompleted(TodoListType.timetable),
                child: SizedBox(
                  width: 36,
                  child: Icon(
                    allDone
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: allDone
                        ? const Color(0xFF34D399)
                        : const Color(0xFF64748B),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Time slots
        Expanded(
          child: ListView.builder(
            itemCount: _hourOrder.length,
            itemBuilder: (context, i) {
              final hour = _hourOrder[i];
              final hourItems = _store.timetableItemsForHour(hour);
              return _TimeSlot(
                hour: hour,
                label: _formatHour(hour),
                items: hourItems,
                onTap: () => _addItemAtHour(hour),
                onToggleComplete: (id) =>
                    _store.toggleCompleted(TodoListType.timetable, id),
                onImportanceChanged: (id, val) => _store.updateItem(
                    TodoListType.timetable, id,
                    importance: val),
                onDelete: (id) => _store.removeTimetableItem(id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TimeSlot extends StatefulWidget {
  final int hour;
  final String label;
  final List<TodoItem> items;
  final VoidCallback onTap;
  final ValueChanged<String> onToggleComplete;
  final void Function(String id, int val) onImportanceChanged;
  final ValueChanged<String> onDelete;

  const _TimeSlot({
    required this.hour,
    required this.label,
    required this.items,
    required this.onTap,
    required this.onToggleComplete,
    required this.onImportanceChanged,
    required this.onDelete,
  });

  @override
  State<_TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<_TimeSlot> {
  bool _hovering = false;

  bool get _isCurrentHour {
    final now = DateTime.now();
    return now.hour == widget.hour;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            color: _isCurrentHour
                ? const Color(0xFF60A5FA).withValues(alpha: 0.06)
                : _hovering
                    ? const Color(0xFF1E293B).withValues(alpha: 0.4)
                    : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: Color(0xFF1E293B), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hour label
              SizedBox(
                width: 56,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _isCurrentHour
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _isCurrentHour
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF64748B),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              // Items
              Expanded(
                child: widget.items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _hovering ? '+ 클릭하여 추가' : '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                          ),
                        ),
                      )
                    : Column(
                        children: widget.items.map((item) {
                          return _TimetableItemRow(
                            item: item,
                            onToggleComplete: () =>
                                widget.onToggleComplete(item.id),
                            onImportanceChanged: (val) =>
                                widget.onImportanceChanged(item.id, val),
                            onDelete: () => widget.onDelete(item.id),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimetableItemRow extends StatefulWidget {
  final TodoItem item;
  final VoidCallback onToggleComplete;
  final ValueChanged<int> onImportanceChanged;
  final VoidCallback onDelete;

  const _TimetableItemRow({
    required this.item,
    required this.onToggleComplete,
    required this.onImportanceChanged,
    required this.onDelete,
  });

  @override
  State<_TimetableItemRow> createState() => _TimetableItemRowState();
}

class _TimetableItemRowState extends State<_TimetableItemRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final done = widget.item.completed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            // Content
            Expanded(
              child: GestureDetector(
                // Prevent parent onTap (add new)
                onTap: () {},
                child: Text(
                  widget.item.content,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        done ? const Color(0xFF475569) : Colors.white,
                    decoration:
                        done ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFF475569),
                  ),
                ),
              ),
            ),
            // Importance
            StarRating(
              rating: widget.item.importance,
              onChanged: widget.onImportanceChanged,
              size: 14,
            ),
            const SizedBox(width: 6),
            // Checkbox
            GestureDetector(
              onTap: widget.onToggleComplete,
              child: Icon(
                done
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: done
                    ? const Color(0xFF34D399)
                    : const Color(0xFF475569),
                size: 16,
              ),
            ),
            // Delete
            SizedBox(
              width: 20,
              child: _hovering
                  ? GestureDetector(
                      onTap: widget.onDelete,
                      child: const Icon(Icons.close,
                          color: Color(0xFFEF4444), size: 13),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
