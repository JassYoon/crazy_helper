import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../core/theme.dart';
import '../core/module_registry.dart';
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

  static const double widgetSize = 56;
  static const double menuBarHeight = 52;
  static const double menuBarGap = 8;

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

  void _toggleMenu() {
    setState(() {
      _menuVisible = !_menuVisible;
    });
    _updateWindowSize();
  }

  Future<void> _updateWindowSize() async {
    if (_menuVisible) {
      final totalHeight = widgetSize + menuBarGap + menuBarHeight;
      final menuModules = widget.registry.menuModules;
      final menuWidth = menuModules.isEmpty
          ? 220.0
          : (menuModules.length * 48.0 + 16).clamp(100.0, 400.0);
      final width = menuWidth.clamp(widgetSize, 400.0);

      await windowManager.setSize(Size(width, totalHeight));
    } else {
      await windowManager.setSize(const Size(widgetSize, widgetSize));
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuModules = widget.registry.menuModules;

    final widgetCircle = GestureDetector(
      onTap: _toggleMenu,
      child: Container(
        width: widgetSize,
        height: widgetSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
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
              ? [menuBar, if (_menuVisible) const SizedBox(height: menuBarGap), widgetCircle]
              : [widgetCircle, if (_menuVisible) const SizedBox(height: menuBarGap), menuBar],
        ),
      ),
    );
  }
}
