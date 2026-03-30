import 'package:flutter/material.dart';
import '../../../core/app_text_input.dart';
import '../../../core/theme.dart';
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

  static const _hourOrder = [
    6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
    18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5,
  ];

  String _formatHour(int h) => '${h.toString().padLeft(2, '0')}:00';

  void _addItemAtHour(int hour) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          '${_formatHour(hour)} 할 일 추가',
          style: appStyle(
            ctx,
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: AppTextInput.keyboard,
          style: appStyle(
            ctx,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: '할 일 입력...',
            hintStyle: appStyle(
              ctx,
              color: AppColors.textHint,
              fontSize: 13,
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onSubmitted: (val) => Navigator.of(ctx).pop(val),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: appStyle(ctx, color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(
              '추가',
              style: appStyle(ctx, color: AppColors.primary),
            ),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryVeryLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              SizedBox(width: 56, child: Text('시간', style: _headerStyle)),
              Expanded(child: Text('할 일', style: _headerStyle)),
              GestureDetector(
                onTap: allItems.isEmpty ? null : () => _store.bulkToggleCompleted(TodoListType.timetable),
                child: SizedBox(
                  width: 36,
                  child: Icon(
                    allDone ? Icons.check_box : Icons.check_box_outline_blank,
                    color: allDone ? AppColors.success : AppColors.textHint,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: AppColors.white,
            child: ListView.builder(
              itemCount: _hourOrder.length,
              itemBuilder: (context, i) {
                final hour = _hourOrder[i];
                return _TimeSlot(
                  hour: hour,
                  label: _formatHour(hour),
                  items: _store.timetableItemsForHour(hour),
                  onTap: () => _addItemAtHour(hour),
                  onToggleComplete: (id) => _store.toggleCompleted(TodoListType.timetable, id),
                  onImportanceChanged: (id, val) =>
                      _store.updateItem(TodoListType.timetable, id, importance: val),
                  onDelete: (id) => _store.removeTimetableItem(id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  TextStyle get _headerStyle => appStyle(
        context,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );
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
    required this.hour, required this.label, required this.items,
    required this.onTap, required this.onToggleComplete,
    required this.onImportanceChanged, required this.onDelete,
  });

  @override
  State<_TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<_TimeSlot> {
  bool _hovering = false;
  bool get _isCurrentHour => DateTime.now().hour == widget.hour;

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
                ? AppColors.primary.withValues(alpha: 0.06)
                : _hovering
                    ? AppColors.cardHover
                    : Colors.transparent,
            border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.label,
                    style: appStyle(
                      context,
                      fontSize: 12,
                      fontWeight: _isCurrentHour ? FontWeight.w700 : FontWeight.w500,
                      color: _isCurrentHour ? AppColors.primaryDark : AppColors.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: widget.items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _hovering ? '+ 클릭하여 추가' : '',
                          style: appStyle(
                            context,
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      )
                    : Column(
                        children: widget.items.map((item) {
                          return _TimetableItemRow(
                            item: item,
                            onToggleComplete: () => widget.onToggleComplete(item.id),
                            onImportanceChanged: (val) => widget.onImportanceChanged(item.id, val),
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
    required this.item, required this.onToggleComplete,
    required this.onImportanceChanged, required this.onDelete,
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
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  widget.item.content,
                  style: appStyle(
                    context,
                    fontSize: 13,
                    color: done ? AppColors.textHint : AppColors.textPrimary,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textHint,
                  ),
                ),
              ),
            ),
            StarRating(rating: widget.item.importance, onChanged: widget.onImportanceChanged, size: 14),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: widget.onToggleComplete,
              child: Icon(
                done ? Icons.check_box : Icons.check_box_outline_blank,
                color: done ? AppColors.success : AppColors.textHint,
                size: 16,
              ),
            ),
            SizedBox(
              width: 20,
              child: _hovering
                  ? GestureDetector(onTap: widget.onDelete, child: Icon(Icons.close, color: AppColors.error, size: 13))
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
