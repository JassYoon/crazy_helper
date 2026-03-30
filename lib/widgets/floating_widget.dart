import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../core/theme.dart';
import '../core/module_registry.dart';
import '../features/anti_a_timer/screens/timer_screen.dart';
import '../features/todolist/screens/todo_screen.dart';
import 'logo_widget.dart';
import 'menu_bar_widget.dart';

class FloatingWidgetScreen extends StatefulWidget {
  final ModuleRegistry registry;
  final VoidCallback onOpenHome;

  const FloatingWidgetScreen({
    super.key,
    required this.registry,
    required this.onOpenHome,
  });

  @override
  State<FloatingWidgetScreen> createState() => _FloatingWidgetScreenState();
}

class _FloatingWidgetScreenState extends State<FloatingWidgetScreen> {
  bool _menuVisible = false;
  bool _menuAbove = true;
  Offset _widgetPosition = Offset.zero;
  double _screenHeight = 800;

  @override
  void initState() {
    super.initState();
    widget.registry.addListener(_onRegistryChanged);
    _updateScreenInfo();
  }

  @override
  void dispose() {
    widget.registry.removeListener(_onRegistryChanged);
    super.dispose();
  }

  void _onRegistryChanged() {
    setState(() {});
  }

  Future<void> _updateScreenInfo() async {
    final bounds = await windowManager.getBounds();
    setState(() {
      _widgetPosition = Offset(bounds.left, bounds.top);
      _screenHeight = 800;
    });
    _recalculateMenuPosition();
  }

  void _recalculateMenuPosition() {
    setState(() {
      _menuAbove = _widgetPosition.dy > _screenHeight / 2;
    });
  }

  Future<void> _openModuleById(String moduleId) async {
    final route = switch (moduleId) {
      'anti_a_timer' => MaterialPageRoute<void>(
          builder: (_) => const TimerScreen(),
        ),
      'todolist' => MaterialPageRoute<void>(
          builder: (_) => const TodoScreen(),
        ),
      _ => null,
    };
    if (route == null) return;
    await windowManager.setSize(const Size(420, 680));
    if (!mounted) return;
    await Navigator.of(context).push(route);
    if (!mounted) return;
    await _updateWindowSize();
  }

  void _toggleMenu() {
    setState(() {
      _menuVisible = !_menuVisible;
    });
    _updateWindowSize();
  }

  Future<void> _updateWindowSize() async {
    if (_menuVisible) {
      final totalHeight = AppFloatingChrome.widgetSize +
          AppFloatingChrome.menuBarGap +
          AppFloatingChrome.menuBarHeight;
      final menuModules = widget.registry.menuModules;
      final menuWidth = menuModules.isEmpty
          ? 220.0
          : (menuModules.length * 48.0 + 16).clamp(100.0, 400.0);
      final width = menuWidth.clamp(AppFloatingChrome.widgetSize, 400.0);

      await windowManager.setSize(Size(width, totalHeight));
    } else {
      await windowManager.setSize(
        const Size(AppFloatingChrome.widgetSize, AppFloatingChrome.widgetSize),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuModules = widget.registry.menuModules;

    final widgetCircle = GestureDetector(
      onTap: _toggleMenu,
      child: Container(
        width: AppFloatingChrome.widgetSize,
        height: AppFloatingChrome.widgetSize,
        decoration: AppFloatingChrome.widgetOrb,
        child: const Center(
          child: LogoWidget(size: 40),
        ),
      ),
    );

    final menuBar = _menuVisible
        ? DragTarget<String>(
            onAcceptWithDetails: (details) {
              widget.registry.addToMenu(details.data);
            },
            builder: (context, candidateData, rejectedData) {
              return MenuBarWidget(
                modules: menuModules,
                showAbove: _menuAbove,
                onModuleOpen: _openModuleById,
              );
            },
          )
        : const SizedBox.shrink();

    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      onPanUpdate: (_) {
        _updateScreenInfo();
      },
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _menuAbove
              ? [
                  menuBar,
                  if (_menuVisible) const SizedBox(height: AppFloatingChrome.menuBarGap),
                  widgetCircle,
                ]
              : [
                  widgetCircle,
                  if (_menuVisible) const SizedBox(height: AppFloatingChrome.menuBarGap),
                  menuBar,
                ],
        ),
      ),
    );
  }
}
