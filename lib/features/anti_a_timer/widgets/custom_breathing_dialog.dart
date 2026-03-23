import 'package:flutter/material.dart';
import '../models/breathing_mode.dart' show BreathingMode, BreathingPhase, kPhaseTemplates;

class CustomBreathingDialog extends StatefulWidget {
  const CustomBreathingDialog({super.key});

  @override
  State<CustomBreathingDialog> createState() => _CustomBreathingDialogState();
}

class _CustomBreathingDialogState extends State<CustomBreathingDialog> {
  final List<_EditablePhase> _phases = [];
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    for (final p in _phases) {
      p.secondsController.dispose();
    }
    super.dispose();
  }

  void _addPhase(BreathingPhase template) {
    setState(() {
      _phases.add(_EditablePhase(
        label: template.label,
        color: template.color,
        secondsController: TextEditingController(text: '4'),
      ));
    });
  }

  void _removePhase(int index) {
    setState(() {
      _phases[index].secondsController.dispose();
      _phases.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _phases.removeAt(oldIndex);
      _phases.insert(newIndex, item);
    });
  }

  void _submit() {
    if (_phases.isEmpty) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final phases = _phases.map((p) {
      final sec = int.tryParse(p.secondsController.text) ?? 4;
      return BreathingPhase(
        label: p.label,
        color: p.color,
        seconds: sec.clamp(1, 60),
      );
    }).toList();

    final timings = phases.map((p) => '${p.seconds}').join('-');

    final mode = BreathingMode(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: timings,
      description: name,
      phases: phases,
    );

    Navigator.of(context).pop(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '커스텀 호흡 추가',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF94A3B8),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Phase template buttons
              const Text(
                '주기 추가',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: kPhaseTemplates.map((template) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _addPhase(template),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: template.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: template.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: template.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              template.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: template.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Added phases list (reorderable)
              Flexible(
                child: _phases.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            '위 버튼을 눌러 호흡 주기를 추가하세요',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        shrinkWrap: true,
                        buildDefaultDragHandles: false,
                        itemCount: _phases.length,
                        proxyDecorator: (child, index, animation) {
                          return Material(
                            color: Colors.transparent,
                            child: child,
                          );
                        },
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          final phase = _phases[index];
                          return _PhaseRow(
                            key: ValueKey(phase),
                            index: index,
                            phase: phase,
                            onRemove: () => _removePhase(index),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),

              // Name input
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '호흡 이름 (예: 나만의 호흡)',
                  hintStyle: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF60A5FA)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _phases.isNotEmpty &&
                          _nameController.text.trim().isNotEmpty
                      ? _submit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60A5FA),
                    disabledBackgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '추가',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditablePhase {
  final String label;
  final Color color;
  final TextEditingController secondsController;

  _EditablePhase({
    required this.label,
    required this.color,
    required this.secondsController,
  });
}

class _PhaseRow extends StatelessWidget {
  final int index;
  final _EditablePhase phase;
  final VoidCallback onRemove;

  const _PhaseRow({
    super.key,
    required this.index,
    required this.phase,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Drag handle (color icon)
          ReorderableDragStartListener(
            index: index,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: phase.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.drag_indicator,
                color: phase.color,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Label
          Expanded(
            child: Text(
              phase.label,
              style: TextStyle(
                fontSize: 13,
                color: phase.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Seconds input
          SizedBox(
            width: 52,
            height: 32,
            child: TextField(
              controller: phase.secondsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                suffixText: '초',
                suffixStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                ),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF60A5FA)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Delete button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFFEF4444),
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
