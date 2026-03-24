import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../models/todo_list_type.dart';
import '../models/todo_store.dart';
import 'star_rating.dart';

class ChecklistView extends StatefulWidget {
  final TodoStore store;

  const ChecklistView({super.key, required this.store});

  @override
  State<ChecklistView> createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  bool _sortByImportance = false;
  final _addController = TextEditingController();
  final _focusNode = FocusNode();

  TodoStore get _store => widget.store;

  List<TodoItem> get _items => _store.checklistItems;

  // Returns display-ordered items with their original indices
  List<(int originalIndex, TodoItem item)> get _displayItems {
    final indexed =
        _items.asMap().entries.map((e) => (e.key, e.value)).toList();
    if (_sortByImportance) {
      indexed.sort((a, b) => b.$2.importance.compareTo(a.$2.importance));
    }
    return indexed;
  }

  void _addItem() {
    final text = _addController.text.trim();
    if (text.isEmpty) return;
    _store.addChecklistItem(text);
    _addController.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _addController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _displayItems;
    final allDone = _items.isNotEmpty && _items.every((e) => e.completed);

    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '#',
                  style: _headerStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text('내용', style: _headerStyle),
              ),
              // Importance header (sortable)
              GestureDetector(
                onTap: () => setState(() => _sortByImportance = !_sortByImportance),
                child: SizedBox(
                  width: 72,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('중요도', style: _headerStyle),
                      const SizedBox(width: 2),
                      Icon(
                        _sortByImportance
                            ? Icons.arrow_downward
                            : Icons.unfold_more,
                        color: _sortByImportance
                            ? const Color(0xFFFFB74D)
                            : const Color(0xFF64748B),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              // Bulk complete toggle
              GestureDetector(
                onTap: () => _store.bulkToggleCompleted(TodoListType.checklist),
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
        // Items
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    '할 일을 추가하세요',
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final (originalIndex, item) = items[i];
                    return _ChecklistRow(
                      number: originalIndex + 1,
                      item: item,
                      onToggleComplete: () =>
                          _store.toggleCompleted(TodoListType.checklist, item.id),
                      onImportanceChanged: (val) => _store.updateItem(
                          TodoListType.checklist, item.id,
                          importance: val),
                      onContentChanged: (val) => _store.updateItem(
                          TodoListType.checklist, item.id,
                          content: val),
                      onDelete: () {
                        final idx =
                            _store.checklistItems.indexWhere((e) => e.id == item.id);
                        if (idx != -1) _store.removeChecklistItem(idx);
                      },
                    );
                  },
                ),
        ),
        // Add new item
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addController,
                  focusNode: _focusNode,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '새 할 일 입력...',
                    hintStyle: const TextStyle(
                        color: Color(0xFF475569), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFF334155)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFF334155)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFF60A5FA)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addItem,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF60A5FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle get _headerStyle => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.5,
      );
}

class _ChecklistRow extends StatefulWidget {
  final int number;
  final TodoItem item;
  final VoidCallback onToggleComplete;
  final ValueChanged<int> onImportanceChanged;
  final ValueChanged<String> onContentChanged;
  final VoidCallback onDelete;

  const _ChecklistRow({
    required this.number,
    required this.item,
    required this.onToggleComplete,
    required this.onImportanceChanged,
    required this.onContentChanged,
    required this.onDelete,
  });

  @override
  State<_ChecklistRow> createState() => _ChecklistRowState();
}

class _ChecklistRowState extends State<_ChecklistRow> {
  late TextEditingController _controller;
  bool _editing = false;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.content);
  }

  @override
  void didUpdateWidget(covariant _ChecklistRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.content != widget.item.content && !_editing) {
      _controller.text = widget.item.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.item.completed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _hovering
              ? const Color(0xFF1E293B).withValues(alpha: 0.5)
              : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: Color(0xFF1E293B), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Number
            SizedBox(
              width: 36,
              child: Text(
                '${widget.number}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: done
                      ? const Color(0xFF334155)
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  decoration:
                      done ? TextDecoration.lineThrough : null,
                  decorationColor: const Color(0xFF475569),
                ),
              ),
            ),
            // Content
            Expanded(
              child: _editing
                  ? TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (val) {
                        widget.onContentChanged(val);
                        setState(() => _editing = false);
                      },
                      onTapOutside: (_) {
                        widget.onContentChanged(_controller.text);
                        setState(() => _editing = false);
                      },
                    )
                  : GestureDetector(
                      onDoubleTap: () =>
                          setState(() => _editing = true),
                      child: Text(
                        widget.item.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: done
                              ? const Color(0xFF475569)
                              : Colors.white,
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                          decorationColor: const Color(0xFF475569),
                        ),
                      ),
                    ),
            ),
            // Importance
            SizedBox(
              width: 72,
              child: StarRating(
                rating: widget.item.importance,
                onChanged: widget.onImportanceChanged,
                size: 16,
              ),
            ),
            // Complete checkbox
            SizedBox(
              width: 36,
              child: GestureDetector(
                onTap: widget.onToggleComplete,
                child: Icon(
                  done
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: done
                      ? const Color(0xFF34D399)
                      : const Color(0xFF475569),
                  size: 18,
                ),
              ),
            ),
            // Delete (on hover)
            SizedBox(
              width: 24,
              child: _hovering
                  ? GestureDetector(
                      onTap: widget.onDelete,
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFFEF4444),
                        size: 14,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
