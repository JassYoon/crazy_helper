import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/breathing_mode.dart';
import '../widgets/timer_donut.dart';
import '../widgets/rest_modal.dart';
import '../widgets/progress_bar.dart';
import '../widgets/custom_breathing_dialog.dart';
import 'info_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  // Settings
  int _sets = 4;
  int _restAfter = 5;
  int _sessionCount = 0;
  bool _restEnabled = true;
  int _modeIndex = 0;

  // Modes list (built-in + custom)
  List<BreathingMode> _allModes = [boxBreathing, anxietyRelief];

  // Timer state
  bool _running = false;
  double _elapsed = 0;
  bool _showRest = false;

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  BreathingMode get _mode => _allModes[_modeIndex];
  int get _totalPerCycle => _mode.totalPerCycle;
  int get _totalDuration => _mode.totalDuration(_sets);
  double get _cycleElapsed => _elapsed % _totalPerCycle;
  int get _completedCycles => (_elapsed / _totalPerCycle).floor();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _loadSettings();
    _loadModes();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sets = prefs.getInt('sets') ?? 4;
      _restAfter = prefs.getInt('restAfter') ?? 5;
      _sessionCount = prefs.getInt('sessionCount') ?? 0;
      _restEnabled = prefs.getBool('restEnabled') ?? true;
    });
  }

  Future<void> _loadModes() async {
    final modes = await BreathingModeStore.loadAll();
    setState(() {
      _allModes = modes;
      if (_modeIndex >= _allModes.length) _modeIndex = 0;
    });
  }

  Future<void> _saveSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sessionCount', _sessionCount);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    setState(() {
      _elapsed += delta;
      if (_elapsed >= _totalDuration) {
        _elapsed = 0;
        _running = false;
        _ticker.stop();
        _lastTick = Duration.zero;
      }
    });
  }

  void _handleStart() {
    if (_running) {
      setState(() {
        _running = false;
        _elapsed = 0;
        _ticker.stop();
        _lastTick = Duration.zero;
      });
      return;
    }

    // Check rest condition
    if (_restEnabled && _sessionCount >= _restAfter) {
      setState(() => _showRest = true);
      return;
    }

    setState(() {
      _sessionCount++;
      _running = true;
      _elapsed = 0;
      _lastTick = Duration.zero;
    });
    _saveSessionCount();
    _ticker.start();
  }

  void _cycleMode() {
    if (_running) return;
    setState(() {
      _modeIndex = (_modeIndex + 1) % _allModes.length;
    });
  }

  void _selectMode(int index) {
    if (_running) return;
    setState(() => _modeIndex = index);
  }

  void _dismissRest() {
    setState(() {
      _showRest = false;
      _sessionCount = 0;
    });
    _saveSessionCount();
  }

  Future<void> _openAddCustom() async {
    final mode = await showDialog<BreathingMode>(
      context: context,
      builder: (_) => const CustomBreathingDialog(),
    );
    if (mode != null) {
      await BreathingModeStore.addCustom(mode);
      await _loadModes();
      setState(() => _modeIndex = _allModes.length - 1);
    }
  }

  void _openInfo() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => InfoScreen(
          sets: _sets,
          restAfter: _restAfter,
          restEnabled: _restEnabled,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _sets = result['sets'] as int? ?? _sets;
        _restAfter = result['restAfter'] as int? ?? _restAfter;
        _restEnabled = result['restEnabled'] as bool? ?? _restEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TopButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      // Mode switcher with hover dropdown
                      _ModeSwitcher(
                        modes: _allModes,
                        currentIndex: _modeIndex,
                        onCycle: _cycleMode,
                        onSelect: _selectMode,
                        onAddCustom: _openAddCustom,
                        enabled: !_running,
                      ),
                      _TopButton(
                        icon: Icons.tune,
                        onTap: _openInfo,
                      ),
                    ],
                  ),
                ),
                // Donut chart
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final donutSize =
                              constraints.maxWidth.clamp(240.0, 288.0);
                          return TimerDonut(
                            mode: _mode,
                            cycleElapsed: _cycleElapsed,
                            running: _running,
                            size: donutSize,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      CycleProgressBar(
                        totalSets: _sets,
                        completedCycles: _completedCycles,
                        running: _running,
                      ),
                    ],
                  ),
                ),
                // Start/Stop button
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: GestureDetector(
                    onTap: _handleStart,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: _running
                            ? const Color(0xFF334155)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _running ? '중지' : '시작',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _running
                              ? Colors.white
                              : const Color(0xFF020617),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showRest)
            RestModal(
              restAfter: _restAfter,
              onDismiss: _dismissRest,
            ),
        ],
      ),
    );
  }
}

// ─── Mode Switcher with hover dropdown ───

class _ModeSwitcher extends StatefulWidget {
  final List<BreathingMode> modes;
  final int currentIndex;
  final VoidCallback onCycle;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddCustom;
  final bool enabled;

  const _ModeSwitcher({
    required this.modes,
    required this.currentIndex,
    required this.onCycle,
    required this.onSelect,
    required this.onAddCustom,
    required this.enabled,
  });

  @override
  State<_ModeSwitcher> createState() => _ModeSwitcherState();
}

class _ModeSwitcherState extends State<_ModeSwitcher> {
  final _overlayController = OverlayPortalController();
  final _link = LayerLink();
  bool _hovering = false;

  void _showDropdown() {
    if (!widget.enabled) return;
    setState(() => _hovering = true);
    _overlayController.show();
  }

  void _hideDropdown() {
    setState(() => _hovering = false);
    // Delay to allow clicking items
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_hovering && mounted) {
        _overlayController.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.modes[widget.currentIndex];

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 8),
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovering = true),
              onExit: (_) => _hideDropdown(),
              child: _ModeDropdown(
                modes: widget.modes,
                currentIndex: widget.currentIndex,
                onSelect: (i) {
                  widget.onSelect(i);
                  _overlayController.hide();
                  setState(() => _hovering = false);
                },
                onAddCustom: () {
                  _overlayController.hide();
                  setState(() => _hovering = false);
                  widget.onAddCustom();
                },
              ),
            ),
          );
        },
        child: MouseRegion(
          onEnter: (_) => _showDropdown(),
          onExit: (_) => _hideDropdown(),
          child: GestureDetector(
            onTap: widget.enabled ? widget.onCycle : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hovering
                      ? const Color(0xFF475569)
                      : const Color(0xFF334155),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mode.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _hovering
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeDropdown extends StatelessWidget {
  final List<BreathingMode> modes;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddCustom;

  const _ModeDropdown({
    required this.modes,
    required this.currentIndex,
    required this.onSelect,
    required this.onAddCustom,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(modes.length, (i) {
              final mode = modes[i];
              final selected = i == currentIndex;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  color: selected
                      ? const Color(0xFF334155).withValues(alpha: 0.5)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      // Phase colors preview
                      ...mode.phases.take(4).map((p) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: p.color,
                              shape: BoxShape.circle,
                            ),
                          )),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mode.description,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        mode.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Divider + Add button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              height: 1,
              color: const Color(0xFF334155),
            ),
            GestureDetector(
              onTap: onAddCustom,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF475569),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF64748B),
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '커스텀 호흡 추가',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      ),
    );
  }
}
