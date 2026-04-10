import 'package:flutter/material.dart';
import '../../../core/app_text_input.dart';
import '../../../core/theme.dart';
import '../../todolist/widgets/star_rating.dart';
import '../models/done_item.dart';
import '../models/done_list_type.dart';
import '../models/done_store.dart';

class DoneChecklistView extends StatefulWidget {
  final DoneStore store;
  const DoneChecklistView({super.key, required this.store});

  @override
  State<DoneChecklistView> createState() => _DoneChecklistViewState();
}

class _DoneChecklistViewState extends State<DoneChecklistView> {
  bool _sortByImportance = false;
  final _addController = TextEditingController();

  DoneStore get _store => widget.store;
  List<DoneItem> get _items => _store.checklistItems;

  List<(int originalIndex, DoneItem item)> get _displayItems {
    final indexed = _items.asMap().entries.map((e) => (e.key, e.value)).toList();
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
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _displayItems;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryVeryLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              SizedBox(width: 36, child: Text('#', style: _headerStyle, textAlign: TextAlign.center)),
              Expanded(child: Text('내용', style: _headerStyle)),
              GestureDetector(
                onTap: () => setState(() => _sortByImportance = !_sortByImportance),
                child: SizedBox(
                  width: 108,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('중요도', style: _headerStyle),
                      const SizedBox(width: 2),
                      Icon(
                        _sortByImportance ? Icons.arrow_downward : Icons.unfold_more,
                        color: _sortByImportance ? AppColors.star : AppColors.textHint,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Items
        Expanded(
          child: Container(
            color: AppColors.white,
            child: items.isEmpty
                ? Center(
                    child: Text(
                      '한 일을 추가하세요',
                      style: appStyle(context, color: AppColors.textHint, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final (originalIndex, item) = items[i];
                      return _DoneChecklistRow(
                        number: originalIndex + 1,
                        item: item,
                        onImportanceChanged: (val) =>
                            _store.updateItem(DoneListType.checklist, item.id, importance: val),
                        onContentChanged: (val) =>
                            _store.updateItem(DoneListType.checklist, item.id, content: val),
                        onDelete: () {
                          final idx = _store.checklistItems.indexWhere((e) => e.id == item.id);
                          if (idx != -1) _store.removeChecklistItem(idx);
                        },
                      );
                    },
                  ),
          ),
        ),
        // Add input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addController,
                  keyboardType: AppTextInput.keyboard,
                  style: appStyle(context, color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '한 일 입력...',
                    hintStyle: appStyle(context, color: AppColors.textHint, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addItem,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.add, color: AppColors.white, size: 20),
                ),
              ),
            ],
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

class _DoneChecklistRow extends StatefulWidget {
  final int number;
  final DoneItem item;
  final ValueChanged<int> onImportanceChanged;
  final ValueChanged<String> onContentChanged;
  final VoidCallback onDelete;

  const _DoneChecklistRow({
    required this.number, required this.item,
    required this.onImportanceChanged,
    required this.onContentChanged, required this.onDelete,
  });

  @override
  State<_DoneChecklistRow> createState() => _DoneChecklistRowState();
}

class _DoneChecklistRowState extends State<_DoneChecklistRow> {
  late TextEditingController _controller;
  bool _editing = false;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.content);
  }

  @override
  void didUpdateWidget(covariant _DoneChecklistRow oldWidget) {
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _hovering ? AppColors.cardHover : Colors.transparent,
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                '${widget.number}',
                textAlign: TextAlign.center,
                style: appStyle(
                  context,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: _editing
                  ? TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: AppTextInput.keyboard,
                      style: appStyle(context, color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (val) { widget.onContentChanged(val); setState(() => _editing = false); },
                      onTapOutside: (_) { widget.onContentChanged(_controller.text); setState(() => _editing = false); },
                    )
                  : GestureDetector(
                      onDoubleTap: () => setState(() => _editing = true),
                      child: Text(
                        widget.item.content,
                        style: appStyle(context, fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
            ),
            SizedBox(width: 108, child: StarRating(rating: widget.item.importance, onChanged: widget.onImportanceChanged, size: 16)),
            SizedBox(
              width: 24,
              child: _hovering
                  ? GestureDetector(onTap: widget.onDelete, child: Icon(Icons.close, color: AppColors.error, size: 14))
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
